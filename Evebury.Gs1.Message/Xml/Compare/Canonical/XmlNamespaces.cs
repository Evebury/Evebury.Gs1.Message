using System.Collections.Generic;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class XmlNamespaces
    {
        private readonly Dictionary<string, XmlAttribute> _namespaces = [];
        internal readonly Dictionary<string, XmlAttribute> Output = [];

        public void Add(XmlAttribute attribute, bool output) 
        {
            if (output) Output.Add(XmlNamespace.GetNamespacePrefix(attribute), attribute);
            else _namespaces.Add(XmlNamespace.GetNamespacePrefix(attribute), attribute);
        }

        public XmlAttribute GetAttribute(string prefix, bool output)
        {
            if (output)
            {
                if (Output.TryGetValue(prefix, out XmlAttribute attribute)) return attribute;
                return null;
            }

            if(_namespaces.TryGetValue(prefix, out XmlAttribute nameSpace)) return nameSpace;
            return null;
        }
    }
}
