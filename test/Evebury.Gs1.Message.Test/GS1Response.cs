using System.Threading.Tasks;
using System.Xml;

namespace Evebury.Gs1.Message.Test
{
    [TestClass]
    public sealed class GS1Response
    {

        [TestMethod]
        public async Task Convert()
        {
            XmlDocument message = new();
            message.Load("GS1Response.xml");
            Validator validator = new();
            Response response = await validator.ConvertGs1Response(message, true);
            Assert.AreEqual("20051101", response.Id);
            Assert.AreEqual(StatusType.ERROR, response.Status, "All validations should pass");
        }
    }
}
