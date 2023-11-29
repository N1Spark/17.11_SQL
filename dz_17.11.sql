-- 1

CREATE FUNCTION dbo.GetTableInfo
    (@databaseName NVARCHAR(255))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        t.name AS TableName,
        p.rows AS [RowCount],
        SUM(a.total_pages) * 8 AS TotalSizeBytes
    FROM 
        sys.tables t
    INNER JOIN 
        sys.indexes i ON t.object_id = i.object_id
    INNER JOIN 
        sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    INNER JOIN 
        sys.allocation_units a ON p.partition_id = a.container_id
    WHERE 
        t.is_ms_shipped = 0
    GROUP BY 
        t.name, p.rows
);


SELECT *
FROM dbo.GetTableInfo('GAME');


-- 2

CREATE FUNCTION dbo.GetTableFields
    (@tableName NVARCHAR(255))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        COLUMN_NAME,
        DATA_TYPE
    FROM 
        INFORMATION_SCHEMA.COLUMNS
    WHERE 
        TABLE_NAME = @tableName
);

SELECT *
FROM dbo.GetTableFields('Bandit');


-- 3

CREATE FUNCTION dbo.GetConnectedUsersCount()
RETURNS INT
AS
BEGIN
    DECLARE @UserCount INT;

    SELECT @UserCount = COUNT(*)
    FROM sys.dm_exec_sessions
    WHERE is_user_process = 1;

    RETURN @UserCount;
END;

DECLARE @ConnectedUsers INT;
SET @ConnectedUsers = dbo.GetConnectedUsersCount();
SELECT @ConnectedUsers AS ConnectedUsersCount;