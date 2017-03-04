using System;
using System.Globalization;
using CsvHelper.TypeConversion;
using UnitsNet;

namespace generator
{
    /// <summary>
    ///     Converts a Double to and from a string.
    /// </summary>
    internal sealed class MountHoleConverter : DefaultTypeConverter
    {
        private readonly int _index;

        public MountHoleConverter(int index)
        {
            _index = index;
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
            var numberStyle = options.NumberStyle;
            var style = numberStyle.HasValue ? numberStyle.GetValueOrDefault() : NumberStyles.Float;
            text = text.Split('�')[_index];
            if (double.TryParse(text, style, options.CultureInfo, out double result))
                return Length.FromMillimeters(result);
            try
            {
                return base.ConvertFromString(options, text);
            }
            catch (Exception)
            {
                return null;
            }
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