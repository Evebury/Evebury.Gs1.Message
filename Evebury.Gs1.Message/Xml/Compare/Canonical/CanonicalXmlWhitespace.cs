using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlWhitespace(string text, XmlDocument xml) : XmlWhitespace(text, xml), ICanonicalNode
    {
        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            if (pointer == XmlPointer.InRootElement)
            {
                byte[] bytes = new UTF8Encoding(false).GetBytes(XmlWriter.EscapeWhitespaceData(Value));
                hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            }
        }
    }
}
