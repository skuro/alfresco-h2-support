--
-- Title:      Upgrade to V3.3 - Remove context_id from the permission_id index on alf_access_control_list_entry 
-- Database:   Oracle
-- Since:      V3.3 schema 4011
-- Author:     
--
-- Remove context_id from the permission_id unique index (as it alwaays contains null and therefore has no effect)
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--



-- The remainder of this script is adapted from 
-- Repository/config/alfresco/dbscripts/upgrade/2.2/org.alfresco.repo.domain.hibernate.dialect.AlfrescoOracle9Dialect/AlfrescoSchemaUpdate-2.2-ACL.sql
-- Ports should do the same and reflect the DB specific improvements

-- ------------------------------------------------- --
-- Ensure stats are up to date on all schema objects --
-- ------------------------------------------------- --
begin dbms_stats.gather_schema_stats(ownname => user, options => 'GATHER AUTO', estimate_percent => dbms_stats.auto_sample_size); end;;

CREATE TABLE NSI_ACE_TEMP AS 
SELECT min(ace1.id) as id, ace1.version as version, ace1.permission_id, ace1.allowed, ace1.authority_id, ace1.applies, ace1.context_id 
FROM alf_access_control_entry ace1
GROUP BY ace1.permission_id, ace1.authority_id, ace1.allowed, ace1.applies, ace1.context_id, ace1.version;


CREATE TABLE alf_tmp_acl_members AS
    SELECT
        mem.id, help.id AS min_id, mem.acl_id, mem.pos, mem.ace_id
    FROM
        alf_acl_member mem
        JOIN
            alf_access_control_entry ace
        ON
            mem.ace_id = ace.id
        JOIN
            NSI_ACE_TEMP help
        ON
            help.permission_id = ace.permission_id AND
            help.authority_id = ace.authority_id AND
            help.allowed = ace.allowed AND
            help.applies = ace.applies;


CREATE TABLE alf_tmp_acl_groups AS
    SELECT
        mems.min_id, mems.acl_id, mems.pos, min(mems.ace_id) AS group_min
    FROM
        alf_tmp_acl_members mems
    GROUP BY
        mems.min_id, mems.acl_id, mems.pos
    HAVING
        count(*) > 1;


DELETE FROM
    alf_acl_member
WHERE
    id IN (
        SELECT
            mems.id
        FROM
            alf_tmp_acl_members mems
            JOIN
                alf_tmp_acl_groups groups
            ON
                mems.min_id = groups.min_id AND
                mems.acl_id = groups.acl_id AND
                mems.pos = groups.pos
        WHERE
            mems.ace_id <> groups.group_min
    );


DROP TABLE
    alf_tmp_acl_members;

DROP TABLE
    alf_tmp_acl_groups;


UPDATE alf_acl_member mem
   SET ace_id = (SELECT min(ace1.id) FROM nsi_ace_temp ace1 
                     JOIN alf_access_control_entry ace2 
                             ON ace1.permission_id = ace2.permission_id AND
                                ace1.authority_id = ace2.authority_id AND 
                                ace1.allowed = ace2.allowed AND 
                                ace1.applies = ace2.applies 
                     WHERE ace2.id = mem.ace_id  );

-- CREATE INDEX fk_alf_aclm_acl ON alf_acl_member (acl_id);
-- CREATE INDEX fk_alf_aclm_ace ON alf_acl_member (ace_id);

-- ------------------------------------------------- --
-- Ensure stats are up to date on all schema objects --
-- ------------------------------------------------- --
begin dbms_stats.gather_schema_stats(ownname => user, options => 'GATHER AUTO', estimate_percent => dbms_stats.auto_sample_size); end;;

ALTER TABLE "ALF_ACL_MEMBER" DISABLE CONSTRAINT FK_ALF_ACLM_ACE; -- (optional)
TRUNCATE TABLE alf_access_control_entry;
INSERT INTO alf_access_control_entry (id, version, permission_id, authority_id, allowed, applies, context_id )
   SELECT id, version, permission_id, authority_id, allowed, applies, context_id FROM NSI_ACE_TEMP;
ALTER TABLE "ALF_ACL_MEMBER" ENABLE CONSTRAINT FK_ALF_ACLM_ACE; -- (optional)

DROP TABLE NSI_ACE_TEMP;


-- Add constraint for duplicate acls (this no longer includes the context)
ALTER TABLE alf_access_control_entry DROP UNIQUE (permission_id, authority_id, allowed, applies, context_id); 
ALTER TABLE alf_access_control_entry
   ADD UNIQUE (permission_id, authority_id, allowed, applies);

   


-- ------------------------------------------------- --
-- Ensure stats are up to date on all schema objects --
-- ------------------------------------------------- --
begin dbms_stats.gather_schema_stats(ownname => user, options => 'GATHER AUTO', estimate_percent => dbms_stats.auto_sample_size); end;;
   
--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.3-modify-index-permission_id';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.3-modify-index-permission_id', 'Remove context_id from the permission_id unique index (as it always contains null and therefore has no effect)',
     0, 4011, -1, 4012, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
   );
