using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlAttribute(string prefix, string localName, string namespaceURI, XmlDocument xml) : XmlAttribute(prefix, localName, namespaceURI, xml), ICanonicalNode
    {
        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            UTF8Encoding encoding = new(false);
            byte[] bytes = encoding.GetBytes($" {Name}=\"");
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            bytes = encoding.GetBytes(XmlWriter.EscapeAttributeValue(Value));
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            bytes = encoding.GetBytes("\"");
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
        }
    }
}
