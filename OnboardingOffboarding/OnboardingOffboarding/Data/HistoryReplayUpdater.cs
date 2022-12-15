using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace OnboardingOffboarding.Data
{
    class HistoryReplayUpdater
    {
        private OnboardingOffboardingDataContext Db { get; set; }

        public HistoryReplayUpdater(OnboardingOffboardingDataContext db)
        {
            this.Db = db;
        }

        /// <summary>
        /// Deletes all data in the EmployeeOrgReplay table
        /// </summary>
        public void DeleteData()
        {
            Db.DeleteAllHistoryReplayData();
        }

        /// <summary>
        /// Reads specified HR employee history data and imports Employee History Replay Data appropriately. 
        /// This will iterate over each employee history record for employeeid/dept_code (orgid), 
        /// and attempt to consolidate multiple overlapping appointments in a single department into their own records.
        /// Then, it will insert the records into the database.
        /// </summary>
        /// <param name="hrdata">A queryable containing the HR data, typically the LINQ table/view object itself</param>
        public void InterpretHrDataAndInsertEmployeeReplayData(IQueryable<HrEmployeeHistoryForValidOrg> hrdata)
        {
            var source = from h in hrdata
                         orderby h.EMPLOYEE_ID, h.DEPT_CODE, h.APPT_NO, h.EFFDT, h.APPT_BEGIN_DT
                         select h;

            string employeeId = null, deptCode = null;
            decimal? apptNo = null;
            EmployeeAppointment appt = null;
            List<EmployeeAppointment> apptList = null;
            EmployeeAppointment oldappt = null;
            foreach (var record in source)
            {
                // iterate over all of the employee records, grouping by employee_id, dept_code, then appt_no; sorted by effdt
                if (employeeId != record.EMPLOYEE_ID || deptCode != record.DEPT_CODE)
                {
                    //   for a new employee/dept_code
                    if (apptList != null)
                    {
                        //     iterate over previous employee/dept_code's appointment records, and consolidate overlapping records
                        var sortedAppts = from a in apptList
                                          orderby a.StartDate ascending
                                          select a;
                        EmployeeOrgReplay replay = null;
                        foreach (var item in sortedAppts)
                        {
                            if (replay == null)
                            {
                                replay = new EmployeeOrgReplay
                                {
                                    EmployeeId = int.Parse(employeeId),
                                    OrgId = int.Parse(deptCode),
                                    BeginDateTime = item.StartDate.Value,
                                    EndDateTime = item.EndDate,
                                };
                            }
                            else if (item.EndDate == null)
                            {
                                // the employee is still current in the org if enddate is null, so set that going forward
                                replay.EndDateTime = null;
                            }
                            else if (replay.EndDateTime == null) { 
                                // ignore everything that comes after, since the employee is still current in the org
                            }
                            else if (item.StartDate <= replay.EndDateTime)
                            {
                                // if this item is overlapping the previous, extend the end date to this one's end date
                                replay.EndDateTime = item.EndDate;
                            }
                            else
                            {
                                //       insert replay into db, and start a new one
                                Db.EmployeeOrgReplays.InsertOnSubmit(replay);
                                replay = null;
                            }
                        }
                        if (replay != null)
                        {
                            //       insert last replay into db
                            Db.EmployeeOrgReplays.InsertOnSubmit(replay);
                        }
                        apptList.Clear();
                    }
                    else
                    {
                        apptList = new List<EmployeeAppointment>();
                    }

                    employeeId = record.EMPLOYEE_ID;
                    deptCode = record.DEPT_CODE;
                    apptNo = null;
                }
                if (apptNo != record.APPT_NO)
                {
                    apptNo = record.APPT_NO;
                    oldappt = null;
                    //     create a new appointment for the employee
                    appt = new EmployeeAppointment();
                    apptList.Add(appt);
                }
                if (appt.EndDate != null && record.SEPARATION_DATE == null)
                {
                    //     if the previous record was a separation and this one isn't, then create a new appointment
                    oldappt = appt;
                    appt = new EmployeeAppointment();
                    apptList.Add(appt);
                }
                //     set the start_date as the earlier between the current appt start date and the record start dates
                appt.StartDate = oldappt == null
                    ? (record.JOB_BEGIN_DT < record.APPT_BEGIN_DT
                        ? record.JOB_BEGIN_DT
                        : record.APPT_BEGIN_DT
                        )
                    : (oldappt.EndDate < record.JOB_BEGIN_DT
                        ? record.JOB_BEGIN_DT
                        : (oldappt.EndDate < record.APPT_BEGIN_DT
                            ? record.APPT_BEGIN_DT
                            : (oldappt.EndDate < record.EFFDT
                                ? record.EFFDT
                                : null
                                )
                            )
                        );
                if (appt.StartDate == null)
                {
                    // should not be possible
                    throw new Exception("Start date does not follow chronological order");
                }
                //     if the record is a termination record, record the separation_date as the end date for the appointment
                if (record.SEPARATION_DATE != null)
                {
                    appt.EndDate = record.SEPARATION_DATE;
                }
            }

            Db.SubmitChanges();
        }
    }
}
