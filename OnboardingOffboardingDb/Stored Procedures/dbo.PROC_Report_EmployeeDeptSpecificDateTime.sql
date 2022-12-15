SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PROC_Report_EmployeeDeptSpecificDateTime]
	-- Add the parameters for the stored procedure here
	@CutOffDate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT  a.NetId, a.Lastname, a.Firstname, k1.DEPT_CODE
FROM    [OnboardingOffboarding].[dbo].[Employee] a ,
        ( SELECT  DISTINCT h.EMPLOYEE_ID, h.DEPT_CODE
			FROM    [CentralDataFeed].[dbo].HRI_NC_EMPLOYEES_HIST h
					INNER JOIN ( SELECT EMPLOYEE_ID ,
										APPT_NO ,
										MAX(EFFDT) AS j1
								 FROM   [CentralDataFeed].[dbo].[HRI_NC_EMPLOYEES_HIST]
								 WHERE  EFFDT <= @CutOffDate
								 GROUP BY EMPLOYEE_ID ,
										APPT_NO
							   ) x ON x.APPT_NO = h.APPT_NO
									  AND x.EMPLOYEE_ID = h.EMPLOYEE_ID
									  AND x.j1 = h.EFFDT
			WHERE h.SEPARATION_DATE IS NULL
        ) k1
WHERE   a.NetID = k1.EMPLOYEE_ID
ORDER BY Lastname, Firstname, k1.DEPT_CODE

END


GO
