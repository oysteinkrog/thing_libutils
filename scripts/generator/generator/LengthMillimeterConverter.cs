using System;
using System.Globalization;
using CsvHelper.TypeConversion;
using UnitsNet;

namespace generator
{
    /// <summary>
    ///     Converts a Double to and from a string.
    /// </summary>
    internal class LengthMillimeterConverter : DefaultTypeConverter
    {
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
            double result;
            if (Double.TryParse(text, style, options.CultureInfo, out result))
                return Length.FromMillimeters(result);
            return base.ConvertFromString(options, text);
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