SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[HrEmployeeHistoryForValidOrgs]
AS
    SELECT  h.*
    FROM    CentralDataFeed.app_onboardingoffboarding.OUTPUT_HR_EMPLOYEE_HISTORY h
            INNER JOIN Org o ON o.Id = h.DEPT_CODE
            INNER JOIN dbo.Employee e ON e.Id = CONVERT(INT, h.EMPLOYEE_ID)

GO
