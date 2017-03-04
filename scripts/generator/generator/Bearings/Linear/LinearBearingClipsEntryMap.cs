using System.Globalization;
using CsvHelper.Configuration;

namespace generator.Bearings.Linear
{
    internal sealed class LinearBearingClipsEntryMap : CsvClassMap<LinearBearingEntry>
    {
        public LinearBearingClipsEntryMap()
        {
            Map(m => m.Model)
                .Index(0);
            Map(m => m.BallRows)
                .Index(1).TypeConverterOption(NumberStyles.Float);

            Map(m => m.InnerDiameter)
                .Index(2).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.OuterDiameter)
                .Index(4).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.Length)
                .Index(6).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.ClipsDistance)
                .Index(8).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ClipsGrooveDepth)
                .Index(10).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ClipsDiameter)
                .Index(11).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.Mass)
                .Index(16).TypeConverter<MassGramConverter>();
        }
    }
}