using System.Collections.Generic;
using System.IO;
using System.Text;
using generator.Threads;
using UnitsNet;

namespace generator.Nuts
{
    internal static class NutMetricKnurl
    {
        public static List<INutEntry> Parse(List<ThreadEntry> metricThreadEntries)
        {
            var threadM3 = metricThreadEntries.Find(v => v.ThreadKey == "M3");
            var entries = new List<INutEntry>
            {
                new NutKnurlEntry
                {
                    HoleDia = Length.FromMillimeters(3),
                    Thickness = Length.FromMillimeters(5),
                    Thread = threadM3,
                    WidthMin = Length.FromMillimeters(4.2-.1),
                    WidthMax = Length.FromMillimeters(4.2-.1)
                },
                new NutKnurlEntry
                {
                    HoleDia = Length.FromMillimeters(3),
                    Thickness = Length.FromMillimeters(3),
                    Thread = threadM3,
                    WidthMin = Length.FromMillimeters(4.2-.1),
                    WidthMax = Length.FromMillimeters(4.2-.1)
                }
            };
            return entries;
        }

        public static void Generate(List<INutEntry> nuts)
        {
            var output = new StringBuilder();

            GenerationCommon.AppendHeader(output, new List<string> {"units.scad", "thread-data.scad"});

            GenerationCommon.GenerateScadLib("Nut", nuts, v => v.Thread.ThreadKeySimple.ToString(), output);

            File.WriteAllText("nut-knurln-data.scad", output.ToString());
        }
    }
}