using System;
using System.IO;
using System.Security.Cryptography;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal class CanonicalXmlDocument : XmlDocument, ICanonicalNode
    {
        private CanonicalXmlDocument()
        {
            PreserveWhitespace = true;
            XmlResolver = XmlResolver.ThrowingResolver;
        }

        public static CanonicalXmlDocument Load(XmlDocument document)
        {
            ArgumentNullException.ThrowIfNull(document);

            CanonicalXmlDocument canonical = new();
            canonical.Load(new XmlNodeReader(document));
            return canonical;
        }

        public static CanonicalXmlDocument LoadStream(Stream stream)
        {
            ArgumentNullException.ThrowIfNull(stream);
            if (!stream.CanRead) throw new ArgumentException("Unable to read stream", nameof(stream));

            XmlReaderSettings settings = new()
            {
                XmlResolver = XmlResolver.ThrowingResolver,
                DtdProcessing = DtdProcessing.Parse
            };

            XmlReader reader = XmlReader.Create(stream, settings);

            CanonicalXmlDocument canonical = new();
            canonical.Load(reader);
            return canonical;
        }

        public override XmlAttribute CreateAttribute(string prefix, string localName, string namespaceURI)
        {
            return new CanonicalXmlAttribute(prefix, localName, namespaceURI, this);
        }

        public override XmlCDataSection CreateCDataSection(string data)
        {
            return new CanonicalXmlCDataSection(data, this);
        }

        public override XmlComment CreateComment(string data)
        {
            return new CanonicalXmlComment(data, this);
        }

        protected override XmlAttribute CreateDefaultAttribute(string prefix, string localName, string namespaceURI)
        {
            return new CanonicalXmlAttribute(prefix, localName, namespaceURI, this);
        }

        public override XmlElement CreateElement(string prefix, string localName, string namespaceURI)
        {
            return new CanonicalXmlElement(prefix, localName, namespaceURI, this);
        }

        public override XmlEntityReference CreateEntityReference(string name)
        {
            return new CanonicalXmlEntityReference(name, this);
        }

        public override XmlProcessingInstruction CreateProcessingInstruction(string target, string data)
        {
            return new CanonicalXmlProcessingInstruction(target, data, this);
        }

        public override XmlSignificantWhitespace CreateSignificantWhitespace(string text)
        {
            return new CanonicalXmlSignificantWhitespace(text, this);
        }

        public override XmlText CreateTextNode(string text)
        {
            return new CanonicalXmlText(text, this);
        }

        public override XmlWhitespace CreateWhitespace(string prefix)
        {
            return new CanonicalXmlWhitespace(prefix, this);
        }

        public void WriteHash(HashAlgorithm hashAlgorithm)
        {
            WriteHash(hashAlgorithm, XmlPointer.BeforeRootElement, new XmlNamespaceContext());
        }

        public void WriteHash(HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext context)
        {
            pointer = XmlPointer.BeforeRootElement;
            foreach (XmlNode node in ChildNodes)
            {
                if (node.NodeType == XmlNodeType.Element)
                {
                    XmlWriter.WriteHash(node, hash, XmlPointer.InRootElement, context);
                    pointer = XmlPointer.AfterRootElement;
                }
                else
                {
                    XmlWriter.WriteHash(node, hash, pointer, context);
                }
            }
        }
    }
}
