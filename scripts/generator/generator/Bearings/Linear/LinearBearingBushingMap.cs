using System.Globalization;
using CsvHelper.Configuration;

namespace generator.Bearings.Linear
{
    internal sealed class LinearBearingBushingMap : CsvClassMap<LinearBearingEntry>
    {
        public LinearBearingBushingMap()
        {
            Map(m => m.Model).ConvertUsing(v => v.CurrentRecord[0] + v.CurrentRecord[1]);

            Map(m => m.InnerDiameter)
                .Index(3).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.OuterDiameter)
                .Index(4).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.Length)
                .Index(5).TypeConverter<LengthMillimeterConverter>();
        }
    }
}