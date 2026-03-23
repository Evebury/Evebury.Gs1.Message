using System.Security.Cryptography;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal interface ICanonicalNode
    {
        void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context);
    }
}
