using Evebury.Gs1.Message.Message;
using Evebury.Gs1.Message.Xml;
using Evebury.Gs1.Message.Xml.Compare;
using Evebury.Gs1.Message.Xml.Schema;
using Evebury.Gs1.Message.Xml.Serialization;
using Evebury.Gs1.Message.Xml.Xsl;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Xml;

namespace Evebury.Gs1.Message
{
    /// <summary>
    /// Validator for schema, compare and rule validations
    /// </summary>
    public class Validator
    {

        #region buffers
        private readonly Dictionary<MessageKey, XmlSchemaSet> _schemas = [];
        private readonly Dictionary<MessageKey, XslDocument> _rules = [];
        private readonly Dictionary<MessageKey, XslDocument> _auxiliary = [];
        private readonly Xsl.ResponseExtension _extension = new();
        #endregion

        /// <summary>
        /// Validates a Gs1 message. Will first apply the schema then do a compare and finally apply any applicable business rule.
        /// If any step fails a direct error response is returned
        /// </summary>
        /// <param name="message">The gs1 message</param>
        /// <param name="previous">Optional previously succesfully send message to the gs1 api</param>
        /// <returns cref="Response"></returns>
        /// <exception cref="MessageException"></exception>
        public async Task<Response> Validate(XmlDocument message, XmlDocument previous = null)
        {
            ArgumentNullException.ThrowIfNull(message);

            MessageKey key = MessageKey.GetKey(message);
            return await Validate(key, message, previous);
        }


        /// <summary>
        /// Validates a Gs1 message. Will first apply the schema then do a compare and finally apply any applicable business rule.
        /// If any step fails a direct error response is returned
        /// </summary>
        /// <param name="key">the message key</param>
        /// <param name="message">The gs1 message</param>
        /// <param name="previous">Optional previously succesfully send message to the gs1 api</param>
        /// <returns cref="Response"></returns>
        /// <exception cref="MessageException"></exception>
        public async Task<Response> Validate(MessageKey key, XmlDocument message, XmlDocument previous)
        {
            ArgumentNullException.ThrowIfNull(message);

            Response response = await ApplySchema(key, message);
            if (response.Status == StatusType.ERROR) return response;

            if (previous != null)
            {
                Response compare = Compare(message, previous);
                //return if Ok this indicates both messages are equal
                if (compare.Status == StatusType.OK) return compare;
            }

            //do not throw message exception rules do not apply to all message types
            XslDocument rules = LoadRules(key);
            if (rules != null)
            {
                response = await ApplyRules(key, rules, message, previous);
            }

            return response;
        }


        #region schema

        /// <summary>
        /// Applies a schema to the specified message
        /// </summary>
        /// <param name="message">Gs1 message</param>
        /// <returns cref="Response"></returns>
        /// <exception cref="ArgumentNullException">if message is null</exception>
        /// <exception cref="MessageException">if message is not a gs1 message</exception>
        public Task<Response> ApplySchema(XmlDocument message)
        {
            ArgumentNullException.ThrowIfNull(message);
            MessageKey key = MessageKey.GetKey(message);
            return ApplySchema(key, message);
        }

        private async Task<Response> ApplySchema(MessageKey key, XmlDocument message)
        {
            XmlSchemaSet schema = LoadSchema(key) ?? throw new MessageException(key);
            XmlSchemaValidator validator = new();
            XmlSchemaValidatorResult result = await validator.Validate(message, schema);
            return Response.GetResponse(result);
        }

        private XmlSchemaSet LoadSchema(MessageKey key) 
        {
            if (key.Type == MessageType.NotImplemented) return null;
            //set index key to message type there is one schema for all messages of said type
            MessageKey index = new()
            {
                Type = key.Type,
                Version = key.Version,
            };

            if (_schemas.TryGetValue(index, out XmlSchemaSet schema)) return schema;

            switch (index.Type) 
            {
                case MessageType.CatalogueItem: 
                    {
                        switch (index.Version)
                        {
                            case 3:
                                {
                                    schema = XmlSchemaSet.Load(R3.Schema.CatalogueItem.Resource.ResourceManager);
                                    _schemas.Add(index, schema);
                                    return schema;
                                }
                        }
                        break;
                    }
            }

            return null;
        }

