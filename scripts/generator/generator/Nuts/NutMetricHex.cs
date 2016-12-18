using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using CsvHelper;
using CsvHelper.Configuration;
using generator.Threads;

namespace generator.Nuts
{
    internal static class NutMetricHex
    {
        public static List<INutEntry> Parse(List<ThreadEntry> metricThreadEntries)
        {
            var entries = new List<INutEntry>();

            entries.AddRange(ParseNutsFromData<NutHexEntry>(@"Nuts\iso4032-NutMetricHex.csv",
                new NutMetricHexEntryMap(metricThreadEntries)));

            entries.AddRange(ParseNutsFromData<NutHexThinEntry>(@"Nuts\iso4035-NutMetricHexThin.csv",
                new NutMetricHexEntryMap(metricThreadEntries)));

            return entries;
        }

        private static IEnumerable<T> ParseNutsFromData<T>(string filePath, CsvClassMap classMap) where T : class, INutEntry 
        {
            using (var file = File.OpenText(filePath))
            {
                // skip header
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap(classMap);

                    while (csv.Read())
                    {
                        T entry = null;
                        try
                        {
                            entry = csv.GetRecord<T>();
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine(e);
                        }
                        if(entry != null)
                        {
                            yield return entry;
                        }
                    }
                }
            }
        }

        public static void Generate(List<INutEntry> nuts)
        {
            var output = new StringBuilder();

            GenerationCommon.AppendHeader(output, new List<string> {"units.scad", "thread-data.scad"});

            GenerationCommon.GenerateScadLib("Nut", nuts, v => v.Thread.ThreadKeySimple.ToString(), output);

            File.WriteAllText("nut-data.scad", output.ToString());
        }
    }
}
