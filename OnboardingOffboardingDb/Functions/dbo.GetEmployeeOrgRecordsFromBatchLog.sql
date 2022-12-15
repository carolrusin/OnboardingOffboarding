SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Gets EmployeeOrg table records inserted or updated from a particular batch job
-- =============================================
CREATE FUNCTION [dbo].[GetEmployeeOrgRecordsFromBatchLog]
(	
	@batchLogId int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		eo.[Id]
		,eo.[EmployeeId]
		,eo.[OrgId]
		,eo.[BeginDateTime]
		,eo.[EndDateTime]
		,eo.[HrBeginDateTime]
		,eo.[HrEndDateTime]	
	FROM BatchLog b
		INNER JOIN EmployeeOrg eo
			ON eo.BeginDateTime = b.LogDateTime
			OR eo.EndDateTime = b.LogDateTime
	WHERE b.Id = @batchLogId
)
GO
