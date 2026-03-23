using System;

namespace Evebury.Gs1.Message.Xml.Compare
{
    /// <summary>
    /// XPath
    /// </summary>
    internal struct XPath
    {
        /// <summary>
        /// XPath e.g "//*", "/e:Entity". 
        /// </summary>
        public string Path { get; set; }

        /// <summary>
        /// Optional Attribute to exclude in this xpath
        /// </summary>
        public string Attribute { get; set; }

        /// <param name="xpath"></param>
        /// <param name="attribute"></param>
        public XPath(string xpath, string attribute = null)
        {
            if (string.IsNullOrEmpty(xpath) || xpath.EndsWith('/')) throw new ArgumentNullException(nameof(xpath));
            if (string.IsNullOrEmpty(attribute)) attribute = null;
            if (attribute != null)
            {
                if (attribute.StartsWith('@')) attribute = attribute[1..];
            }
            Path = xpath;
            Attribute = attribute;
        }
    }
}
