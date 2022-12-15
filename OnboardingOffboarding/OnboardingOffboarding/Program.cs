using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OnboardingOffboarding.Data;
using OnboardingOffboarding.Report;

namespace OnboardingOffboarding
{
    class Program
    {
        static int Main(string[] args)
        {
            try
            {
                var options = new CommandLineOptions();
                if (!CommandLine.Parser.Default.ParseArguments(args, options))
                {
                    Console.Error.WriteLine("Could not interpret command line options");
                    return 1;
                }

                // Run each operation (update, report, etc.)
                if (!options.GenerateReport && !options.UpdateDatabase)
                {
                    Console.Error.WriteLine("No operation was performed.  You must either update the database, generate a report, or both.");
                    return 2;
                }

                // update database if requested
                if (options.UpdateDatabase)
                {
                    Console.WriteLine("Updating employee/org mappings database...");
                    var updater = new DataUpdater();
                    updater.ImportEmployeeHistoryReplayData();
                    updater.ImportEmployeeSnapshotData();
                    Console.WriteLine("Updating complete.");
                }

                // generate report if requested
                if (options.GenerateReport)
                {
                    var reporter = new DataReporter();

                    DateTime defaultBeginDate = DateTime.Today.Date;
                    // Get the last batch job date as the default date if not specified for current snapshot report type
                    if (options.ReportSource == ReportSources.CurrentSnapshot)
                    {
                        var lastBatch = reporter.GetLastBatchJobDateForCurrentSnapshot();
                        if (lastBatch.HasValue)
                        {
                            defaultBeginDate = lastBatch.Value;
                        }
                    }
                    // set default report dates, if not set
                    if (options.ReportBeginDate == null)
                    {
                        options.ReportBeginDate = defaultBeginDate;
                    }
                    if (options.ReportEndDate == null)
                    {
                        options.ReportEndDate = options.ReportBeginDate.Value.AddDays(1d);
                    }

                    // Generate the report from the database
                    Console.WriteLine("Generating employee/org report from {2}, using begin date {0:MM/dd/yyyy HH:mm:ss.fff} and end date {1:MM/dd/yyyy HH:mm:ss.fff}...", options.ReportBeginDate, options.ReportEndDate, options.ReportSource);
                    EmployeeReport report;
                    switch (options.ReportSource)
                    {
                        case ReportSources.History:
                            report = reporter.GenerateReportFromReplay(options.ReportBeginDate.Value, options.ReportEndDate.Value);
                            break;
                        case ReportSources.CurrentSnapshot:
                            report = reporter.GenerateReportFromCurrentSnapshot(options.ReportBeginDate.Value, options.ReportEndDate.Value);
                            break;
                        default:
                            Console.Error.WriteLine("Invalid report source: '{0}'.  You must specify a valid report source: History, CurrentSnapshot", options.ReportSource);
                            return 3;
                    }
                    if (!string.IsNullOrWhiteSpace(report.Warnings))
                    {
                        Console.WriteLine("Warnings: \r\n{0}", report.Warnings);
                    }
                    Console.WriteLine("Report generation complete.");

                    // Write the report output
                    System.IO.TextWriter reportWriter;
                    if (options.ReportFileName == null)
                    {
                        reportWriter = Console.Out;
                    }
                    else
                    {
                        reportWriter = new System.IO.StreamWriter(new System.IO.FileStream(options.ReportFileName, System.IO.FileMode.Create, System.IO.FileAccess.Write, System.IO.FileShare.Read));
                    }
                    using (reportWriter)
                    {
                        report.WriteCSV(reportWriter);
                    }
                } // (end of report generation)

                // success
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("An unhandled error occurred: {0}", ex.ToString());
                return 255;
            }
            finally
            {
#if DEBUG
                Console.WriteLine("Press any key to continue...");
                Console.ReadKey();
#endif
            }
        }
    }
}
