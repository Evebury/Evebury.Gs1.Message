using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Resources;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Xsl
{
    internal class XslResolver
    {
        /// <summary>
        /// Resolves a xsl document from the resource. Nb! resource may only contain xslt files.
        /// </summary>
        /// <param name="resourceManager">the resourcemanager</param>
        /// <returns>a XslDocument object</returns>
        public static XslDocument Resolve(ResourceManager resourceManager)
        {
            XslResourceResolver xslResourceResolver = new(resourceManager);
            XmlDocument resolved = new();
            XmlNamespaceManager xmlNamespaceManager = null;
            List<string> includes = [];

            ResourceSet entries = resourceManager.GetResourceSet(CultureInfo.InvariantCulture, true, true);
            foreach (DictionaryEntry entry in entries)
            {
                string resourceKey = entry.Key.ToString();

                if (xmlNamespaceManager == null)
                {
                    includes.Add(resourceKey);
                    if (entry.Value is string value)
                    {
                        resolved.LoadXml(value);
                    }
                    else if (entry.Value is byte[] bytes)
                    {
                        using (MemoryStream stream = new(bytes))
                        {
                            resolved.Load(stream);
                        }
                    }
                    xmlNamespaceManager = new XmlNamespaceManager(resolved.NameTable);
                    xmlNamespaceManager.AddNamespace("xsl", resolved.DocumentElement.NamespaceURI);
                    Resolve(resolved, xslResourceResolver, xmlNamespaceManager, includes);
                }
                else if (!includes.Contains(resourceKey))
                {
                    XmlDocument xd = new();
                    if (entry.Value.GetType() == typeof(byte[]))
                    {
                        using (MemoryStream stream = new((byte[])entry.Value))
                        {
                            xd.Load(stream);
                        }
                    }
                    else xd.LoadXml(resourceManager.GetString(resourceKey));
                    includes.Add(resourceKey);
                    Resolve(xd, xslResourceResolver, xmlNamespaceManager, includes);
                    Append(resolved, xd, xmlNamespaceManager);
                }
            }
            return new XslDocument(resolved);
        }

        private static void Resolve(XmlDocument xsl, XmlResolver resolver, XmlNamespaceManager xmlNamespaceManager, List<string> includes)
        {
            XmlNodeList includeNodeList = xsl.SelectNodes(@"/*/xsl:include", xmlNamespaceManager);
            foreach (XmlNode includeNode in includeNodeList)
            {
                string href = includeNode.Attributes["href"].Value;
                string name = Path.GetFileNameWithoutExtension(href);
                if (!includes.Contains(name))
                {
                    includes.Add(name);


                    XmlDocument include = new();
                    include.Load((Stream)resolver.GetEntity(new Uri($"X:/{name}"), "role", typeof(Stream)));

                    Resolve(include, resolver, xmlNamespaceManager, includes);

                    Append(xsl, include, xmlNamespaceManager);
                }

                includeNode.ParentNode.RemoveChild(includeNode);
            }
        }


        private static void Append(XmlDocument xsl, XmlDocument include, XmlNamespaceManager xmlNamespaceManager)
        {
            foreach (XmlNode node in include.DocumentElement.ChildNodes)
            {
                if (node.NodeType == XmlNodeType.Element)
                {
                    switch (node.LocalName)
                    {
                        case "output":
                            {
                                if (xsl.SelectSingleNode("/*/xsl:output", xmlNamespaceManager) == null)
                                {
                                    xsl.DocumentElement.AppendChild(xsl.ImportNode(node, true));
                                }
                                break;
                            }
                        default:
                            {
                                xsl.DocumentElement.AppendChild(xsl.ImportNode(node, true));
                                break;
                            }
                    }
                }
            }

            XmlNode xslNode = xsl.SelectSingleNode("xsl:stylesheet", xmlNamespaceManager);
            XmlNode includeNode = include.SelectSingleNode("xsl:stylesheet", xmlNamespaceManager);

            foreach (XmlAttribute attribute in includeNode.Attributes)
            {
                // Copy namespaces.
                if (attribute.Name.StartsWith("xmlns:") && xslNode.Attributes[attribute.Name] == null)
                {
                    // Create new namespace attribute.
                    xslNode.Attributes.Append(xsl.CreateAttribute(attribute.Name)).Value = attribute.Value;
                }
                else if (attribute.Name == "exclude-result-prefixes")
                {
                    if (xslNode.Attributes[attribute.Name] == null)
                    {
                        xslNode.Attributes.Append(xsl.CreateAttribute(attribute.Name)).Value = attribute.Value;
                    }
                    else
                    {
                        List<string> prefixes = [];
                        prefixes.AddRange(xslNode.Attributes[attribute.Name].Value.Split(' '));
                        prefixes.AddRange(includeNode.Attributes[attribute.Name].Value.Split(' '));
                        xslNode.Attributes[attribute.Name].Value = string.Join(" ", prefixes.Distinct());
                    }

                }
            }
        }
    }
}
