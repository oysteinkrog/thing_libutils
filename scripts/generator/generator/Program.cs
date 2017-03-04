using System.Linq;
using generator.Bearings.Linear;
using generator.Nuts;
using generator.Threads;

namespace generator
{
    internal static class Program
    {
        private static void Main(string[] args)
        {
            LinearBearing.Generate(LinearBearing.Parse());

//            var threads = ThreadMetric.Parse();
//            ThreadMetric.Generate(threads);
//            var nuts = NutMetricHex.Parse(threads);
//            var knurlNuts = NutMetricKnurl.Parse(threads);
//            NutMetricHex.Generate(nuts.Concat(knurlNuts).ToList());
        }
    }
}