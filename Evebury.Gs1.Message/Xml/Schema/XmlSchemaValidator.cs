using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Schema;

namespace Evebury.Gs1.Message.Xml.Schema
{
    /// <summary>
    /// Validator for validating XmlDocuments with Schema(set)s
    /// </summary>
    internal class XmlSchemaValidator
    {

        private bool IsValid;

        private List<XmlSchemaValidatorMessage> Messages;

        /// <summary>
        /// Constructs new Validator
        /// </summary>
        public XmlSchemaValidator()
        {
            Reset();
        }

        private void Reset()
        {
            IsValid = true;
            Messages = [];
        }

        private void Clear()
        {
            IsValid = false;
            Messages = null;
        }

        private void SchemaValidationEventHandler(object sender, ValidationEventArgs e)
        {
            IsValid = false;
            Messages.Add(new XmlSchemaValidatorMessage(e));
        }

        /// <summary>
        /// Validate a XmlDocument with a SchemaSet
        /// </summary>
        /// <param name="xml">The document to validate</param>
        /// <param name="schemas">the schemas to validate the document with</param>
        /// <returns>a result <see cref="XmlSchemaValidatorResult"/></returns>
        public Task<XmlSchemaValidatorResult> Validate(XmlDocument xml, XmlSchemaSet schemas)
        {
            return Task.Run(() =>
            {
                XmlSchemaValidatorResult result = new(false, null);
                Reset();

                try
                {
                    xml.Schemas.Add(schemas);
                    ValidationEventHandler handler = new(SchemaValidationEventHandler);
                    xml.Validate(handler);
                    result = new XmlSchemaValidatorResult(IsValid, Messages);
                }
                catch (Exception e)
                {
                    Messages.Add(new XmlSchemaValidatorMessage(e));
                    result = new XmlSchemaValidatorResult(false, Messages);
                }

                Clear();
                return result;
            });
        }
    }
}
