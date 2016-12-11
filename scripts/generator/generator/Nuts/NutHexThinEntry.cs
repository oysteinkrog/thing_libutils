using System.Xml.Serialization;

namespace generator.Nuts
{
    public sealed class NutHexThinEntry : NutHexEntry
    {
        [XmlIgnore]
        public override string ExtraPrefix => "HexThin";
    }
}