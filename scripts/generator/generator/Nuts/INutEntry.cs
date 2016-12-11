using generator.Threads;
using UnitsNet;

namespace generator.Nuts
{
    public interface INutEntry : IObjectEntry
    {
        Length HoleDia { get; set; }
        Length WidthMin { get; set; }
        Length Thickness { get; set; }
        Length WidthMax { get; set; }
        ThreadEntry Thread { get; set; }
        int Facets { get; }
    }
}