using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class XmlNamespaceContext
    {
       
        private readonly List<XmlNamespaces> _namespaces = [];

        public void EnterElement(Dictionary<string, XmlAttribute> namespaces, SortedList output)
        {
            XmlNamespaces xmlNamespaces = new();
            foreach (string key in namespaces.Keys)
            {
                xmlNamespaces.Add(namespaces[key], false);
            }

            foreach (object obj in output.GetKeyList())
            {
                xmlNamespaces.Add((XmlAttribute)obj, true);
            }
            _namespaces.Add(xmlNamespaces);
        }

        public void ExitElement()
        {
            _namespaces.RemoveAt(_namespaces.Count - 1);
        }

        public SortedList GetAttributes(XmlElement element, Dictionary<string, XmlAttribute> namespaces) 
        {
            SortedList attributes = new(new XmlAttributeComparer());
            if (element.Attributes != null)
            {
                foreach (XmlAttribute attribute in element.Attributes)
                {
                    if (IsNamespaceNode(attribute) || IsXmlNamespaceNode(attribute))
                    {
                        namespaces.Add(XmlNamespace.GetNamespacePrefix(attribute), attribute);
                    }
                    else
                    {
                        attributes.Add(attribute, null);
                    }
                }
            }

            string prefix = element.Prefix;
            if (!IsCommittedNamespace(element, prefix, element.NamespaceURI))
            {
                string name = (prefix.Length == 0) ? "xmlns" : $"xmlns:{prefix}";
                XmlAttribute attribute = element.OwnerDocument.CreateAttribute(name);
                attribute.Value = element.NamespaceURI;
                namespaces.Add(XmlNamespace.GetNamespacePrefix(attribute), attribute);
            }
            return attributes;
        }

        public SortedList GetOutputNamespaces(Dictionary<string, XmlAttribute> namespaces, SortedList attributes) 
        {
            SortedList output = new(new XmlNamespaceComparer());

            foreach (string prefix in namespaces.Keys) 
            {
                XmlAttribute attribute = namespaces[prefix];
                XmlAttribute nearest = GetNearestWithMatchingPrefix(prefix, true, out _);
                if (IsNonRedundantNamespace(attribute, nearest))
                {
                    namespaces.Remove(prefix);

                    if (IsXmlNamespaceNode(attribute))
                    {
                        attributes.Add(attribute, null);
                    }
                    else
                    {
                        output.Add(attribute, null);
                    }
                }
            }

            for (int i = _namespaces.Count - 1; i >= 0; i--)
            {
                Dictionary<string, XmlAttribute> dict = _namespaces[i].Output;
                foreach (string prefix in dict.Keys)
                {
                    if (!namespaces.ContainsKey(prefix)) continue;
                    GetOutputNamespace(prefix, namespaces, attributes, output);
                }
            }

            return output;
        }

        private void GetOutputNamespace(string prefix, Dictionary<string, XmlAttribute> namespaces, SortedList attributes, SortedList output)
        {
            foreach (object ns in output.GetKeyList())
            {
                if (XmlNamespace.HasNamespacePrefix((XmlAttribute)ns, prefix))
                {
                    return;
                }
            }
            foreach (object attr in attributes.GetKeyList())
            {
                if (((XmlAttribute)attr).LocalName.Equals(prefix))
                {
                    return;
                }
            }
            XmlAttribute attribute = namespaces[prefix];
            XmlAttribute nearest = GetNearestWithMatchingPrefix(prefix, true, out int depth1);
            if (attribute != null)
            {
                if (IsNonRedundantNamespace(attribute, nearest))
                {
                    namespaces.Remove(prefix);
                    if (IsXmlNamespaceNode(attribute))
                    {
                        attributes.Add(attribute, null);
                    }
                    else
                    {
                        output.Add(attribute, null);
                    }
                }
            }
            else
            {
                attribute = GetNearestWithMatchingPrefix(prefix, false, out int depth2);
                if ((attribute != null) && (depth2 > depth1) && IsNonRedundantNamespace(attribute, attribute))
                {
                    if (IsXmlNamespaceNode(attribute))
                    {
                        attributes.Add(attribute, null);
                    }
                    else
                    {
                        output.Add(attribute, null);
                    }
                }
            }
        }

        private XmlAttribute GetNearestWithMatchingPrefix(string prefix, bool output, out int depth)
        {
            depth = -1;
            XmlAttribute attribute;
            for (int i = _namespaces.Count - 1; i >= 0; i--)
            {
                XmlNamespaces namespaces = _namespaces[i];
                attribute = namespaces.GetAttribute(prefix, output);
                if (attribute != null)
                {
                    depth = i;
                    return attribute;
                }
            }
            return null;
        }


        #region static
        private static bool IsCommittedNamespace(XmlElement element, string prefix, string value)
        {
            ArgumentNullException.ThrowIfNull(element);
            string name = (prefix.Length > 0) ? ("xmlns:" + prefix) : "xmlns";
            return element.HasAttribute(name) && (element.GetAttribute(name) == value);
        }

        private static bool IsNamespaceNode(XmlNode node)
        {
            if (node.NodeType != XmlNodeType.Attribute)
            {
                return false;
            }
            return node.Prefix.Equals("xmlns") || ((node.Prefix.Length == 0) && node.LocalName.Equals("xmlns"));
        }

        public static bool IsDefaultNamespaceNode(XmlNode node)
        {
            bool flag = (node.NodeType == XmlNodeType.Attribute) && (node.Prefix.Length == 0) && node.LocalName.Equals("xmlns");
            if (!flag)
            {
                return IsXmlNamespaceNode(node);
            }
            return true;
        }

        private static bool IsEmptyDefaultNamespaceNode(XmlNode node)
        {
            return IsDefaultNamespaceNode(node) && (node.Value.Length == 0);
        }

        private static bool IsNonRedundantNamespace(XmlAttribute attribute, XmlAttribute nearestAncestorWithSamePrefix)
        {
            if (nearestAncestorWithSamePrefix == null)
            {
                return !IsEmptyDefaultNamespaceNode(attribute);
            }
            return !nearestAncestorWithSamePrefix.Value.Equals(attribute.Value);
        }

        private static bool IsXmlNamespaceNode(XmlNode node)
        {
            return (node.NodeType == XmlNodeType.Attribute) && node.Prefix.Equals("xml");
        }
        #endregion
    }
}
