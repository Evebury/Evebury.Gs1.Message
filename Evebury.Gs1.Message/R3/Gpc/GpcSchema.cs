using System.IO;
using System.Xml;

namespace Evebury.Gs1.Message.R3.Gpc
{
    internal class GpcSchema
    {
        public static BrickPath GetBrickPath(string brick) 
        {
            if (string.IsNullOrEmpty(brick)) return new BrickPath();

            XmlDocument xml = new();
            using (MemoryStream stream = new(Resource.Gpc.gpc)) 
            {
                xml.Load(stream);
            }
            XmlNode node = xml.SelectSingleNode($"/schema/segment/family/class[brick/@code = '{brick}']");
            if (node == null) return new BrickPath();

            return new BrickPath()
            {
                Class = node.Attributes["code"].Value,
                Family = node.ParentNode.Attributes["code"].Value,
                Segment = node.ParentNode.ParentNode.Attributes["code"].Value,
            };  
        }
    }
}
