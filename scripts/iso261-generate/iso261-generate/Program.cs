using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using CsvHelper;
using UnitsNet;

namespace iso261_generate
{
    internal static class Program
    {
        private static void Main(string[] args)
        {
            using (var file = File.OpenText("iso261-extended-MetricThread.csv"))
            {
                // skip two header lines
                file.ReadLine();
                file.ReadLine();
                using (var csv = new CsvReader(file))
                {
                    csv.Configuration.HasHeaderRecord = true;
                    csv.Configuration.CultureInfo = CultureInfo.InvariantCulture;
                    csv.Configuration.RegisterClassMap<MetricEntryMap>();

                    var entries = csv.GetRecords<MetricEntry>();

                    var output = new StringBuilder();
                    GenerateScadLib(entries, output);

                    File.WriteAllText("metric-thread.scad", output.ToString());
                }
            }
        }

        private static void GenerateScadLib(IEnumerable<MetricEntry> entries, StringBuilder stringBuilder)
        {
            stringBuilder.AppendLine("// THIS FILE HAS BEEN GENERATED (by iso261-generate)");
            stringBuilder.AppendLine("// DO NOT MODIFY DIRECTLY");
            stringBuilder.AppendLine();
            stringBuilder.AppendLine("include <units.scad>");
            stringBuilder.AppendLine();
            var properties = typeof (MetricEntry).GetProperties();

            for (int index = 0; index < properties.Length; index++)
            {
                var propertyInfo = properties[index];
                stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "Metric{0} = {1};", propertyInfo.Name, index));
            }
            stringBuilder.AppendLine();
            foreach (var metricEntry in entries)
            {
                var entryName = metricEntry.ThreadDesignationSimple;
                entryName = entryName.Replace(".", "_");
                stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "{0} = ", entryName));
                stringBuilder.AppendLine("[");
                for (int index = 0; index < properties.Length; index++)
                {
                    var propertyInfo = properties[index];
                    var stringValue = GetFormattedValue(propertyInfo, metricEntry);
                    stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "[{0}, {1}],", propertyInfo.Name, stringValue));
                }
                stringBuilder.AppendLine("];");
                stringBuilder.AppendLine();
            }
        }

        private static string GetFormattedValue(PropertyInfo propertyInfo, MetricEntry metricEntry)
        {
            string stringValue;
            var value = propertyInfo.GetValue(metricEntry);
            if (value is Length)
            {
                stringValue = string.Format(CultureInfo.InvariantCulture, "{0}*mm", ((Length) value).Millimeters);
            }
            else
            {
                stringValue = $"\"{value}\"";
            }
            return stringValue;
        }
    }
}
