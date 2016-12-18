using System.Globalization;
using System.Xml.Serialization;
using generator.Threads;
using UnitsNet;

namespace generator.Nuts
{
    public class NutKnurlEntry : INutEntry
    {

        public Length HoleDia { get; set; }
        public Length WidthMin => WidthNom - Length.FromMillimeters(.1);
        public Length Thickness { get; set; }
        public Length WidthMax => WidthNom - Length.FromMillimeters(.1);

        public ThreadEntry Thread { get; set; }

        public int Facets => 20;

        public Length WidthNom { get; set; }

        [XmlIgnore]
        public virtual string ExtraSuffix
            =>
                $"_{Thickness.Millimeters.ToString(CultureInfo.InvariantCulture)}_{(10*WidthNom.Millimeters).ToString(CultureInfo.InvariantCulture)}"
        ;

        [XmlIgnore]
        public virtual string ExtraPrefix => "Knurl";
    }
}