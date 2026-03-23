using System;
using System.Collections.Generic;
using System.Xml;
using System.Xml.Schema;

namespace Evebury.Gs1.Message.Xml.Schema
{
    /// <summary>
    /// Xml Schema Validator Message
    /// </summary>
    internal class XmlSchemaValidatorMessage
    {
        /// <summary>
        /// Severity either Error or Warning 
        /// </summary>
        public XmlSchemaValidatorSeverity Severity { get; }

        /// <summary>
        /// Exception message
        /// </summary>
        public string Message { get; }

        /// <summary>
        /// XPath to offending node 
        /// </summary>
        public string XPath { get; set; }

        internal XmlSchemaValidatorMessage(ValidationEventArgs e)
        {
            Severity = (e.Severity == XmlSeverityType.Warning) ? XmlSchemaValidatorSeverity.Warning : XmlSchemaValidatorSeverity.Error;
            Message = e.Exception.Message;
            XPath = GetXPath(e.Exception as XmlSchemaValidationException);
        }

        private static string GetXPath(XmlSchemaValidationException exception)
        {
            List<string> path = [];
            XmlNode node = exception.SourceObject as XmlNode;
            while (node != null)
            {
                if (node.Name == "#document") path.Add(string.Empty);
                else path.Add(node.Name);
                node = node.ParentNode;
            }
            path.Reverse();
            return string.Join("/", path);
        }

        internal XmlSchemaValidatorMessage(Exception e) : this(XmlSchemaValidatorSeverity.Error, e.Message)
        {
        }

        internal XmlSchemaValidatorMessage(XmlSchemaValidatorSeverity severity, string message)
        {
            Severity = severity;
            Message = message;
            XPath = "#document";
        }

        /// <summary>
        /// Converts the value of the current object to its equivalent String representation.(Overrides Object.ToString().)
        /// </summary>
        public override string ToString()
        {
            return $"{Severity} {Message} XPath: {XPath}";
        }
    }
}