        #endregion

        #region compare

        /// <summary>
        /// Compares two Gs1 messages
        /// </summary>
        /// <param name="message">Gs1 message</param>
        /// <param name="previous">Gs1 message if null returns false</param>
        /// <returns cref="Response">status set OK on equals otherwise ERROR</returns>
        /// <exception cref="ArgumentNullException">if message is null</exception>
        public static Response Compare(XmlDocument message, XmlDocument previous)
        {
            ArgumentNullException.ThrowIfNull(message);

            if (previous == null) return Response.GetResponse(false);


            MessageKey key = MessageKey.GetKey(message);

            XPaths paths = null;

            if (key.Type == MessageType.CatalogueItem)
            {
                List<XmlNamespace> namespaces = [];
                namespaces.Add(new("gs1", key.NamespaceUri));
                namespaces.Add(new("sh", "http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"));

                //ignore all timestamps and entityIdentification 
                List<XPath> xpaths = GetXPaths(key);
                if (key == MessageKey.CatalogueItemNotification3)
                {
                    xpaths.Add(new XPath("/gs1:catalogueItemNotificationMessage//tradeItemSynchronisationDates/lastChangeDateTime"));
                    xpaths.Add(new XPath("/gs1:catalogueItemNotificationMessage//tradeItemSynchronisationDates/effectiveDateTime"));
                    xpaths.Add(new XPath("/gs1:catalogueItemNotificationMessage//tradeItemSynchronisationDates/publicationDateTime"));
                }
                paths = new(xpaths, namespaces);
            }

            string hash1 = XmlCompare.GetHashCode(message, paths);
            string hash2 = XmlCompare.GetHashCode(previous, paths);
            Response response = Response.GetResponse(hash1 == hash2);
            response.SetVersion(key.Version);
            return response;
        }

        private static List<XPath> GetXPaths(MessageKey key)
        {
            List<XPath> xpaths = [];
            xpaths.Add(new XPath($"/gs1:{key.Message}/sh:StandardBusinessDocumentHeader/sh:DocumentIdentification/sh:CreationDateAndTime"));
            xpaths.Add(new XPath($"/gs1:{key.Message}/sh:StandardBusinessDocumentHeader/sh:DocumentIdentification/sh:InstanceIdentifier"));
            xpaths.Add(new XPath($"/gs1:{key.Message}/transaction/transactionIdentification/entityIdentification"));
            xpaths.Add(new XPath($"/gs1:{key.Message}/transaction/documentCommand/documentCommandHeader/documentCommandIdentification/entityIdentification"));
            xpaths.Add(new XPath($"/gs1:{key.Message}/transaction/documentCommand/gs1:{key.Element}/creationDateTime"));
            xpaths.Add(new XPath($"/gs1:{key.Message}/transaction/documentCommand/gs1:{key.Element}/lastUpdateDateTime"));
            xpaths.Add(new XPath($"/gs1:{key.Message}/transaction/documentCommand/gs1:{key.Element}/{key.Element}Identification/entityIdentification"));
            return xpaths;
        }

        #endregion

        #region rules

        /// <summary>
        /// Applies rules to the specified message
        /// </summary>
        /// <param name="message">Gs1 message</param>
        /// <param name="previous">Last Gs1 message successfully send to Gs1. Can be set to null</param>
        /// <returns cref="Response"></returns>
        /// <exception cref="ArgumentNullException">if message is null</exception>
        /// <exception cref="MessageException">if message is not a gs1 message</exception>
        public Task<Response> ApplyRules(XmlDocument message, XmlDocument previous = null)
        {
            ArgumentNullException.ThrowIfNull(message);
            MessageKey key = MessageKey.GetKey(message);
            XslDocument xsl = LoadRules(key) ?? throw new MessageException(key);
            return ApplyRules(key, xsl, message, previous);

        }

