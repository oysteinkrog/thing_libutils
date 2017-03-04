using System.Globalization;
using CsvHelper.Configuration;

namespace generator.Bearings.Linear
{
    internal sealed class LinearBearingFlangeCutEntryMap : CsvClassMap<LinearBearingEntry>
    {
        public LinearBearingFlangeCutEntryMap()
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

            Map(m => m.FlangeDiameter)
                .Index(8).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.FlangeCutDiameter)
                .Index(10).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.FlangeThickness)
                .Index(11).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.FlangeCutMountHoleDist)
                .Index(12).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.FlangeCutMountHoleDistSide)
                .Index(13).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.FlangeMountingSize)
                .TypeConverter(new MountHoleConverter(0)).TypeConverterOption(CultureInfo.InvariantCulture).Index(14);
            Map(m => m.FlangeMountingHeadSize)
                .TypeConverter(new MountHoleConverter(1)).TypeConverterOption(CultureInfo.InvariantCulture).Index(14);
            Map(m => m.FlangeMountingHeadDepth)
                .TypeConverter(new MountHoleConverter(2)).TypeConverterOption(CultureInfo.InvariantCulture).Index(14);

            Map(m => m.Mass)
                .Index(18).TypeConverter<MassGramConverter>();
        }
    }
}