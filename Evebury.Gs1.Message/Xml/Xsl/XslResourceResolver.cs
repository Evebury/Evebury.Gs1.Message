using System;
using System.IO;
using System.Resources;
using System.Text;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Xsl
{
    /// <summary>
    /// Xsl resource manager resolver class
    /// </summary>
    /// <remarks>
    /// Constructs a resolver around a ResourceManager
    /// </remarks>
    /// <param name="resourceManager"></param>
    internal class XslResourceResolver(ResourceManager resourceManager) : XmlResolver
    {
        private readonly ResourceManager _resourceManager = resourceManager;

        /// <summary>
        /// override to fetch files from resource
        /// </summary>
        /// <param name="absoluteUri">as defined in include</param>
        /// <param name="role">N.I.</param>
        /// <param name="ofObjectToReturn">Xslt file from resource as memorystream</param>
        /// <returns></returns>
        public override object GetEntity(Uri absoluteUri, string role, Type ofObjectToReturn)
        {

            string name = Path.GetFileNameWithoutExtension(absoluteUri.ToString());

            object value = _resourceManager.GetObject(name);
            if (value != null)
            {
                if (value is string xslt)
                {
                    UTF8Encoding utf8Encoding = new();
                    byte[] entityBytes = utf8Encoding.GetBytes(xslt);
                    return new MemoryStream(entityBytes);
                }
                else if (value is byte[] bytes)
                {
                    return new MemoryStream(bytes);
                }
            }
            return null;
        }
    }
}
