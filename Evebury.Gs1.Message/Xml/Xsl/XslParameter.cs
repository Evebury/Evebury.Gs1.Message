using System;
using System.Globalization;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Xsl
{
    /// <summary>
    /// A parameter for a Xsl transformation
    /// </summary>
    internal class XslParameter
    {
        /// <summary>
        /// Name of the parameter as defined within the xslt (CaseSensitive)
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// The value of the parameter as string
        /// </summary> 
        public object Value { get; }

        /// <summary>
        /// Optional namespace uri
        /// </summary>
        public string NamespaceUri { get; }


        /// <summary>
        /// Creates a parameter to use for xslt transformation
        /// </summary>
        /// <param name="name">Name of the parameter as defined within the xslt (CaseSensitive)</param>
        /// <param name="value">The value of the parameter</param>
        /// <param name="nameSpaceUri">Optional namespaceuri</param>
        public XslParameter(string name, object value, string nameSpaceUri = "")
        {

            if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("Parameter name can not be null or empty.", nameof(name));

            Name = name;
            Value = ToXslValue(value);
            NamespaceUri = nameSpaceUri;
        }

        private static object ToXslValue(object value)
        {
            switch (value)
            {
                case XmlDocument obj:
                    {
                        return obj.CreateNavigator();
                    }
                case DateTime obj:
                    {
                        if (obj.Kind == DateTimeKind.Unspecified)
                        {
                            obj = DateTime.SpecifyKind(obj, DateTimeKind.Utc);
                        }
                        return obj.ToString("O", CultureInfo.InvariantCulture);
                    }
            }
            return value;
        }
    }
}
