using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using CsvHelper;
using CsvHelper.Configuration;
using UnitsNet;

namespace generator.Bearings.Linear
{
    internal static class LinearBearing
    {
        public static List<LinearBearingEntry> Parse()
        {
            List<LinearBearingEntry> entries = new List<LinearBearingEntry>();

            entries.AddRange(ReadCsv<LinearBearingClipsEntryMap, LinearBearingEntry>(@"Bearings\Linear\LM.csv"));
            entries.AddRange(ReadCsv<LinearBearingClipsEntryMap, LinearBearingEntry>(@"Bearings\Linear\LME.csv"));
            entries.AddRange(ReadCsv<LinearBearingClipsEntryMap, LinearBearingEntry>(@"Bearings\Linear\LM-L.csv"));
            entries.AddRange(ReadCsv<LinearBearingFlangeRoundEntryMap, LinearBearingEntry>(@"Bearings\Linear\LMF.csv"));
            entries.AddRange(ReadCsv<LinearBearingFlangeRoundEntryMap, LinearBearingEntry>(@"Bearings\Linear\LMF-L.csv"));
            entries.AddRange(ReadCsv<LinearBearingFlangeSquareEntryMap, LinearBearingFlangeSquareEntry>(@"Bearings\Linear\LMK.csv"));
            entries.AddRange(ReadCsv<LinearBearingFlangeSquareEntryMap, LinearBearingFlangeSquareEntry>(@"Bearings\Linear\LMK-L.csv"));
            entries.AddRange(ReadCsv<LinearBearingFlangeCutEntryMap, LinearBearingFlangeCutEntry>(@"Bearings\Linear\LMH.csv"));
            entries.AddRange(ReadCsv<LinearBearingFlangeCutEntryMap, LinearBearingFlangeCutEntry>(@"Bearings\Linear\LMH-L.csv"));
            entries.AddRange(ReadCsv<LinearBearingBushingMap, LinearBearingBushing>(@"Bearings\Linear\SKF bushings.csv", 2));
            entries.AddRange(ReadCsv<LinearBearingMiniatureMap, LinearBearingMiniature>(@"Bearings\Linear\KH miniature ball bearings.csv", 1));
            return entries;
        }

        private static List<TOut> ReadCsv<TMap, TOut>(string fileName, int linesToSkipInBeginning = 0) where TMap : CsvClassMap
        {
            List<TOut> entries;
            var lines = File.ReadAllLines(fileName);
            if(linesToSkipInBeginning > 0)
            {
                lines = lines.Skip(linesToSkipInBeginning).ToArray();
            }
            var str = string.Join(Environment.NewLine, lines);

            using (MemoryStream stream = new MemoryStream())
            using (StreamWriter writer = new StreamWriter(stream))
            {
                writer.Write(str);
                writer.Flush();
                stream.Position = 0;
                using (var csv = new CsvReader(new StreamReader(stream)))
                {
                    csv.Configuration.HasHeaderRecord = false;
                    csv.Configuration.CultureInfo = new CultureInfo("nb-no");
                    csv.Configuration.RegisterClassMap<TMap>();
                    csv.Configuration.Delimiter = ";";

                    entries = csv.GetRecords<TOut>().ToList();
                }
            }
            return entries;
        }

        public static void Generate(List<LinearBearingEntry> entries )
        {
            var output = new StringBuilder();
            GenerationCommon.AppendHeader(output, new List<string> {"units.scad"});

            GenerationCommon.GenerateScadLib("LinearBearing", entries, v => v.Model, output);

            File.WriteAllText("bearing-linear-data.scad", output.ToString());
        }
    }
}