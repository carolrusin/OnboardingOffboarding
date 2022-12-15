using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace OnboardingOffboarding.Data
{
    class DataUpdater
    {
        /// <summary>
        /// Pulls data from HR HIST data, and build a list of EmployeeOrgReplay mappings according to the history
        /// </summary>
        public void ImportEmployeeHistoryReplayData()
        {
            using (var db = new OnboardingOffboardingDataContext())
            {
                // Update employee list from unique employees in HR data from CentralDataFeed
                db.UpdateEmployeesFromHrData();

                // Clear out the current replay data taken from HR history, and re-import HR history as replay data
                HistoryReplayUpdater replay = new HistoryReplayUpdater(db);
                replay.DeleteData();
                replay.InterpretHrDataAndInsertEmployeeReplayData(db.HrEmployeeHistoryForValidOrgs);
            }
        }

        /// <summary>
        /// Pulls data from HR Employee data (a snapshot of current data), and update EmployeeOrg data in comparison to that snapshot
        /// </summary>
        public void ImportEmployeeSnapshotData()
        {
            using (var db = new OnboardingOffboardingDataContext())
            {
                // Call procedure that pulls from CentralDataFeed snapshot of current employee and update/insert EmployeeOrg records as needed
                // NOTE: UpdateEmployeesFromHrData is included in the following procedure, so don't need to run it here
                db.UpdateEmployeeOrgDataFromHrSnapshotData();
            }
        }

    }
}
