using System.Xml;

namespace Evebury.Gs1.Message.Xml
{
    /// <summary>
    /// Namespace
    /// </summary>
    /// <param name="prefix"></param>
    /// <param name="uri"></param>
    internal struct XmlNamespace(string prefix, string uri)
    {
        /// <summary>
        /// Prefix
        /// </summary>
        public string Prefix { get; set; } = prefix;

        /// <summary>
        /// Uri
        /// </summary>
        public string Uri { get; set; } = uri;


        /// <summary>
        /// Gets the prefix if set else string.empty
        /// </summary>
        /// <param name="attribute"></param>
        /// <returns></returns>
        public static string GetNamespacePrefix(XmlAttribute attribute)
        {
            if (attribute.Prefix.Length != 0)
            {
                return attribute.LocalName;
            }
            return string.Empty;
        }


        /// <summary>
        /// checks if attribute has prefix
        /// </summary>
        /// <param name="attribute"></param>
        /// <param name="prefix"></param>
        /// <returns></returns>
        public static bool HasNamespacePrefix(XmlAttribute attribute, string prefix)
        {
            return GetNamespacePrefix(attribute).Equals(prefix);
        }

        /// <summary>
        /// Checks if a node has a namespace
        /// </summary>
        /// <param name="node"></param>
        /// <returns></returns>
        public static bool IsNamespaceNode(XmlNode node)
        {
            if (node.NodeType != XmlNodeType.Attribute)
            {
                return false;
            }
            return node.Prefix.Equals("xmlns") || ((node.Prefix.Length == 0) && node.LocalName.Equals("xmlns"));
        }

    }
}
