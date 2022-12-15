using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CommandLine;
using CommandLine.Text;
using OnboardingOffboarding.Report;

namespace OnboardingOffboarding
{
    public class CommandLineOptions
    {

        [Option('r', "report", HelpText = "Generate an employee change report", DefaultValue = false)]
        public bool GenerateReport { get; set; }

        [Option('s', "reportSource", HelpText = "Source of the report (History, CurrentSnapshot)", DefaultValue = ReportSources.History)]
        public ReportSources ReportSource { get; set; }

        [Option('t', "reportType", HelpText = "Type of the report (Csv)", DefaultValue = ReportTypes.Csv)]
        public ReportTypes ReportType { get; set; }

        [Option('f', "reportFile", HelpText = "Name of the report filename (if not specified, will use standard output)")]
        public string ReportFileName { get; set; }

        [Option('b', "reportBegin", HelpText = "Start date to use for the report (defaults to today's date for history, or last batch job for current snapshot)")]
        public DateTime? ReportBeginDate { get; set; }

        [Option('e', "reportEnd", HelpText = "End date to use for the report (defaults to same value as the begin date)")]
        public DateTime? ReportEndDate { get; set; }

        [Option('u', "update", HelpText = "Update the database by pulling new/changed data from CentralDataFeed", DefaultValue = false)]
        public bool UpdateDatabase { get; set; }

        [HelpOption]
        public string GetUsage()
        {
            var help = HelpText.AutoBuild(this, (HelpText current) => HelpText.DefaultParsingErrorsHandler(this, current));
            help.Heading = "Onboarding/Offboarding Updater and Report Generator Tool v" + System.Reflection.Assembly.GetEntryAssembly().GetName().Version;
            return help;
        }
        
    }
}
