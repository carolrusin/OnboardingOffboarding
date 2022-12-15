using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OnboardingOffboarding.Data;
using OnboardingOffboarding.Util;

namespace OnboardingOffboarding.Report
{
    public class EmployeeReport : Dictionary<int, IEnumerable<IEmployeeReportItem>>
    {

        public EmployeeReport(Dictionary<int, IEnumerable<IEmployeeReportItem>> reportData)
            : base(reportData)
        {
        }

        public string Warnings { get; set; }


        public void WriteCSV(System.IO.TextWriter reportWriter)
        {
            // Write header once
            this.WriteCSVForEmployeeReport(reportWriter, new IEmployeeReportItem[0], true);
            // Iterate over each employee, and write each list of changes as CSV
            foreach (var list in this.Values)
            {
                this.WriteCSVForEmployeeReport(reportWriter, list, false);
            }
        }

        private void WriteCSVForEmployeeReport(System.IO.TextWriter reportWriter, IEnumerable<IEmployeeReportItem> employeeData, bool includeHeader)
        {
            var employeeReport = from x in employeeData
                                 select new
                                 {
                                     x.Employee.NetId,
                                     x.Employee.Lastname,
                                     x.Employee.Firstname,
                                     EmployeeStatus = Enum.Parse(typeof(EmployeeChangeTypes), x.EmployeeStatus),
                                     x.OrgId,
                                     x.OrgName,
                                     OrgStatus = (x.Hire == 1 ? DepartmentStatuses.Hire : DepartmentStatuses.Separation),
                                     // The date time effective in the report is the start date for hires, and the end date for separations
                                     DateTimeEffective = (x.Hire == 1 ? x.BeginDateTime : x.EndDateTime.Value).ToString("MM/dd/yyyy HH:mm:ss.fff"),
                                 };

            employeeReport.WriteCSV(reportWriter, true, includeHeader);
        }
    }
}
