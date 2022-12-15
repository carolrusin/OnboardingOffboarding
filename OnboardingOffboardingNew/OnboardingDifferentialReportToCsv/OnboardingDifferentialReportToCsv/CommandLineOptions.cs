using CommandLine;
using OnboardingDifferentialReportToCsv.Util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OnboardingDifferentialReportToCsv
{
    public class CommandLineOptions
    {
        [Option('t', "reportType", HelpText = "Type of the report (Csv)", DefaultValue = ReportTypes.Csv)]
        public ReportTypes ReportType { get; set; }

        [Option('f', "reportFile", HelpText = "Name of the report filename (if not specified, will use standard output)")]
        public string ReportFileName { get; set; }

        [Option('b', "reportBegin", HelpText = "Start date to use for the report (defaults to today's date for history, or last batch job for current snapshot)")]
        public DateTime? ReportBeginDate { get; set; }

        [Option('e', "reportEnd", HelpText = "End date to use for the report (defaults to same value as the begin date)")]
        public DateTime? ReportEndDate { get; set; }
    }
}
