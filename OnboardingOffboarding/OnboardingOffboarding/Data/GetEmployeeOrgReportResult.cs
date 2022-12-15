using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Linq;
using OnboardingOffboarding.Report;

namespace OnboardingOffboarding.Data
{
    public partial class GetEmployeeOrgReportResult : IEmployeeReportItem
    {

        private EntityRef<Employee> _Employee;

        [global::System.Data.Linq.Mapping.AssociationAttribute(Storage = "_Employee", ThisKey = "EmployeeId", OtherKey = "Id", IsForeignKey = true)]
        public Employee Employee
        {
            get
            {
                return this._Employee.Entity;
            }
            set
            {
                Employee previousValue = this._Employee.Entity;
                if (((previousValue != value)
                            || (this._Employee.HasLoadedOrAssignedValue == false)))
                {
                    if ((previousValue != null))
                    {
                        this._Employee.Entity = null;
                    }
                    this._Employee.Entity = value;
                    if ((value != null))
                    {
                        this._EmployeeId = value.Id;
                    }
                    else
                    {
                        this._EmployeeId = default(int);
                    }
                }
            }
        }


    }
}
