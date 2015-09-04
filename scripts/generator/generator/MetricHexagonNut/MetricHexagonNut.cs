using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using CsvHelper;
using generator.MetricThread;

namespace generator.MetricHexagonNut
{
    internal static class MetricHexagonNut
    {
        public static void GenerateHexagonNut(List<MetricThreadEntry> metricThreadEntries)
        {
            var output = new StringBuilder();
            GenerationCommon.AppendHeader(output, new List<string> {"units.scad", "metric-thread.scad"});

            using (var file = File.OpenText(@"MetricHexagonNut\iso4032-MetricHexagonNut.csv"))
            {
                // skip header
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap(new MetricHexagonNutEntryMap(metricThreadEntries));

                    var entries = new List<MetricHexagonNutEntry>();
                    while (csv.Read())
                    {
                        try
                        {
                            var entry = csv.GetRecord<MetricHexagonNutEntry>();
                            entries.Add(entry);
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine(e);
                        }
                    }

                    GenerationCommon.GenerateScadLib("MHexNut", entries, v => v.Thread.ThreadKeySimple.ToString(), output);
                }
            }
            using (var file = File.OpenText(@"MetricHexagonNut\iso4035-MetricHexagonThinNut.csv"))
            {
                // skip header
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap(new MetricHexagonNutEntryMap(metricThreadEntries));

                    var entries = new List<MetricHexagonNutEntry>();
                    while (csv.Read())
                    {
                        try
                        {
                            var entry = csv.GetRecord<MetricHexagonNutEntry>();
                            entries.Add(entry);
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine(e);
                        }
                    }

                    GenerationCommon.GenerateScadLib("MHexThinNut", entries, v => v.Thread.ToString(),
                        output);
                }
            }

            File.WriteAllText("metric-hexnut.scad", output.ToString());
        }
    }
}