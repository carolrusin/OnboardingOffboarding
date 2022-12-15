using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OnboardingOffboarding.Data;

namespace OnboardingOffboarding.Report
{
    public class DataReporter
    {
        /// <summary>
        /// Using the EmployeeOrgReplay (Employee History) data, for a given date range, show the differences in organizational structure between the first date and last date
        /// </summary>
        /// <param name="rangeBeginDate">Start date for the report</param>
        /// <param name="rangeEndDate">End date for the report</param>
        public EmployeeReport GenerateReportFromReplay(DateTime rangeBeginDate, DateTime rangeEndDate)
        {
            using (var db = new OnboardingOffboardingDataContext())
            {
                // Load joined Employee data with queries for EmployeeOrgReplay (optimization)
                var loadOptions = new System.Data.Linq.DataLoadOptions();
                loadOptions.LoadWith<GetEmployeeOrgReplayReportResult>(f => f.Employee);
                db.LoadOptions = loadOptions;
                db.Log = new System.IO.StringWriter();

                var jobchangelist = from x in db.GetEmployeeOrgReplayReport(rangeBeginDate, rangeEndDate)
                                    orderby x.EmployeeId, x.OrgId
                                    select x;

                // group into report by employee (turn into array first to do the grouping in LINQ, not SQL)
                return new EmployeeReport(jobchangelist.AsEnumerable().GroupBy(f => f.EmployeeId).ToDictionary(f => f.Key, f => f.AsEnumerable<IEmployeeReportItem>()));
            }
        }

        /// <summary>
        /// Using the EmployeeOrg (Current Employee Snapshot) data, for a given date range, show the differences in organizational structure between the first date and last date
        /// </summary>
        /// <param name="rangeBeginDate">Start date for the report</param>
        /// <param name="rangeEndDate">End date for the report</param>
        public EmployeeReport GenerateReportFromCurrentSnapshot(DateTime rangeBeginDate, DateTime rangeEndDate)
        {
            using (var db = new OnboardingOffboardingDataContext())
            {
                // Load joined Employee data with queries for EmployeeOrgReplay (optimization)
                var loadOptions = new System.Data.Linq.DataLoadOptions();
                loadOptions.LoadWith<GetEmployeeOrgReportResult>(f => f.Employee);
                db.LoadOptions = loadOptions;
                db.Log = new System.IO.StringWriter();

                var batchLogsBetweenDates = (from b in db.BatchLogs
                                             where b.LogDateTime >= rangeBeginDate && b.LogDateTime <= rangeEndDate
                                             orderby b.LogDateTime
                                             select b.LogDateTime).AsEnumerable().Select(f => f.ToString("MM/dd/yyyy HH:mm:ss.fff")).ToArray();

                var firstBatchLog = (from b in db.BatchLogs
                                     orderby b.LogDateTime ascending
                                     select b).FirstOrDefault();

                StringBuilder warnings = new StringBuilder();
                if (batchLogsBetweenDates.Length != 1)
                {
                    warnings.AppendFormat("There were {0} batch job within the report date range{1}.  Typically you would report with exactly 1 batch job in the range.\r\n", batchLogsBetweenDates.Length, batchLogsBetweenDates.Length > 0 ? " (" + string.Join(", ", batchLogsBetweenDates) + ")" : "");
                }
                if (firstBatchLog != null && firstBatchLog.LogDateTime >= rangeBeginDate)
                {
                    throw new Exception(string.Format("The report start date {0} is on or before the first batch job {1}.  The first batch job typically is a seed that includes all existing employees, and separated employees will be omitted.", rangeBeginDate, firstBatchLog.LogDateTime));
                }

                var jobchangelist = from x in db.GetEmployeeOrgReport(rangeBeginDate, rangeEndDate)
                                    orderby x.EmployeeId, x.OrgId
                                    select x;

                // group into report by employee (turn into array first to do the grouping in LINQ, not SQL)
                var report = new EmployeeReport(jobchangelist.AsEnumerable().GroupBy(f => f.EmployeeId).ToDictionary(f => f.Key, f => f.AsEnumerable<IEmployeeReportItem>()));
                report.Warnings = warnings.ToString();
                return report;
            }
        }


        public DateTime? GetLastBatchJobDateForCurrentSnapshot()
        {
            using (var db = new OnboardingOffboardingDataContext())
            {
                var log = (from b in db.BatchLogs
                        orderby b.LogDateTime descending
                        select b).FirstOrDefault();
                if (log == null)
                {
                    return null;
                }
                else
                {
                    return log.LogDateTime;
                }
            }
        }
    }
}
