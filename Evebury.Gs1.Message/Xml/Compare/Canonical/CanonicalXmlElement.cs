using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlElement(string prefix, string localName, string namespaceURI, XmlDocument xml) : XmlElement(prefix, localName, namespaceURI, xml), ICanonicalNode
    {
        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            Dictionary<string, XmlAttribute> namespaces = [];
            SortedList attributes = context.GetAttributes(this, namespaces);
            SortedList output = context.GetOutputNamespaces(namespaces, attributes);
            
            UTF8Encoding encoding = new(false);

            byte[] bytes = encoding.GetBytes($"<{Name}");
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            WriteHash(output, hash, pointer, context);
            WriteHash(attributes, hash, pointer, context);
            bytes = encoding.GetBytes(">");
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);

            context.EnterElement(namespaces, output);
            foreach (XmlNode node in ChildNodes)
            {
                XmlWriter.WriteHash(node, hash, pointer, context);
            }
            context.ExitElement();

            bytes = encoding.GetBytes($"</{Name}>");
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);

        }

        private static void WriteHash(SortedList list, HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context) 
        {
            foreach (object node in list.GetKeyList())
            {
                (node as CanonicalXmlAttribute).WriteHash(hash, pointer, context);
            }
        }
    }
}
