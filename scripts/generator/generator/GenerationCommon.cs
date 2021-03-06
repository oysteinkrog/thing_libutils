using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml.Serialization;
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
            StringBuilder stringBuilder) where T : IObjectEntry
        {
            if (prefix == null) throw new ArgumentNullException(nameof(prefix));
            var properties = typeof (T).GetProperties();
            // filter out properties decorated with XmlIgnore
            properties = properties.Where(v => !Attribute.IsDefined(v, typeof(XmlIgnoreAttribute))).ToArray();

            for (var index = 0; index < properties.Length; index++)
            {
                var propertyInfo = properties[index];
                stringBuilder.AppendLine(string.Format(CultureInfo.InvariantCulture, "{0}{1} = {2};",
                    prefix, propertyInfo.Name, index));
            }
            stringBuilder.AppendLine();
            foreach (var entry in entries)
            {
                var entryName = $"{prefix}{entry.ExtraPrefix}{keyName(entry)}{entry.ExtraSuffix}";
                entryName = SanitizeOpenScadVariableName(entryName);
                AppendTable(prefix, stringBuilder, entryName, properties, entry);
                stringBuilder.AppendLine();
            }

            stringBuilder.Append($"All{prefix} = [");
            foreach (var entry in entries)
            {
                var entryName = $"{prefix}{entry.ExtraPrefix}{keyName(entry)}{entry.ExtraSuffix}";
                entryName = SanitizeOpenScadVariableName(entryName);
                stringBuilder.AppendLine(entryName+",");
            }
            stringBuilder.Append("];");

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
            else if (value is Mass)
            {
                stringValue = string.Format(CultureInfo.InvariantCulture, "{0}*g", ((Mass) value).Grams);
            }
            else if (value is string)
            {
                stringValue = $"\"{((string)value).Trim()}\"";
            }
            else if (value is null)
            {
                stringValue = "undef";
            }
            else
            {
                stringValue = SanitizeOpenScadVariableName($"{value}");
            }
            return stringValue;
        }
    }
}