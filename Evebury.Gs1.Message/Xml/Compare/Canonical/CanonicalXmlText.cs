using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlText(string text, XmlDocument xml) : XmlText(text, xml), ICanonicalNode
    {
        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            byte[] bytes = new UTF8Encoding(false).GetBytes(XmlWriter.EscapeTextData(Value));
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
        }
    }
}
