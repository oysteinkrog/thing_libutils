using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using CsvHelper;
using generator.Threads;

namespace generator.Nuts
{
    internal static class NutMetricHex
    {
        public static List<INutEntry> Parse(List<ThreadEntry> metricThreadEntries)
        {
            var entries = new List<INutEntry>();

            using (var file = File.OpenText(@"NutMetricHex\iso4032-NutMetricHex.csv"))
            {
                // skip header
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap(new NutMetricHexEntryMap(metricThreadEntries));

                    while (csv.Read())
                    {
                        try
                        {
                            var entry = csv.GetRecord<NutHexEntry>();
                            entries.Add(entry);
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine(e);
                        }
                    }
                }
            }

            using (var file = File.OpenText(@"NutMetricHex\iso4035-NutMetricHexThin.csv"))
            {
                // skip header
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap(new NutMetricHexEntryMap(metricThreadEntries));

                    while (csv.Read())
                    {
                        try
                        {
                            var entry = csv.GetRecord<NutHexThinEntry>();
                            entries.Add(entry);
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine(e);
                        }
                    }
                }
            }
            return entries;
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
