SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[OverlappingEmployeeOrgRecords]
AS
SELECT e1.[Id] AS [Id_1]
      ,e1.[EmployeeId] AS [EmployeeId_1]
      ,e1.[OrgId] AS [OrgId_1]
      ,e1.[BeginDateTime] AS [BeginDateTime_1]
      ,e1.[EndDateTime] AS [EndDateTime_1]
      ,e2.[Id] AS [Id_2]
      ,e2.[EmployeeId] AS [EmployeeId_2]
      ,e2.[OrgId] AS [OrgId_2]
      ,e2.[BeginDateTime] AS [BeginDateTime_2]
      ,e2.[EndDateTime] AS [EndDateTime_2]
FROM EmployeeOrg e1
INNER JOIN EmployeeOrg e2
	ON e1.EmployeeId = e2.EmployeeId
	AND e1.OrgId = e2.OrgId
	AND e1.Id != e2.Id
WHERE 
	(e1.BeginDateTime >= e2.BeginDateTime AND (e1.BeginDateTime <= e2.EndDateTime OR e2.EndDateTime IS NULL))
GO
