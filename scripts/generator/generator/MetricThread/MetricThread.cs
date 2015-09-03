using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text;
using CsvHelper;
using UnitsNet;

namespace generator
{
    internal class MetricThread
    {
        private static void GenerateScadLib(IEnumerable<MetricThreadEntry> entries, StringBuilder stringBuilder)
        {
            stringBuilder.AppendLine("// THIS FILE HAS BEEN GENERATED");
            stringBuilder.AppendLine("// DO NOT MODIFY DIRECTLY");
            stringBuilder.AppendLine();
            stringBuilder.AppendLine("include <units.scad>");
            stringBuilder.AppendLine();
            var properties = typeof (MetricThreadEntry).GetProperties();

            for (var index = 0; index < properties.Length; index++)
            {
                var propertyInfo = properties[index];
                stringBuilder.AppendLine(String.Format(CultureInfo.InvariantCulture, "Metric{0} = {1};",
                    propertyInfo.Name, index));
            }
            stringBuilder.AppendLine();
            foreach (var metricEntry in entries)
            {
                var entryName = metricEntry.ThreadDesignationSimple;
                entryName = entryName.Replace(".", "_");
                stringBuilder.AppendLine(String.Format(CultureInfo.InvariantCulture, "{0} = ", entryName));
                stringBuilder.AppendLine("[");
                for (var index = 0; index < properties.Length; index++)
                {
                    var propertyInfo = properties[index];
                    var stringValue = GetFormattedValue(propertyInfo, metricEntry);
                    stringBuilder.AppendLine(String.Format(CultureInfo.InvariantCulture, "[{0}, {1}],",
                        propertyInfo.Name, stringValue));
                }
                stringBuilder.AppendLine("];");
                stringBuilder.AppendLine();
            }
        }

        private static string GetFormattedValue(PropertyInfo propertyInfo, MetricThreadEntry metricThreadEntry)
        {
            string stringValue;
            var value = propertyInfo.GetValue(metricThreadEntry);
            if (value is Length)
            {
                stringValue = String.Format(CultureInfo.InvariantCulture, "{0}*mm", ((Length) value).Millimeters);
            }
            else
            {
                stringValue = $"\"{value}\"";
            }
            return stringValue;
        }

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
                    GenerateScadLib(entries, output);

                    File.WriteAllText("metric-thread.scad", output.ToString());
                }
            }
        }
    }
}