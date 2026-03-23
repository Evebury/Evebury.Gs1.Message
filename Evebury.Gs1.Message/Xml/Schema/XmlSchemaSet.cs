using System.Collections;
using System.Globalization;
using System.IO;
using System.Resources;
using System.Text;

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
            return set;
        }

        private static System.Xml.Schema.XmlSchema LoadSchema(ResourceManager resourceManager, string resourceKey)
        {
            System.Xml.Schema.XmlSchema schema = null;
            object value = resourceManager.GetObject(resourceKey);
            if (value is string xsd)
            {
                byte[] data = Encoding.UTF8.GetBytes(resourceManager.GetString(resourceKey));
                using (MemoryStream ms = new(data))
                {
                    schema = System.Xml.Schema.XmlSchema.Read(ms, null);
                }
            }
            else if (value is byte[] bytes)
            {
                using (MemoryStream ms = new(bytes))
                {
                    schema = System.Xml.Schema.XmlSchema.Read(ms, null);
                }
            }

            return schema;
        }

    }
}
