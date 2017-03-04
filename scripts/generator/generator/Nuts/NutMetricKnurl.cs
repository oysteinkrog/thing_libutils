using System.Collections.Generic;
using generator.Threads;
using UnitsNet;

namespace generator.Nuts
{
    internal static class NutMetricKnurl
    {
        public static List<INutEntry> Parse(List<ThreadEntry> metricThreadEntries)
        {
            var threadM3 = metricThreadEntries.Find(v => v.KeySimple == "M3");
            var entries = new List<INutEntry>
            {
                new NutKnurlEntry
                {
                    HoleDia = Length.FromMillimeters(3),
                    Thickness = Length.FromMillimeters(5),
                    Thread = threadM3,
                    WidthNom = Length.FromMillimeters(4.2),
                },
                new NutKnurlEntry
                {
                    HoleDia = Length.FromMillimeters(3),
                    Thickness = Length.FromMillimeters(3),
                    Thread = threadM3,
                    WidthNom = Length.FromMillimeters(4.2),
                }
            };
            return entries;
        }
    }
}