using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using CsvHelper;

namespace generator.MetricThread
{
    internal static class MetricThread
    {
        public static List<MetricThreadEntry> Generate()
        {
            var output = new StringBuilder();
            GenerationCommon.AppendHeader(output, new List<string> {"units.scad"});
            List<MetricThreadEntry> entries;

            using (var file = File.OpenText(@"MetricThread\iso261-extended-MetricThread.csv"))
            {
                // skip two header lines
                file.ReadLine();
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap<MetricThreadEntryMap>();

                    entries = csv.GetRecords<MetricThreadEntry>().ToList();

                    GenerationCommon.GenerateScadLib("", entries, v => v.ThreadKeySimple, output);
                }
            }
            File.WriteAllText("metric-thread.scad", output.ToString());
            return entries;
        }
    }
}