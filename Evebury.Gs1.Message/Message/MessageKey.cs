using System;
using System.Xml;

namespace Evebury.Gs1.Message.Message
{
    /// <summary>
    /// Key for identifying GDSN GS1 messages
    /// </summary>
    /// <param name="message">full message name e.g. 'catalogueItemNotificationMessage'</param>
    /// <param name="element">name of the body element e.g. 'catalogueItemNotification'</param>
    /// <param name="nameSpaceUri">full namespaceUri e.g. 'urn:gs1:gdsn:catalogue_item_notification:xsd:3'</param>
    /// <param name="version">major version. schema should never break on minor update</param>
    /// <param name="type"></param>
    public struct MessageKey(string message, string element, string nameSpaceUri, int version, MessageType type) : IEquatable<MessageKey>
    {
        #region implemented
        /// <summary>
        /// catalogueItemNotificationMessage v3
        /// </summary>
        public static MessageKey CatalogueItemNotification3 => GetKey("catalogueItemNotificationMessage", "urn:gs1:gdsn:catalogue_item_notification:xsd:3", MessageType.CatalogueItem);

        /// <summary>
        /// gS1ResponseMessage v3
        /// </summary>
        public static MessageKey Gs1Response3 => GetKey("gS1ResponseMessage", "urn:gs1:gdsn:gs1_response:xsd:3", MessageType.CatalogueItem);

        /// <summary>
        /// catalogueItemPublicationMessage v3
        /// </summary>
        public static MessageKey CatalogueItemPublication3 => GetKey("catalogueItemPublicationMessage", "urn:gs1:gdsn:catalogue_item_publication:xsd:3", MessageType.CatalogueItem);

        /// <summary>
        /// catalogueItemHierarchicalWithdrawalMessage v3
        /// </summary>
        public static MessageKey CatalogueItemHierarchicalWithdrawal3 => GetKey("catalogueItemHierarchicalWithdrawalMessage", "urn:gs1:gdsn:catalogue_item_hierarchical_withdrawal:xsd:3", MessageType.CatalogueItem);

        /// <summary>
        /// catalogueItemConfirmationMessage v3
        /// </summary>
        public static MessageKey CatalogueItemConfirmation3 => GetKey("catalogueItemConfirmationMessage", "urn:gs1:gdsn:catalogue_item_confirmation:xsd:3", MessageType.CatalogueItem);

        /// <summary>
        /// catalogueItemRegistrationResponseMessage v3
        /// </summary>
        public static MessageKey CatalogueItemRegistrationResponse3 => GetKey("catalogueItemRegistrationResponseMessage", "urn:gs1:gdsn:catalogue_item_registration_response:xsd:3", MessageType.CatalogueItem);

        /// <summary>
        /// catalogueItemSubscriptionMessage v3
        /// </summary>
        public static MessageKey CatalogueItemSubscription3 => GetKey("catalogueItemSubscriptionMessage", "urn:gs1:gdsn:catalogue_item_subscription:xsd:3", MessageType.CatalogueItem);
        #endregion

        /// <summary>
        /// Full message name e.g. 'catalogueItemNotificationMessage'
        /// </summary>
        public string Message { get; set; } = message;

        /// <summary>
        /// Body element name e.g. 'catalogueItemNotification'
        /// </summary>
        public string Element { get; set; } = element;

        /// <summary>
        /// Full namespaceUri e.g. 'urn:gs1:gdsn:catalogue_item_notification:xsd:3'
        /// </summary>
        public string NamespaceUri { get; set; } = nameSpaceUri;

        /// <summary>
        /// Major version
        /// </summary>
        public int Version { get; set; } = version;

        /// <summary>
        /// Type (group)
        /// </summary>
        public MessageType Type { get; set; } = type;

        private static MessageType GetType(string namespaceUri) 
        {
            if (namespaceUri == CatalogueItemNotification3.NamespaceUri) return MessageType.CatalogueItem;
            if (namespaceUri == Gs1Response3.NamespaceUri) return MessageType.CatalogueItem;
            if (namespaceUri == CatalogueItemPublication3.NamespaceUri) return MessageType.CatalogueItem;
            if (namespaceUri == CatalogueItemHierarchicalWithdrawal3.NamespaceUri) return MessageType.CatalogueItem;
            if (namespaceUri == CatalogueItemConfirmation3.NamespaceUri) return MessageType.CatalogueItem;
            if (namespaceUri == CatalogueItemRegistrationResponse3.NamespaceUri) return MessageType.CatalogueItem;
            if (namespaceUri == CatalogueItemSubscription3.NamespaceUri) return MessageType.CatalogueItem;
            return MessageType.NotImplemented;
        }

        private static MessageKey GetKey(string message, string namespaceUri, MessageType type) 
        {
            string element = message;
            if (element.EndsWith("Message")) element = element[..^7];
            int version = 0;
            if (namespaceUri.Contains(':'))
            {
                string namespaceVersion = namespaceUri[(namespaceUri.LastIndexOf(':') + 1)..];
                _ = int.TryParse(namespaceVersion, out version);
            }
            return new MessageKey(message, element, namespaceUri, version, type);
        }

        /// <summary>
        /// Gets a message key for given content xml
        /// </summary>
        /// <param name="content"></param>
        /// <returns></returns>
        public static MessageKey GetKey(XmlDocument content)
        {
            string message = content.DocumentElement.LocalName;
            string namespaceUri = content.DocumentElement.NamespaceURI;
            MessageType type = GetType(namespaceUri);
            return GetKey(message, namespaceUri, type);
        }

#pragma warning disable CS1591 // Missing XML comment for publicly visible type or member
        public override readonly string ToString()
        {
            return $"{Message} {NamespaceUri}";
        }

        public readonly bool Equals(MessageKey other)
        {
            return string.Equals(Message, other.Message, StringComparison.OrdinalIgnoreCase) && string.Equals(NamespaceUri, other.NamespaceUri, StringComparison.OrdinalIgnoreCase) && Version == other.Version && Type == other.Type;
        }

        public override readonly bool Equals(object obj)
        {
            return obj is MessageKey key && Equals(key);
        }

        public override readonly int GetHashCode()
        {
            return HashCode.Combine(Message, NamespaceUri);
        }

        public static bool operator ==(MessageKey obj, MessageKey other)
        {
            return Equals(obj, other);
        }

        public static bool operator !=(MessageKey obj, MessageKey other)
        {
            return !Equals(obj, other);
        }
#pragma warning restore CS1591 // Missing XML comment for publicly visible type or member
    }
}
