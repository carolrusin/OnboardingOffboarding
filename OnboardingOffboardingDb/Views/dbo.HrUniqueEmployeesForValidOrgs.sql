SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[HrUniqueEmployeesForValidOrgs]
AS

SELECT hremps.EMPLOYEE_ID, hremps.NETID, hremps.RCP_ID, hremps.LAST_NAME, hremps.FIRST_NAME
FROM CentralDataFeed.app_onboardingoffboarding.UNIQUE_EMPLOYEES hremps
	INNER JOIN
		(
			SELECT DISTINCT snap.EMPLOYEE_ID
			FROM CentralDataFeed.app_onboardingoffboarding.OUTPUT_HR_EMPLOYEES snap
			INNER JOIN Org o
				ON o.Id = snap.DEPT_CODE
			WHERE SEPARATION_DATE IS NULL
			
			UNION
			
			SELECT DISTINCT hist.EMPLOYEE_ID
			FROM CentralDataFeed.app_onboardingoffboarding.OUTPUT_HR_EMPLOYEE_HISTORY hist
			INNER JOIN Org o
				ON o.Id = hist.DEPT_CODE
			WHERE SEPARATION_DATE IS NULL
		) empLimited
			ON empLimited.EMPLOYEE_ID = hremps.EMPLOYEE_ID
GO
