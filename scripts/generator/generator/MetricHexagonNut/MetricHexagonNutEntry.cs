using generator.MetricThread;
using UnitsNet;

namespace generator.MetricHexagonNut
{
    public sealed class MetricHexagonNutEntry
    {
        public Length HoleDia { get; set; }
        public Length WidthMin { get; set; }
        public Length Thickness { get; set; }
        public Length WidthMax { get; set; }

        public MetricThreadEntry Thread { get; set; }

        public int Facets => 6;
    }
}