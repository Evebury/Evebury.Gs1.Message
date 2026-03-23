using System;
using System.Collections.Generic;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare
{
    /// <summary>
    /// Use for xml compare
    /// </summary>
    internal class XPaths
    {
        /// <summary>
        /// List of xpaths
        /// </summary>
        public List<XPath> Paths { get; set; } = [];

        /// <summary>
        /// Optional list of namespaces for specified xpaths
        /// </summary>
        public List<XmlNamespace> Namespaces { get; set; } = [];


        /// <summary>
        /// ctor
        /// </summary>
        /// <param name="xPaths"></param>
        /// <param name="namespaces"></param>
        /// <exception cref="ArgumentException"></exception>
        public XPaths(List<XPath> xPaths, List<XmlNamespace> namespaces = null)
        {
            if (xPaths == null || xPaths.Count == 0) throw new ArgumentException("Xpaths null or empty", nameof(xPaths));
            Paths = xPaths;
            namespaces ??= [];
            Namespaces = namespaces;
        }


        public XmlNamespaceManager GetXmlNamespaceManager(XmlDocument xml)
        {
            XmlNamespaceManager manager = new(xml.NameTable);
            foreach (XmlNamespace nameSpace in Namespaces)
            {
                manager.AddNamespace(nameSpace.Prefix, nameSpace.Uri);
            }
            return manager;
        }
    }
}
