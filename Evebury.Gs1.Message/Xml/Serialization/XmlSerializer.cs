using System.IO;
using System.Threading.Tasks;
using System.Xml;

namespace Evebury.Gs1.Message.Xml.Serialization
{
    internal static class XmlSerializer
    {

        /// <summary>
        /// Deserialize from an XmlDocument to an object of type
        /// </summary>
        /// <param name="xd">Serialized object</param>
        /// <returns>a deserialized object</returns>
        public static Task<T> Deserialize<T>(XmlDocument xd)
        {
            return Task.Run(() =>
            {
                T obj = default;
                System.Xml.Serialization.XmlSerializer xs = new(typeof(T));
                using (MemoryStream ms = new())
                {
                    xd.Save(ms);
                    ms.Position = 0;
                    obj = (T)xs.Deserialize(ms);
                }
                return obj;
            });
        }
    }
}
