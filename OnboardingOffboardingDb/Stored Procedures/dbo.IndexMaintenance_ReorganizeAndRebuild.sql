SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Reorganizes indexes that have 10%-30% fragmentation, rebuilds indexes that have 30%+ fragmentation, for this database
CREATE PROCEDURE [dbo].[IndexMaintenance_ReorganizeAndRebuild]
WITH EXEC AS OWNER
AS
    BEGIN

-- Create temporary resources to create inventory of indexes to rebuild/reorganize
        CREATE TABLE #IndexOperations
            (
              DatabaseName NVARCHAR(128) ,
              SchemaName NVARCHAR(128) ,
              TableName NVARCHAR(128) ,
              IndexName NVARCHAR(128) ,
              FragmentationLevelBefore FLOAT ,
              Operation NVARCHAR(50) ,
              Script NVARCHAR(MAX) ,
              OutputMessage NVARCHAR(MAX)
            );

-- REORGANIZE INDEX LIST
        INSERT  INTO #IndexOperations
                ( DatabaseName ,
                  SchemaName ,
                  TableName ,
                  IndexName ,
                  FragmentationLevelBefore ,
                  Operation ,
                  Script
                )
                SELECT  DB_NAME() AS DatabaseName ,
                        SCHEMA_NAME(o.schema_id) AS SchemaName ,
                        o.name AS TableName ,
                        i.name AS IndexName ,
                        z.avg_fragmentation_in_percent AS FragmentationLevelBefore ,
                        N'REORGANIZE' AS Operation ,
                        N'ALTER INDEX ' + QUOTENAME(i.name) + N' ON '
                        + QUOTENAME(SCHEMA_NAME(o.schema_id)) + N'.'
                        + QUOTENAME(o.name)
                        + N' REORGANIZE WITH ( LOB_COMPACTION = ON )' AS Script
                FROM    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL,
                                                       NULL, NULL) z
                        INNER JOIN sys.indexes i ON i.index_id = z.index_id
                                                    AND i.object_id = z.object_id
                        INNER JOIN sys.objects o ON o.object_id = i.object_id
                WHERE   o.is_ms_shipped = 0
                        AND i.name IS NOT NULL
                        AND o.name != 'sysdiagrams'
                        AND z.avg_fragmentation_in_percent >= 10.0
                        AND z.avg_fragmentation_in_percent < 30.0
                ORDER BY o.name ,
                        i.is_primary_key DESC ,
                        i.name

-- REBUILD INDEX LIST
        INSERT  INTO #IndexOperations
                ( DatabaseName ,
                  SchemaName ,
                  TableName ,
                  IndexName ,
                  FragmentationLevelBefore ,
                  Operation ,
                  Script
                )
                SELECT  DB_NAME() AS DatabaseName ,
                        SCHEMA_NAME(o.schema_id) AS SchemaName ,
                        o.name AS TableName ,
                        i.name AS IndexName ,
                        z.avg_fragmentation_in_percent AS FragmentationLevelBefore ,
                        N'REBUILD' AS Operation ,
                        N'ALTER INDEX ' + QUOTENAME(i.name) + N' ON '
                        + QUOTENAME(SCHEMA_NAME(o.schema_id)) + N'.'
                        + QUOTENAME(o.name)
                        + N' REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)' AS Script
                FROM    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL,
                                                       NULL, NULL) z
                        INNER JOIN sys.indexes i ON i.index_id = z.index_id
                                                    AND i.object_id = z.object_id
                        INNER JOIN sys.objects o ON o.object_id = i.object_id
                WHERE   o.is_ms_shipped = 0
                        AND i.name IS NOT NULL
                        AND o.name != 'sysdiagrams'
                        AND z.avg_fragmentation_in_percent >= 30.0
                ORDER BY o.name ,
                        i.is_primary_key DESC ,
                        i.name

-- Set output message for nice logging
        UPDATE  i
        SET     i.OutputMessage = i.Operation + ' index '
                + QUOTENAME(i.DatabaseName) + '.' + QUOTENAME(i.SchemaName)
                + '.' + QUOTENAME(i.TableName) + '.' + QUOTENAME(i.IndexName)
                + ' ('
                + CONVERT(NVARCHAR(255), ROUND(i.FragmentationLevelBefore, 3))
                + '% fragmented)'
        FROM    #IndexOperations i

-- Build MSSQL script
        DECLARE @script NVARCHAR(MAX)
        SET @script = ''
        SELECT  @script = @script + N'PRINT N' + QUOTENAME(i.OutputMessage,
                                                           '''') + N'; '
                + CHAR(13) + CHAR(10) + i.Script + N'; ' + CHAR(13) + CHAR(10)
        FROM    #IndexOperations i

-- Clean up temporary resources
        DROP TABLE #IndexOperations

-- Reorganize/rebuild actual indexes (run the script that was generated)
        EXEC (@script)


    END

GO
