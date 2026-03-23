using System;
using System.Collections;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class XmlNamespaceComparer : IComparer
    {
        public int Compare(object x, object y)
        {
            XmlNode node1 = x as XmlNode;
            XmlNode node2 = y as XmlNode;
            if ((x == null) || (y == null))
            {
                throw new ArgumentException("node can not be null");
            }
            bool default1 = XmlNamespaceContext.IsDefaultNamespaceNode(node1);
            bool default2 = XmlNamespaceContext.IsDefaultNamespaceNode(node2);
            if (default1 && default2)
            {
                return 0;
            }
            if (default1)
            {
                return -1;
            }
            if (default2)
            {
                return 1;
            }
            return string.CompareOrdinal(node1.LocalName, node2.LocalName);
        }
    }
}
