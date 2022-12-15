
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Updates EmployeeOrg table with new entries from HR data, or closed entries from HR data when existing employee/orgs are missing
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEmployeeOrgDataFromHrSnapshotData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @runtime datetime;
	SET @runtime = GETDATE();
	DECLARE @result int;
	SET @result = 0;

	BEGIN TRANSACTION
	SET XACT_ABORT ON

	-- Update batch log
	INSERT INTO BatchLog
	([LogDateTime], [Message], [Status])
	VALUES (@runtime, NULL, 0)
	
	-- insert any employees that are not included yet
	EXEC dbo.UpdateEmployeesFromHrData

	-- update EndDateTime for existing EmployeeOrg mappings that are no longer in the HR employee data snapshot
	UPDATE eo
	SET eo.EndDateTime = @runtime
	FROM EmployeeOrg eo
		LEFT OUTER JOIN HrEmployeeCurrentSnapshotForValidOrgs_Deduplicated hr
			ON hr.EMPLOYEE_ID = eo.EmployeeId
			AND hr.DEPT_CODE = eo.OrgId
	WHERE 
		eo.EndDateTime IS NULL
		AND hr.EMPLOYEE_ID IS NULL

	SET @result = @result + @@ROWCOUNT	

	-- updated records that have a separation date that weren't recorded previously
	UPDATE eo
	SET eo.EndDateTime = @runtime
		,eo.HrEndDateTime = hr.SEPARATION_DATE
	FROM EmployeeOrg eo
		LEFT OUTER JOIN HrEmployeeCurrentSnapshotForValidOrgs_Deduplicated hr
			ON hr.EMPLOYEE_ID = eo.EmployeeId
			AND hr.DEPT_CODE = eo.OrgId
	WHERE 
		eo.EndDateTime IS NULL
		AND hr.SEPARATION_DATE IS NOT NULL
		AND hr.SEPARATION_DATE <= @runtime

	SET @result = @result + @@ROWCOUNT	

	-- insert employee/org mappings found in HR employee data snapshot that are not already in the EmployeeOrg table
	INSERT INTO EmployeeOrg
	(EmployeeId, OrgId, BeginDateTime, EndDateTime, HrBeginDateTime)
	SELECT hr.EMPLOYEE_ID as EmployeeId
		, hr.DEPT_CODE as OrgId
		, @runtime as BeginDateTime
		,NULL as EndDateTime
		, CASE WHEN hr.JOB_BEGIN_DATE < hr.APPT_BEGIN_DATE OR hr.APPT_BEGIN_DATE IS NULL
			THEN hr.JOB_BEGIN_DATE
			ELSE hr.APPT_BEGIN_DATE
			END as HrBeginDateTime
	FROM HrEmployeeCurrentSnapshotForValidOrgs_Deduplicated hr
		LEFT OUTER JOIN EmployeeOrg eo
			ON eo.EmployeeId = hr.EMPLOYEE_ID
			AND eo.OrgId = hr.DEPT_CODE
			AND eo.EndDateTime IS NULL
	WHERE
		eo.EmployeeId IS NULL
		-- we don't want to import separation records as "hires"
		AND hr.SEPARATION_DATE IS NULL

	SET @result = @result + @@ROWCOUNT
	
	COMMIT TRANSACTION

	RETURN @result
		
END
GO
