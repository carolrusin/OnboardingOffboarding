//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace OnboardingDifferentialReportToCsv.DB
{
    using System;
    
    public partial class PROC_EmployeeDeptDifferential_Result
    {
        public string employee_id { get; set; }
        public string dept_code { get; set; }
        public Nullable<System.DateTime> DeptHireDate { get; set; }
        public Nullable<System.DateTime> DeptEndDate { get; set; }
        public Nullable<System.DateTime> RutgersHireDate { get; set; }
        public Nullable<System.DateTime> DeptTerminationDate { get; set; }
        public Nullable<System.DateTime> RutgersTerminationDate { get; set; }
        public string EMP_START_STATUS { get; set; }
        public string EMP_END_STATUS { get; set; }
    }
}
