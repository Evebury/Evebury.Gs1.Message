using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlProcessingInstruction(string target, string data, XmlDocument xml) : XmlProcessingInstruction(target, data, xml), ICanonicalNode
    {
        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            string LINE_FEED = $"{(char)10}";

            byte[] bytes;
            UTF8Encoding encoding = new(false);
            if (pointer == XmlPointer.AfterRootElement)
            {
                bytes = encoding.GetBytes(LINE_FEED);
                hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            }
            bytes = encoding.GetBytes("<?");
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            bytes = encoding.GetBytes(Name);
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            if ((Value != null) && (Value.Length > 0))
            {
                bytes = encoding.GetBytes($" {Value}");
                hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            }
            bytes = encoding.GetBytes("?>");
            hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            if (pointer == XmlPointer.BeforeRootElement)
            {
                bytes = encoding.GetBytes(LINE_FEED);
                hash.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
            }

        }
    }
}
