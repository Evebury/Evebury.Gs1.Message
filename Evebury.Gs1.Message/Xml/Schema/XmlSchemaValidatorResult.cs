using System.Collections.Generic;
using System.Text;

namespace Evebury.Gs1.Message.Xml.Schema
{
    /// <summary>
    /// A result upon validating against an schema(set)
    /// </summary>
    internal readonly struct XmlSchemaValidatorResult
    {
        /// <summary>
        /// Indicates if Xml is valid after validating against schema(set)
        /// </summary>
        public bool IsValid { get; }

        /// <summary>
        /// List containing any messages (only filled if IsValid = false)
        /// </summary>
        public XmlSchemaValidatorMessage[] Messages { get; }

        /// <summary>
        /// Constructs a Result
        /// </summary>
        /// <param name="isValid">indicate if result is valid</param>
        /// <param name="messages">any message if result not is valid</param>
        internal XmlSchemaValidatorResult(bool isValid, List<XmlSchemaValidatorMessage> messages)
        {
            IsValid = isValid;
            Messages = messages?.ToArray();
        }

        internal static XmlSchemaValidatorResult NoSchema => new(false, [new XmlSchemaValidatorMessage(XmlSchemaValidatorSeverity.Error, "No schema defined!")]);


        /// <summary>
        /// Converts the value of the current object to its equivalent String representation.(Overrides Object.ToString().)
        /// </summary>
        public override string ToString()
        {
            StringBuilder sb = new();
            sb.AppendLine($"Xml validation result: {IsValid}");
            if (Messages != null)
            {
                foreach (XmlSchemaValidatorMessage message in Messages)
                {
                    sb.AppendLine(message.ToString());
                }
            }
            return sb.ToString();
        }
    }
}
