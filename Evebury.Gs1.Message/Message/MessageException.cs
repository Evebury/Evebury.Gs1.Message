using System;

namespace Evebury.Gs1.Message.Message
{

    /// <summary>
    /// Exception thrown when message is not defined for current operation
    /// </summary>
    public class MessageException : Exception
    {
        /// <summary>
        /// ctor
        /// </summary>
        /// <param name="key"></param>
        public MessageException(MessageKey key) :base($"Message is not defined for current operation: {key.Message} {key.NamespaceUri}")
        { 
        }
    }
}
