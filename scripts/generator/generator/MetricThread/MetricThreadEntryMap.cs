using CsvHelper.Configuration;

namespace generator.MetricThread
{
    internal sealed class MetricThreadEntryMap : CsvClassMap<MetricThreadEntry>
    {
        public MetricThreadEntryMap()
        {
            Map(m => m.Size)
                .Index(0).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ThreadDesignation)
                .Index(1);
            Map(m => m.ThreadDesignationSimple)
                .Index(2);

            Map(m => m.PitchMm)
                .Index(3).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.ExternalBoltClass)
                .Index(4);
            Map(m => m.ExternalMajorDiaMax)
                .Index(5).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ExternalMajorDiaMin)
                .Index(6).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ExternalPitchMax)
                .Index(7).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ExternalPitchMin)
                .Index(8).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ExternalMinorDiaMax)
                .Index(9).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.ExternalMinorDiaMin)
                .Index(10).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.InternalBoltClass)
                .Index(12);
            Map(m => m.InternalMinorDiaMin)
                .Index(13).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.InternalMinorDiaMax)
                .Index(14).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.InternalPitchMin)
                .Index(15).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.InternalPitchMax)
                .Index(16).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.InternalMajorDiaMin)
                .Index(17).TypeConverter<LengthMillimeterConverter>();
            Map(m => m.InternalMajorDiaMax)
                .Index(18).TypeConverter<LengthMillimeterConverter>();

            Map(m => m.BasicTapDrill)
                .Index(19).TypeConverter<LengthMillimeterConverter>();
        }
    }
}