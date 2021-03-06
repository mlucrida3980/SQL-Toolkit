/********************************************************************************************************
Title:					Database Analysis
Query Notes:			View the metadata of tables and columns in each database.  THIS QUERY IS NOT DESIGNED
						TO BE USED IN A REPORT DUE TO THE INFLEXABILITY OF SSRS.
Database(s) Used:		Any.  Just change the connections and select the database you want to analyze
Date Last Updated:		02/09/2018
Change Log:				Please see the end of file.
********************************************************************************************************/

--DECLARE @TABLE VARCHAR(20) = 'LOAN'

;WITH _CoreData_ AS (
SELECT 
	T.object_id AS TableObjectID
	,T.Name AS TableName
	,T.type_desc AS TableType
	,S.Name AS SchemaType
	,C.column_id AS ColumnID
	,C.Name As ColumnName
	,Y.Name AS DataType
	,C.max_length AS DataTypeLength
FROM [sys].[Tables] T
	LEFT JOIN [sys].[Schemas] S
		ON T.schema_id = S.schema_id
	LEFT JOIN [sys].[Columns] C
		ON T.object_id = C.object_id
	LEFT JOIN [sys].[systypes] Y
		ON C.[system_type_id] = Y.xtype
),
TableIndexes AS (
SELECT 
	i.object_id as Table_ID
	,ic.column_id
	,i.name AS IndexName  
	,i.type_desc AS IndexType
    ,COL_NAME(ic.object_id,ic.column_id) AS column_name  
    ,ic.index_column_id  
    ,ic.key_ordinal  
	,ic.is_included_column  
FROM [sys].[indexes] i INNER JOIN [sys].[index_columns] ic   
    ON i.object_id = ic.object_id 
	AND i.index_id = ic.index_id  
),

ForeignKeys AS (
SELECT 
	F.parent_object_id AS TableObjectID
	,F.parent_column_id AS ColumnID
	,RT.Name AS FK_ReferencedTable
	,RC.Name AS FK_ReferencedColumn
FROM 
	[sys].[foreign_key_columns] F
	
	LEFT JOIN [sys].[Tables] PT 
		ON PT.object_id = F.parent_object_id
	LEFT JOIN [sys].[Columns] PC
		ON PC.object_id = F.parent_column_id
	LEFT JOIN [sys].[Tables] RT 
		ON RT.object_id = F.referenced_object_id
	LEFT JOIN [sys].[Columns] RC
		ON RC.object_id = F.referenced_column_id
)

,Results AS (
SELECT 
	TableName
	,TableType
	,SchemaType
	,ColumnName
	,DataType
	,DataTypeLength
	,IndexName
	,IndexType
	,FK_ReferencedTable
	,FK_ReferencedColumn
FROM 
	_CoreData_ C LEFT JOIN ForeignKeys F
		ON C.TableObjectID = F.TableObjectID
		AND C.ColumnID = F.ColumnID
	LEFT JOIN TableIndexes TI ON 
		C.TableObjectID = TI.Table_ID
		AND C.ColumnID = TI.column_id
)
SELECT *
FROM Results
-- Code your filters here --
;
---- Uncomment to view statistics of an index for a table
--DBCC SHOW_STATISTICS(<TABLE>,<INDEX>);

/********************************************************************************************************
Change Log:

02/07/2017 - Initial File Created by mLucrida
02/09/2018 - Updated to show index by column
		   - Database statistics now available at bottom
********************************************************************************************************/