namespace generator
{
    internal static class Program
    {
        private static void Main(string[] args)
        {
            var metricThreadEntries = MetricThread.MetricThread.Generate();
            MetricHexagonNut.MetricHexagonNut.GenerateHexagonNut(metricThreadEntries);
        }
    }
}