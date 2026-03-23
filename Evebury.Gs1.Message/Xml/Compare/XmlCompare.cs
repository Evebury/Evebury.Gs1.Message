using Evebury.Gs1.Message.Xml.Compare.Canonical;
using System;
using System.Security.Cryptography;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare
{
    internal class XmlCompare
    {
        /// <summary>
        /// Generates an unique hash code for this xml using a canonical xml
        /// </summary>
        /// <param name="xml"></param>
        /// <param name="xPaths">Optional omit paths to exclude in hash generation e.g. for timestamps</param>
        /// <returns>base64 hash</returns>
        public static string GetHashCode(XmlDocument xml, XPaths xPaths = null)
        {
            if (xPaths == null) return GetHashCode(xml);
            XmlDocument omitted = Omit(xml, xPaths);
            return GetHashCode(omitted);
        }

        /// <summary>
        /// Gets the base64 hashcode string SHA256 encoded
        /// </summary>
        /// <param name="document"></param>
        /// <returns></returns>
        private static string GetHashCode(XmlDocument document)
        {
            byte[] hash;
            using (SHA256 sha = SHA256.Create())
            {
                CanonicalXmlDocument canonical = CanonicalXmlDocument.Load(document);
                canonical.WriteHash(sha);
                sha.TransformFinalBlock([], 0, 0);
                hash = (byte[])sha.Hash.Clone();
                sha.Initialize();
            }
            return Convert.ToBase64String(hash);
        }

        /// <summary>
        /// Omits nodes or attributes before comparing. Will create a clone of the document 
        /// </summary>
        /// <param name="xml"></param>
        /// <param name="xPaths"></param>
        /// <returns></returns>
        private static XmlDocument Omit(XmlDocument xml, XPaths xPaths)
        {
            XmlDocument document = (XmlDocument)xml.Clone();
            XmlNamespaceManager namespaceManager = xPaths.GetXmlNamespaceManager(document);
            foreach (XPath ommit in xPaths.Paths)
            {
                bool hasAttribute = ommit.Attribute != null;
                string xpath = ommit.Path;
                if (hasAttribute)
                {
                    xpath = $"{xpath}[@{ommit.Attribute}]";
                }
                XmlNodeList list = document.SelectNodes(xpath, namespaceManager);
                foreach (XmlNode node in list)
                {
                    if (ommit.Attribute != null)
                    {
                        XmlAttribute attribute = node.Attributes[ommit.Attribute];
                        if (attribute != null)
                        {
                            node.Attributes.Remove(attribute);
                        }
                    }
                    else
                    {
                        node.ParentNode.RemoveChild(node);
                    }
                }
            }
            return document;
        }
    }
}
