-- Migration Script: Add Title and Description columns to Mission table
-- Date: 2025-12-15
-- Purpose: Add support for mission title and description fields

USE MILESTONE2;
GO

-- Check if the columns already exist before adding them
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Mission]') AND name = 'title')
BEGIN
    ALTER TABLE Mission
    ADD title varchar(200);
    PRINT 'Column title added to Mission table.';
END
ELSE
BEGIN
    PRINT 'Column title already exists in Mission table.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Mission]') AND name = 'description')
BEGIN
    ALTER TABLE Mission
    ADD description text;
    PRINT 'Column description added to Mission table.';
END
ELSE
BEGIN
    PRINT 'Column description already exists in Mission table.';
END
GO

PRINT 'Migration completed successfully.';
