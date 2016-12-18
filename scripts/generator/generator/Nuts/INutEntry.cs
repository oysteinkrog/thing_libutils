using generator.Threads;
using UnitsNet;

namespace generator.Nuts
{
    public interface INutEntry : IObjectEntry
    {
        Length HoleDia { get; }
        Length WidthMin { get; }
        Length Thickness { get; }
        Length WidthMax { get; }
        ThreadEntry Thread { get; }
        int Facets { get; }
    }
}