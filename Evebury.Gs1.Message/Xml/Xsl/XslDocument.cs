using System;
using System.Collections.Generic;
using System.IO;
using System.Resources;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.XPath;
using X = System.Xml.Xsl;

namespace Evebury.Gs1.Message.Xml.Xsl
{
    /// <summary>
    /// Constructs a new XslDocument
    /// </summary>
    /// <param name="xsl">the xsl document</param>
    internal class XslDocument(IXPathNavigable xsl)
    {
        /// <summary>
        /// Gets the resolved xsl document
        /// </summary>
        public IXPathNavigable Xsl { get; } = xsl;

        /// <summary>
        /// Loads a resolved xsl document from a resource
        /// </summary>
        /// <param name="resource">the resource containing (only) xslt files</param>
        /// <returns></returns>
        public static XslDocument Load(ResourceManager resource)
        {
            return XslResolver.Resolve(resource);
        }

        /// <summary>
        /// Loads a resolved xsl document from a byte array
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        public static XslDocument Load(byte[] bytes)
        {
            XmlDocument xd = new();
            using (MemoryStream stream = new(bytes))
            {
                xd.Load(stream);
            }
            return new XslDocument(xd);
        }

        /// <summary>
        /// Transforms the input with optional paramaters and extensions
        /// </summary>
        /// <param name="input">the input document implementing IXPathNavigable</param>
        /// <param name="parameters">optional xsl parameters</param>
        /// <param name="extensions">optional extension objects</param>
        /// <param name="cancellationToken">optional cancellationToken for terminating long lasting transformations</param>
        /// <returns>a xmldocument</returns>
        public Task<XmlDocument> Transform(IXPathNavigable input, List<XslParameter> parameters = null, List<IXslExtension> extensions = null, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(input);

            return Task.Run(() =>
            {
                XmlDocument xd = null;
                X.XslCompiledTransform xct = new(false);
                X.XsltSettings xs = new(true, true);
                xct.Load(Xsl, xs, new XmlUrlResolver());

                X.XsltArgumentList arguments = new();
                if (parameters != null)
                {
                    foreach (XslParameter parameter in parameters)
                    {
                        arguments.AddParam(parameter.Name, parameter.NamespaceUri, parameter.Value);
                    }
                }

                if (extensions != null)
                {
                    foreach (IXslExtension extension in extensions)
                    {
                        arguments.AddExtensionObject(extension.NamespaceUri, extension);
                    }
                }

                xd = new XmlDocument();
                using (XmlWriter writer = xd.CreateNavigator().AppendChild())
                {
                    xct.Transform(input, arguments, writer);
                }
                return xd;
            }, cancellationToken);
        }
    }
}
