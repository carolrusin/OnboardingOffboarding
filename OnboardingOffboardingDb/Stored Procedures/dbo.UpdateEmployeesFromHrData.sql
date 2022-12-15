SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Insert all employees from HR data that are not yet in the Employee table, and update Employee data for those that are
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEmployeesFromHrData] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @runtime datetime;
	SET @runtime = GETDATE();

    -- Insert employees not yet in the Employee table
	INSERT INTO
	Employee
		( Id, NetId, RcpId, Lastname, Firstname, DateTimeCreated )
	SELECT 
		hremps.[EMPLOYEE_ID]
		,hremps.[NETID]
		,hremps.[RCP_ID]
		,hremps.[LAST_NAME]
		,hremps.[FIRST_NAME]
		,@runtime
	FROM HrUniqueEmployeesForValidOrgs hremps
		LEFT OUTER JOIN dbo.Employee e
			ON e.Id = hremps.EMPLOYEE_ID
	WHERE e.Id IS NULL
	
	-- Update employees that are already in the Employee table
	UPDATE e
	SET e.NetId = hremps.[NETID]
		,e.RcpId = hremps.[RCP_ID]
		,e.Lastname = hremps.[LAST_NAME]
		,e.Firstname = hremps.[FIRST_NAME]
		,e.DateTimeUpdated = @runtime
	FROM CentralDataFeed.app_onboardingoffboarding.UNIQUE_EMPLOYEES hremps
		INNER JOIN Employee e
			ON e.Id = hremps.EMPLOYEE_ID
	
END
GO
