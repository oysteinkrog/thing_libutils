using System;
using System.Collections.Generic;
using System.Globalization;
using System.Reflection;
using System.Text;
using UnitsNet;

namespace generator
{
    internal static class GenerationCommon
    {
        public static void AppendHeaderGeneratedWarning(StringBuilder stringBuilder)
        {
            stringBuilder.AppendLine("// THIS FILE HAS BEEN GENERATED");
            stringBuilder.AppendLine("// DO NOT MODIFY DIRECTLY");
            stringBuilder.AppendLine();
        }

        public static void GenerateScadLib<T>(string prefix, IEnumerable<T> entries, Func<T, string> keyName,
            StringBuilder stringBuilder, IEnumerable<string> filesToInclude)
        {
            if (prefix == null) throw new ArgumentNullException(nameof(prefix));
            AppendHeaderGeneratedWarning(stringBuilder);
            foreach (var file in filesToInclude)
            {
                stringBuilder.AppendLine($"include <{file}>");
            }
            stringBuilder.AppendLine();
            var properties = typeof (T).GetProperties();

            for (var index = 0; index < properties.Length; index++)
            {
                var propertyInfo = properties[index];
                stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "{0}{1} = {2};",
                    prefix, propertyInfo.Name, index));
            }
            stringBuilder.AppendLine();
            foreach (var entry in entries)
            {
                var entryName = keyName(entry);
                entryName = entryName.Replace(".", "_");
                AppendTable(stringBuilder, entryName, properties, entry);
                stringBuilder.AppendLine();
            }
        }

        private static void AppendTable<T>(StringBuilder stringBuilder, string entryName, PropertyInfo[] properties,
            T metricEntry)
        {
            stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "{0} = ", entryName));
            AppendTableData(stringBuilder, properties, metricEntry);
        }

        private static void AppendTableData<T>(StringBuilder stringBuilder, PropertyInfo[] properties, T metricEntry)
        {
            stringBuilder.AppendLine("[");
            for (var index = 0; index < properties.Length; index++)
            {
                AppendTableEntry(stringBuilder, properties, index, metricEntry);
            }
            stringBuilder.AppendLine("];");
        }

        private static void AppendTableEntry<T>(StringBuilder stringBuilder, PropertyInfo[] properties, int index,
            T metricEntry)
        {
            var propertyInfo = properties[index];
            var stringValue = GetFormattedValue(propertyInfo, metricEntry);
            stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "[{0}, {1}],",
                propertyInfo.Name, stringValue));
        }

        private static string GetFormattedValue(PropertyInfo propertyInfo, object tableEntry)
        {
            string stringValue;
            var value = propertyInfo.GetValue(tableEntry);
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