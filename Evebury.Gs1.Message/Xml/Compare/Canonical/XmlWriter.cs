using System;
using System.Security.Cryptography;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Compare.Canonical
{
    internal static class XmlWriter
    {
        public static void WriteHash(XmlNode node, HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext namespaceManager)
        {
            if (node is ICanonicalNode cnode)
            {
                cnode.WriteHash(hash, pointer, namespaceManager);
            }
            else
            {
                WriteHashGenericNode(node, hash, pointer, namespaceManager);
            }
        }

        public static void WriteHashGenericNode(XmlNode node, HashAlgorithm hash, XmlPointer pointer, XmlNamespaceContext namespaceManager)
        {
            ArgumentNullException.ThrowIfNull(node);

            foreach (XmlNode child in node.ChildNodes)
            {
                WriteHash(child, hash, pointer, namespaceManager);
            }
        }

        public static string EscapeTextData(string text)
        {
            StringBuilder sb = new();
            sb.Append(text);
            sb.Replace("&", "&amp;");
            sb.Replace("<", "&lt;");
            sb.Replace(">", "&gt;");
            ReplaceCharWithString(sb, '\r', "&#xD;");
            return sb.ToString();
        }

        public static string EscapeWhitespaceData(string text)
        {
            StringBuilder sb = new();
            sb.Append(text);
            ReplaceCharWithString(sb, '\r', "&#xD;");
            return sb.ToString();
        }

        private static void ReplaceCharWithString(StringBuilder sb, char oldChar, string newString)
        {
            int startIndex = 0;
            int length = newString.Length;
            while (startIndex < sb.Length)
            {
                if (sb[startIndex] == oldChar)
                {
                    sb.Remove(startIndex, 1);
                    sb.Insert(startIndex, newString);
                    startIndex += length;
                }
                else
                {
                    startIndex++;
                }
            }
        }

        public static string EscapeAttributeValue(string value)
        {
            StringBuilder sb = new();
            sb.Append(value);
            sb.Replace("&", "&amp;");
            sb.Replace("<", "&lt;");
            sb.Replace("\"", "&quot;");
            ReplaceCharWithString(sb, '\t', "&#x9;");
            ReplaceCharWithString(sb, '\n', "&#xA;");
            ReplaceCharWithString(sb, '\r', "&#xD;");
            return sb.ToString();
        }
    }
}
