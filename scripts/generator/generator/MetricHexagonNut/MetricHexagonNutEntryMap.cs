using System;
using System.Collections.Generic;
using CsvHelper.Configuration;
using CsvHelper.TypeConversion;
using generator.MetricThread;

namespace generator.MetricHexagonNut
{
    internal sealed class MetricHexagonNutEntryMap : CsvClassMap<MetricHexagonNutEntry>
    {
        private readonly List<MetricThreadEntry> _metricThreadEntries;

        public MetricHexagonNutEntryMap(List<MetricThreadEntry> metricThreadEntries)
        {
            _metricThreadEntries = metricThreadEntries;

            Map(m => m.Thread)
                .Index(0).TypeConverter(new LookupMetricThreadConverter(metricThreadEntries));

            Map(m => m.HoleDia)
                .Index(2).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.WidthMin)
                .Index(3).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.Thickness)
                .Index(3).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.WidthMax)
                .Index(4).TypeConverter<LengthMillimeterConverter>();
        }

        internal class LookupMetricThreadConverter : DefaultTypeConverter
        {
            private readonly List<MetricThreadEntry> _metricThreadEntries;

            public LookupMetricThreadConverter(List<MetricThreadEntry> metricThreadEntries)
            {
                _metricThreadEntries = metricThreadEntries;
            }

            /// <summary>
            ///     Converts the string to an object.
            /// </summary>
            /// <param name="options">The options to use when converting.</param>
            /// <param name="text">The string to convert to an object.</param>
            /// <returns>
            ///     The object created from the string.
            /// </returns>
            public override object ConvertFromString(TypeConverterOptions options, string text)
            {
                MetricThreadEntry metricThreadEntry =
                    _metricThreadEntries.Find(
                        v => v.ThreadKeySimple.Trim().Equals(text.Trim(), StringComparison.InvariantCultureIgnoreCase));
                if (metricThreadEntry != null)
                {
                    return metricThreadEntry;
                }
                return text;
            }

            /// <summary>
            ///     Determines whether this instance [can convert from] the specified type.
            /// </summary>
            /// <param name="type">The type.</param>
            /// <returns>
            ///     <c>true</c> if this instance [can convert from] the specified type; otherwise, <c>false</c>.
            /// </returns>
            public override bool CanConvertFrom(Type type)
            {
                return type == typeof (string);
            }
        }
    }
}