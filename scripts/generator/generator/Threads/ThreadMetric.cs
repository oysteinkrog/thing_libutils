using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using CsvHelper;

namespace generator.Threads
{
    internal static class ThreadMetric
    {
        public static List<ThreadEntry> Parse()
        {
            List<ThreadEntry> entries;

            using (var file = File.OpenText(@"Threads\iso261-ThreadMetric-extended.csv"))
            {
                // skip two header lines
                file.ReadLine();
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap<ThreadMetricEntryMap>();

                    entries = csv.GetRecords<ThreadEntry>().ToList();
                }
            }
            return entries;
        }

        public static void Generate(List<ThreadEntry> entries)
        {
            var output = new StringBuilder();
            GenerationCommon.AppendHeader(output, new List<string> {"units.scad"});

            GenerationCommon.GenerateScadLib("Thread", entries, v => v.KeySimple, output);

            File.WriteAllText("thread-data.scad", output.ToString());
        }
    }
}