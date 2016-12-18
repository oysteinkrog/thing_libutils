using System.Xml.Serialization;
using UnitsNet;

namespace generator.Threads
{
    public sealed class ThreadEntry : IObjectEntry 
    {
        public Length Size { get; set; }

        public string ThreadKey { get; set; }
        public string ThreadKeySimple { get; set; }

        public Length PitchMm { get; set; }

        // External (bolt thread)
        public string ExternalBoltClass { get; set; }
        public Length ExternalMajorDiaMax { get; set; }
        public Length ExternalMajorDiaMin { get; set; }
        public Length ExternalPitchMax { get; set; }
        public Length ExternalPitchMin { get; set; }
        public Length ExternalMinorDiaMax { get; set; }
        public Length ExternalMinorDiaMin { get; set; }

        // Internal (nut thread)
        public string InternalBoltClass { get; set; }
        public Length InternalMinorDiaMin { get; set; }
        public Length InternalMinorDiaMax { get; set; }
        public Length InternalPitchMin { get; set; }
        public Length InternalPitchMax { get; set; }
        public Length InternalMajorDiaMin { get; set; }
        public Length InternalMajorDiaMax { get; set; }

        public Length BasicTapDrill { get; set; }

        public override string ToString()
        {
            return $"Thread{ThreadKeySimple}";
        }

        [XmlIgnore]
        public string ExtraPrefix => string.Empty;

        [XmlIgnore]
        public string ExtraSuffix { get; }
    }
}