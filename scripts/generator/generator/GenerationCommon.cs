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
        public static void AppendHeader(StringBuilder stringBuilder, IEnumerable<string> filesToInclude)
        {
            AppendHeaderGeneratedWarning(stringBuilder);

            foreach (var file in filesToInclude)
            {
                stringBuilder.AppendLine($"include <{file}>");
            }
            stringBuilder.AppendLine();
        }

        public static void AppendHeaderGeneratedWarning(StringBuilder stringBuilder)
        {
            stringBuilder.AppendLine("// THIS FILE HAS BEEN GENERATED");
            stringBuilder.AppendLine("// DO NOT MODIFY DIRECTLY");
            stringBuilder.AppendLine();
        }

        public static void GenerateScadLib<T>(string prefix, List<T> entries, Func<T, string> keyName,
            StringBuilder stringBuilder)
        {
            if (prefix == null) throw new ArgumentNullException(nameof(prefix));
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
                var entryName = $"{prefix}{keyName(entry)}";
                entryName = SanitizeOpenScadVariableName(entryName);
                AppendTable(prefix, stringBuilder, entryName, properties, entry);
                stringBuilder.AppendLine();
            }
        }

        private static string SanitizeOpenScadVariableName(string entryName)
        {
            return entryName.Replace(".", "_");
        }

        private static void AppendTable<T>(string prefix, StringBuilder stringBuilder, string entryName, PropertyInfo[] properties, T metricEntry)
        {
            stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "{0} = [", entryName));
            for (var index = 0; index < properties.Length; index++)
            {
                stringBuilder.Append("    ");
                AppendTableEntry(prefix, stringBuilder, properties, index, metricEntry);
            }
            stringBuilder.AppendLine("];");
        }

        private static void AppendTableEntry<T>(string prefix, StringBuilder stringBuilder, PropertyInfo[] properties, int index, T metricEntry)
        {
            var propertyInfo = properties[index];
            var stringValue = GetFormattedValue(propertyInfo, metricEntry);
            stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "[{0}{1}, {2}],",
                prefix, propertyInfo.Name, stringValue));
        }

        private static string GetFormattedValue(PropertyInfo propertyInfo, object tableEntry)
        {
            string stringValue;
            var value = propertyInfo.GetValue(tableEntry);
            if (value is Length)
            {
                stringValue = string.Format(CultureInfo.InvariantCulture, "{0}*mm", ((Length) value).Millimeters);
            }
            else if (value is string)
            {
                stringValue = $"\"{((string)value).Trim()}\"";
            }
            else
            {
                stringValue = SanitizeOpenScadVariableName($"{value}");
            }
            return stringValue;
        }
    }
}