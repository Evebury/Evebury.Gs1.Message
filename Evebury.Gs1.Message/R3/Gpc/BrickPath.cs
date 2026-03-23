namespace Evebury.Gs1.Message.R3.Gpc
{
    internal struct BrickPath(string segment, string family, string @class)
    {
        public string Segment { get; set; } = segment;

        public string Family { get; set; } = family;

        public string Class { get; set; } = @class;
    }
}
