using System.Xml.Serialization;
using generator.Threads;
using UnitsNet;

namespace generator.Nuts
{
    public class NutHexEntry : INutEntry
    {
        public Length HoleDia { get; set; }
        public Length WidthMin { get; set; }
        public Length Thickness { get; set; }
        public Length WidthMax { get; set; }

        public ThreadEntry Thread { get; set; }

        public int Facets => 6;

        [XmlIgnore]
        public virtual string ExtraPrefix => "Hex";

        [XmlIgnore]
        public string ExtraSuffix { get; }
    }
}