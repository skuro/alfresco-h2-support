--
-- Title:      Create missing 2.1 tables
-- Database:   DB2
-- Since:      V2.1.a Schema 81
-- Author:     
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- Upgrade paths that bypass V2.1 will need to have a some tables added in order
-- to simplify subsequent upgrade scripts.
--

-- Add ACL column for AVM tables
ALTER TABLE AVM_STORES ADD COLUMN ACL_ID BIGINT;

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V2.2-0-CreateMissingTables';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V2.2-0-CreateMissingTables', 'Manually executed script upgrade V2.2: Created missing tables',
    0, 120, -1, 121, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );