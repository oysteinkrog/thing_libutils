using System.Xml.Serialization;
using UnitsNet;

namespace generator.Bearings.Linear
{
    public sealed class LinearBearingClipsEntry : LinearBearingEntry
    {
    }

    public sealed class LinearBearingFlangeRoundEntry : LinearBearingEntry
    {
    }

    public sealed class LinearBearingFlangeSquareEntry : LinearBearingEntry
    {
    }

    public sealed class LinearBearingFlangeCutEntry : LinearBearingEntry
    {
    }

    public sealed class LinearBearingBushing : LinearBearingEntry
    {
    }

    public class LinearBearingEntry : IObjectEntry
    {
        public string Model { get; set; }
        public int BallRows { get; set; }

        public Length InnerDiameter { get; set; }
//        public string InscribedBoreDiameterTolerance { get; set; }

        public Length OuterDiameter { get; set; }
//        public string OuterDiameterTolerance { get; set; }

        public Length Length { get; set; }
//        public string LengthTolerance { get; set; }

        public Length? ClipsDistance { get; set; }
        public Length? ClipsGrooveDepth { get; set; }
        public Length? ClipsDiameter { get; set; }

        public Length? FlangeDiameter { get; set; }
        public Length? FlangeSide { get; set; }
        public Length? FlangeThickness { get; set; }
        public Length? FlangePitchCircleDiameter { get; set; }

        public Length? FlangeCutDiameter { get; set; }
        public Length? FlangeCutMountHoleDist { get; set; }
        public Length? FlangeCutMountHoleDistSide { get; set; }

        public Mass Mass { get; set; }

        public override string ToString()
        {
            return $"{Model}";
        }

        [XmlIgnore]
        public virtual string ExtraPrefix => string.Empty;

        [XmlIgnore]
        public string ExtraSuffix { get; }

        public Length FlangeMountingSize { get; set; }
        public Length FlangeMountingHeadSize { get; set; }
        public Length FlangeMountingHeadDepth { get; set; }
    }
}