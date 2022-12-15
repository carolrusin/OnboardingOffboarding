using OnboardingDifferentialReportToCsv.DB;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using OnboardingDifferentialReportToCsv.Util;
using System.IO;

namespace OnboardingDifferentialReportToCsv
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
                string DirName = Path.GetDirectoryName(options.ReportFileName + options.ReportType);
                if (!Directory.Exists(DirName))
                {
                    Console.Error.WriteLine("Incorrect file path");
                    return 1;
                }
                using (var ctx = new OnboardingOffboardingEntities())
                {
                    using (System.IO.TextWriter reportWriter = new System.IO.StreamWriter(new System.IO.FileStream(options.ReportFileName + options.ReportType,
                                                                                            System.IO.FileMode.Create,
                                                                                            System.IO.FileAccess.Write,
                                                                                            System.IO.FileShare.Read))
                          )
                    {
                        //ctx.PROC_EmployeeDeptDifferential(StartDate, EndDate).ToList().WriteCSV(reportWriter, true, true);
                        ctx.PROC_EmployeeDeptDifferential(options.ReportBeginDate, options.ReportEndDate).ToList().WriteCSV(reportWriter, true, true);
                        var lineCount = File.ReadLines(options.ReportFileName + options.ReportType).Count();
                        if (lineCount == 1)
                        {
                            Console.Error.WriteLine("Incorrect file path");
                            return 2;
                        }
                    }
                }
                //Console.WriteLine("All done successfully. Press any key to exit");
                //Console.ReadKey();
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("An unhandled error occurred: {0}", ex.ToString());
                return 255;
            }
        }




    }
}
