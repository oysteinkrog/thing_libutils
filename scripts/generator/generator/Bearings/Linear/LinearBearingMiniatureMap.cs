using System.Globalization;
using CsvHelper.Configuration;

namespace generator.Bearings.Linear
{
    internal sealed class LinearBearingMiniatureMap : CsvClassMap<LinearBearingEntry>
    {
        public LinearBearingMiniatureMap()
        {
            Map(m => m.Model).Index(0);

            Map(m => m.InnerDiameter)
                .Index(1).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.OuterDiameter)
                .Index(2).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.Length)
                .Index(3).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.Mass)
                .Index(6).TypeConverter<MassGramConverter>().TypeConverterOption(CultureInfo.InvariantCulture);
        }
    }
}