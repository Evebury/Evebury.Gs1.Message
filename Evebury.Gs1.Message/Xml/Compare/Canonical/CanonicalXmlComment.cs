using System.Security.Cryptography;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlComment(string comment, XmlDocument xml) : XmlComment(comment, xml), ICanonicalNode
    {
        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            //skip comments in hash
        }
    }
}
