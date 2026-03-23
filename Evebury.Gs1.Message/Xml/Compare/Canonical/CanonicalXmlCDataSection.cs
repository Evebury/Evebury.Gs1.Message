using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlCDataSection(string cdata, XmlDocument xml) : XmlCDataSection(cdata, xml), ICanonicalNode
    {
        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            byte[] bytes = new UTF8Encoding(false).GetBytes(XmlWriter.EscapeTextData(Data));
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
        }
    }
}
