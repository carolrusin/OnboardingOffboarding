SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Deletes all data in the EmployeeOrgReplay table 
-- =============================================
CREATE PROCEDURE [dbo].[DeleteAllHistoryReplayData] 
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM dbo.EmployeeOrgReplay
END
GO