        private async Task<Response> ApplyRules(MessageKey key, XslDocument xsl, XmlDocument message, XmlDocument previous)
        {

            List<XslParameter> parameters = [];

            if (previous != null && key == MessageKey.CatalogueItemNotification3)
            {
                if(_auxiliary.TryGetValue(key, out XslDocument aux))
                { 
                    parameters = [];
                    XmlDocument current = await aux.Transform(previous);
                    parameters.Add(new("current", current));
                }
            }

            XmlDocument xml = await xsl.Transform(message, parameters, [_extension]);
            Response response = await XmlSerializer.Deserialize<Response>(xml);
            response.SetVersion(key.Version);
            return response;
        }


        private XslDocument LoadRules(MessageKey key) 
        {
            if (_rules.TryGetValue(key, out XslDocument xsl)) return xsl;

            if (key == MessageKey.CatalogueItemNotification3)
            {
                _auxiliary.Add(key, XslDocument.Load(R3.Xsl.CatalogueItem.XslResource.previous));
                xsl = XslDocument.Load(R3.Xsl.CatalogueItem.CatalogueItem.ResourceManager);
                _rules.Add(key, xsl);
                return xsl;
            }
            else if (key == MessageKey.CatalogueItemPublication3)
            {
                xsl = XslDocument.Load(R3.Xsl.CatalogueItem.XslResource.catalogueItemPublication);
                _rules.Add(key, xsl);
                return xsl;
            }
            else if (key == MessageKey.CatalogueItemHierarchicalWithdrawal3)
            {
                xsl = XslDocument.Load(R3.Xsl.CatalogueItem.XslResource.catalogueItemHierarchicalWithdrawal);
                _rules.Add(key, xsl);
                return xsl;
            }
            return null;
        }

        #endregion

        #region gs1 response

        /// <summary>
        /// Converts a gS1ResponseMessage to a Response
        /// </summary>
        /// <param name="gs1ResponseMessage">the gs1 response message</param>
        /// <param name="applySchema">if true applies schema to gS1ResponseMessage</param>
        /// <returns cref="Response"></returns>
        /// <exception cref="MessageException">if not defined</exception>
        /// <exception cref="ArgumentNullException">if gs1ResponseMessage is null</exception>
        public async Task<Response> ConvertGs1Response(XmlDocument gs1ResponseMessage, bool applySchema = false)
        {
            ArgumentNullException.ThrowIfNull(gs1ResponseMessage);
            MessageKey key = MessageKey.GetKey(gs1ResponseMessage);
            return await ConvertGs1Response(key, gs1ResponseMessage, applySchema);
        }

        /// <summary>
        /// Converts a gS1ResponseMessage to a Response
        /// </summary>
        /// <param name="key">the message key</param>
        /// <param name="gs1ResponseMessage">the gs1 response message</param>
        /// <param name="applySchema">if true applies schema to gS1ResponseMessage</param>
        /// <returns cref="Response"></returns>
        /// <exception cref="MessageException">if not defined</exception>
        /// <exception cref="ArgumentNullException">if gs1ResponseMessage is null</exception>
        public async Task<Response> ConvertGs1Response(MessageKey key, XmlDocument gs1ResponseMessage, bool applySchema = false)
        {
            ArgumentNullException.ThrowIfNull(gs1ResponseMessage);
            if (key != MessageKey.Gs1Response3) throw new MessageException(key);

            if (applySchema)
            {
                Response response = await ApplySchema(key, gs1ResponseMessage);
                if (response.Status == StatusType.ERROR) return response;
            }

            XslDocument xsl = LoadGs1Response(key);
            XmlDocument responseXml = await xsl.Transform(gs1ResponseMessage, null, [_extension]);
            return await XmlSerializer.Deserialize<Response>(responseXml);
        }

        private XslDocument LoadGs1Response(MessageKey key)
        {
            if (_auxiliary.TryGetValue(key, out XslDocument xsl)) return xsl;

            if (key == MessageKey.Gs1Response3)
            {
                xsl = XslDocument.Load(R3.Xsl.CatalogueItem.XslResource.gs1Response);
                _auxiliary.Add(key, xsl);
                return xsl;
            }
            return null;
        }

        #endregion

        /// <summary>
        /// Clears all buffers
        /// </summary>
        public void ClearBuffer()
        {
            _schemas.Clear();
            _rules.Clear();
            _auxiliary.Clear();
            _extension.ClearBuffer();
        }
    }
}
