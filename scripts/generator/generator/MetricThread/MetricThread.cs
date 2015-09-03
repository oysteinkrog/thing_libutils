using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using CsvHelper;

namespace generator.MetricThread
{
    internal static class MetricThread
    {
        public static void Generate()
        {
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

                    var entries = csv.GetRecords<MetricThreadEntry>();

                    var output = new StringBuilder();
                    GenerationCommon.GenerateScadLib("MetricThread", entries, v => v.ThreadDesignationSimple, output,
                        new List<string> {"units.scad"});

                    File.WriteAllText("metric-thread.scad", output.ToString());
                }
            }
        }
    }
}