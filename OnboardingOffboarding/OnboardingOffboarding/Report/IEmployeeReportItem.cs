using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OnboardingOffboarding.Data;

namespace OnboardingOffboarding.Report
{
    public interface IEmployeeReportItem
    {

        Employee Employee { get; }
        DateTime BeginDateTime { get; }
        DateTime? EndDateTime { get; }
        string EmployeeStatus { get; }
        int Hire { get; }
        int OrgId { get; }
        string OrgName { get; }

    }

}
