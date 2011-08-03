--
-- Title:      Increase the ipAddress field length to allow IPv6 adresses
-- Database:   MS SQL
-- Since:      V3.1 schema 1009
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

-- PLEASE DO NOT SPLIT THE LINE BELOW CAUSE SchemaBootstrap CLASS DOES NOT HANDLE MSSQL VARIABLES

declare @uk VARCHAR(40);declare @drop VARCHAR(100);declare @add VARCHAR(100);set @uk = ( SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE  WHERE TABLE_NAME = 'alf_server'  AND COLUMN_NAME='ip_address');set @drop = 'alter table alf_server drop constraint ' + @uk;exec (@drop);alter table alf_server ALTER COLUMN ip_address varchar(39);set @add = 'ALTER TABLE alf_server add constraint ' + @uk + ' unique (ip_address)';exec (@add);

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.1-Allow-IPv6';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.1-Allow-IPv6', 'Manually executed script upgrade V3.1: Increase the ipAddress field length',
     0, 1009, -1, 1010, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
   );