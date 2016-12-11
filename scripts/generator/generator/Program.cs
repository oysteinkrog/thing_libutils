using generator.Nuts;
using generator.Threads;

namespace generator
{
    internal static class Program
    {
        private static void Main(string[] args)
        {
            var threads = ThreadMetric.Parse();
            ThreadMetric.Generate(threads);
            var nuts = NutMetricHex.Parse(threads);
            NutMetricHex.Generate(nuts);
        }
    }
}