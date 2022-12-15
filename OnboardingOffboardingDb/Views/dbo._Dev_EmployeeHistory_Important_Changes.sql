SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW dbo._Dev_EmployeeHistory_Important_Changes
AS

WITH hist AS (
	-- employee history records, but for each distinct EMPLOYEE_ID/APPT_NO add an incremental id "_row" (by date)
	-- this way, we can join previous records easily for delta comparisons
	SELECT ROW_NUMBER() OVER (PARTITION BY h.EMPLOYEE_ID, h.APPT_NO ORDER BY h.EFFDT) AS _row, h.*
	FROM CentralDataFeed.dbo.HRI_NC_EMPLOYEES_HIST h
)
, delta AS (
/*
Important/significant historical records for an employee's appointment (job):
---
Employee changes dept for job:
For EMPLOYEE_ID / APPT_NO, DEPT_CODE is different on previous record (and there's no separation date for record OR previous record)

Employee leaves job:
For EMPLOYEE_ID / APPT_NO, SEPARATION_DATE specified (previous record no sep date)

Employee is hired for job first time:
For EMPLOYEE_ID / APPT_NO, first record (no previous record)

Employee is rehired for job after leaving:
For EMPLOYEE_ID / APPT_NO, record that has NO SEPARATION_DATE, after the previous record that has a SEPARATION_DATE
*/
	SELECT 
		CASE WHEN (p.DEPT_CODE != h.DEPT_CODE AND p.SEPARATION_DATE IS NULL AND h.SEPARATION_DATE IS NULL)
			THEN 1
			ELSE 0
			END AS ApptDeptChange
		,CASE WHEN (p.SEPARATION_DATE IS NULL AND h.SEPARATION_DATE IS NOT NULL)
			THEN 1
			ELSE 0
			END AS ApptLeaveAppt
		,CASE WHEN (p.EFFDT IS NULL)
			THEN 1
			ELSE 0
			END AS ApptFirstHire
		,CASE WHEN (p.SEPARATION_DATE IS NOT NULL AND h.SEPARATION_DATE IS NULL)
			THEN 1
			ELSE 0
			END AS ApptRehire
		,h.EMPLOYEE_ID, h.APPT_NO, h.EFFDT, h.[_row], h.DEPT_CODE, h.SEPARATION_DATE, p.[_row] AS _prevrow, p.DEPT_CODE AS PREV_DEPT_CODE, p.SEPARATION_DATE AS PREV_SEPARATION_DATE
		
	FROM hist h
	LEFT JOIN hist p 
		ON p.EMPLOYEE_ID = h.EMPLOYEE_ID
		AND p.APPT_NO = h.APPT_NO
		AND p.[_row] = h.[_row] - 1
	WHERE 
	(
		(p.DEPT_CODE != h.DEPT_CODE AND p.SEPARATION_DATE IS NULL AND h.SEPARATION_DATE IS NULL)
		OR (p.SEPARATION_DATE IS NULL AND h.SEPARATION_DATE IS NOT NULL)
		OR (p.EFFDT IS NULL)
		OR (p.SEPARATION_DATE IS NOT NULL AND h.SEPARATION_DATE IS NULL)
	)
	--AND h.EFFDT >= '2013-01-01' AND h.EFFDT <= '2013-10-24'
)
/*
Rules:
- SEPARATION_DATE <= EFFDT (usually ==)
- ApptLeaveAppt takes precedence over all
- ApptRehire takes precedence over ApptDeptChange
*/

SELECT *
FROM delta
--WHERE ApptDeptChange = 1 AND ApptRehire = 1
GO
