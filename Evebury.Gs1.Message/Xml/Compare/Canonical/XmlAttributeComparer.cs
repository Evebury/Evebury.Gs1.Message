using System;
using System.Collections;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class XmlAttributeComparer : IComparer
    {
        public int Compare(object x, object y)
        {
            XmlNode node1 = x as XmlNode;
            XmlNode node2 = y as XmlNode;
            if ((x == null) || (y == null))
            {
                throw new ArgumentException("node can not be null");
            }
            int compare = string.CompareOrdinal(node1.NamespaceURI, node2.NamespaceURI);
            if (compare != 0)
            {
                return compare;
            }
            return string.CompareOrdinal(node1.LocalName, node2.LocalName);
        }
    }
}
