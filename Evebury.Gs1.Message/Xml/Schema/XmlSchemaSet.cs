using System.Collections;
using System.Globalization;
using System.IO;
using System.Resources;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Schema
{
    internal class XmlSchemaSet : System.Xml.Schema.XmlSchemaSet
    {

        /// <summary>
        /// Loads all schema's from a invariant culture resourcefile and binds them to a schemaset
        /// </summary>
        /// <param name="resourceManager">The resourcemanager of the invariant culture resource containing the schema's</param>
        /// <returns>a schemaset containing all schema's in the invariant culture resource</returns>
        public static XmlSchemaSet Load(ResourceManager resourceManager)
        {
            XmlSchemaSet set = new();
            ResourceSet entries = resourceManager.GetResourceSet(CultureInfo.InvariantCulture, true, true);
            foreach (DictionaryEntry entry in entries)
            {
                string resourceKey = entry.Key.ToString();
                System.Xml.Schema.XmlSchema schema = LoadSchema(resourceManager, resourceKey);
                set.Add(schema);
            }
            set.Compile();
            return set;
        }

        private static System.Xml.Schema.XmlSchema LoadSchema(ResourceManager resourceManager, string resourceKey)
        {
            System.Xml.Schema.XmlSchema schema = null;

            XmlDocument xsd = null;

            object value = resourceManager.GetObject(resourceKey);
            if (value is byte[] bytes)
            {
                xsd = LoadXmlSchema(bytes);
            }
            else if (value is string str)
            {
                xsd = LoadXmlSchema(Encoding.UTF8.GetBytes(str));
            }

            using (MemoryStream stream = new())
            {
                xsd.Save(stream);
                stream.Position = 0;
                schema = System.Xml.Schema.XmlSchema.Read(stream, null);
            }
            return schema;
        }

        private static XmlDocument LoadXmlSchema(byte[] bytes, bool skipAnnotations = true) 
        {
            XmlReaderSettings settings = new()
            {
                IgnoreComments = true,
                IgnoreWhitespace = true,
            };
            XmlDocument xsd = new();

            using (MemoryStream stream = new(bytes))
            {
                using (XmlReader reader = XmlReader.Create(stream, settings))
                {
                    xsd.Load(reader);
                }
            }

            if (skipAnnotations)
            {
                XmlNamespaceManager xnm = new(xsd.NameTable);
                xnm.AddNamespace("xsd", xsd.DocumentElement.NamespaceURI);
                XmlNodeList nodes = xsd.SelectNodes("//xsd:annotation", xnm);
                foreach (XmlNode node in nodes)
                {
                    node.ParentNode.RemoveChild(node);
                }
            }
            return xsd;
        }

    }
}
