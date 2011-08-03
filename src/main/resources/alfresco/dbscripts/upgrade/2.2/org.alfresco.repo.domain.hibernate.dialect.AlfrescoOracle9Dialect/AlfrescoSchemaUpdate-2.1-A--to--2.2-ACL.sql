--
-- Title:      Update for permissions schema changes
-- Database:   Oracle
-- Since:      V2.2 Schema 85
-- Author:     Andy Hind
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- Improved By NSI-SA www.nsi-sa.be: MSL & BMI 


-- -------------------------------- --
-- NSI - DISABLE ALL FK CONSTRAINTS --
-- -------------------------------- --

alter table "ALF_TRANSACTION" disable constraint "FKB8761A3A9AE340B7";
alter table "ALF_STORE" disable constraint "FKBD4FF53D22DBA5BA";
alter table "ALF_NODE_STATUS" disable constraint "FK71C2002B7F2C8017";
alter table "ALF_NODE_STATUS" disable constraint "FK71C2002B9E57C13D";
alter table "ALF_NODE_PROPERTIES" disable constraint "FK7D4CF8EC40E780DC";
alter table "ALF_NODE_PROPERTIES" disable constraint "FK7D4CF8EC7F2C8017";
alter table "ALF_NODE_ASSOC" disable constraint "FKE1A550BCA8FC7769";
alter table "ALF_NODE_ASSOC" disable constraint "FKE1A550BCB69C43F3";
alter table "ALF_NODE_ASPECTS" disable constraint "FKD654E027F2C8017";
alter table "ALF_NODE" disable constraint "FK60EFB626D24ADD25";
alter table "ALF_NODE" disable constraint "FK60EFB626B9553F6C";
alter table "ALF_MAP_ATTRIBUTE_ENTRIES" disable constraint "FK335CAE26AEAC208C";
alter table "ALF_MAP_ATTRIBUTE_ENTRIES" disable constraint "FK335CAE262C5AB86C";
alter table "ALF_LIST_ATTRIBUTE_ENTRIES" disable constraint "FKC7D52FB02C5AB86C";
alter table "ALF_LIST_ATTRIBUTE_ENTRIES" disable constraint "FKC7D52FB0ACD8822C";
alter table "ALF_GLOBAL_ATTRIBUTES" disable constraint "FK64D0B9CF69B9F16A";
alter table "ALF_CHILD_ASSOC" disable constraint "FKFFC5468E8E50E582";
alter table "ALF_CHILD_ASSOC" disable constraint "FKFFC5468E74173FF4";
alter table "ALF_AUTH_EXT_KEYS" disable constraint "FK8A749A657B7FDE43";
alter table "ALF_ATTRIBUTES" disable constraint "FK_ATTRIBUTES_N_ACL";          -- (optional)
alter table "ALF_ATTRIBUTES" disable constraint "FK_ATTR_N_ACL";                -- (optional)
alter table "ALF_ACCESS_CONTROL_ENTRY" disable constraint "FKFFF41F99B9553F6C";
alter table "ALF_ACCESS_CONTROL_ENTRY" disable constraint "FKFFF41F99B25A50BF";
alter table "ALF_ACCESS_CONTROL_ENTRY" disable constraint "FKFFF41F9960601995";


CREATE TABLE alf_acl_change_set (
   id NUMBER(19,0) NOT NULL,
   version NUMBER(19,0) NOT NULL,
   PRIMARY KEY (id)
);


-- Add to ACL
ALTER TABLE alf_access_control_list ADD (
   type NUMBER(10,0) DEFAULT 0 NOT NULL,
   latest NUMBER(1,0) DEFAULT 1 NOT NULL,
   acl_id VARCHAR2(36 CHAR) DEFAULT 'UNSET' NOT NULL,
   acl_version NUMBER(19,0) DEFAULT 1 NOT NULL,
   inherited_acl NUMBER(19,0),
   is_versioned NUMBER(1,0) DEFAULT 0 NOT NULL,
   requires_version NUMBER(1,0) DEFAULT 0 NOT NULL,
   acl_change_set NUMBER(19,0),
   inherits_from NUMBER(19,0)
);
CREATE INDEX fk_alf_acl_acs ON alf_access_control_list (acl_change_set);
ALTER TABLE alf_access_control_list ADD CONSTRAINT fk_alf_acl_acs FOREIGN KEY (acl_change_set) REFERENCES alf_acl_change_set (id);
CREATE INDEX idx_alf_acl_inh ON alf_access_control_list (inherits, inherits_from);

UPDATE alf_access_control_list acl
   set acl_id = (acl.id);

ALTER TABLE alf_access_control_list
   ADD UNIQUE (acl_id, latest, acl_version);

-- Create ACL member list
CREATE TABLE alf_acl_member (
   id NUMBER(19,0) NOT NULL,
   version NUMBER(19,0) NOT NULL,
   acl_id NUMBER(19,0) NOT NULL,
   ace_id NUMBER(19,0) NOT NULL,
   pos NUMBER(10,0) NOT NULL,
   primary key (id),
   unique (acl_id, ace_id, pos)
);


ALTER TABLE alf_access_control_entry DROP UNIQUE (acl_id, permission_id, authority_id);

-- Extend ACE
-- not required from 2.1-A
--  auth_id NUMBER(19,0) DEFAULT -1 NOT NULL,
ALTER TABLE alf_access_control_entry ADD (
   applies NUMBER(10,0) DEFAULT 0 NOT NULL,
   context_id NUMBER(19,0)
);

-- remove unused
DROP TABLE alf_auth_ext_keys;

-- remove authority constraint
DROP INDEX FKFFF41F99B25A50BF;
ALTER TABLE alf_access_control_entry DROP CONSTRAINT FKFFF41F99B25A50BF; -- (optional)

-- not required from 2.1-A
-- restructure authority
-- ALTER TABLE alf_authority DROP PRIMARY KEY;
-- ALTER TABLE alf_authority ADD (
--   id number(19,0) DEFAULT 0 NOT NULL,
--   crc NUMBER(19,0)
-- );
-- UPDATE alf_authority SET id = hibernate_sequence.nextval;
-- ALTER TABLE alf_authority RENAME COLUMN recipient TO authority;
-- ALTER TABLE alf_authority MODIFY (
--   authority VARCHAR(100 char) NULL
-- );
-- ALTER TABLE alf_authority ADD PRIMARY KEY (id);
-- ALTER TABLE alf_authority ADD UNIQUE (authority, crc);
-- CREATE INDEX idx_alf_auth_aut on alf_authority (authority);

-- ------------------------------------------------- --
-- Ensure stats are up to date on all schema objects --
-- ------------------------------------------------- --
begin dbms_stats.gather_schema_stats(ownname => user, options => 'GATHER AUTO', estimate_percent => dbms_stats.auto_sample_size); end;;

-- migrate data - fix up FK refs to authority
-- UPDATE alf_access_control_entry ace
--    SET auth_id = (SELECT id FROM alf_authority a WHERE a.authority = ace.authority_id);


-- migrate data - build equivalent ACL entries
INSERT INTO alf_acl_member (id, version, acl_id, ace_id, pos)
   select hibernate_sequence.nextval, 1, acl_id, id, 0 from alf_access_control_entry;

-- Create ACE context
CREATE TABLE alf_ace_context (
   id NUMBER(19,0) NOT NULL,
   version NUMBER(19,0) NOT NULL,
   class_context VARCHAR2(1024 CHAR),
   property_context VARCHAR2(1024 CHAR),
   kvp_context VARCHAR2(1024 CHAR),
   PRIMARY KEY (id)
);


-- Create auth aliases table
CREATE TABLE alf_authority_alias (
    id NUMBER(19,0) NOT NULL,
    version NUMBER(19,0) NOT NULL,
    auth_id NUMBER(19,0) NOT NULL,
    alias_id NUMBER(19,0) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (auth_id, alias_id)
);
CREATE INDEX fk_alf_autha_ali ON alf_authority_alias (alias_id);
ALTER TABLE alf_authority_alias ADD CONSTRAINT fk_alf_autha_ali FOREIGN KEY (alias_id) REFERENCES alf_authority (id);
CREATE INDEX fk_alf_autha_aut ON alf_authority_alias (auth_id);
ALTER TABLE alf_authority_alias ADD CONSTRAINT fk_alf_autha_aut FOREIGN KEY (auth_id) REFERENCES alf_authority (id);


-- Tidy up unused cols on ace table and add the FK contstraint back
-- finish take out of ACL_ID
DROP INDEX FKFFF41F99B9553F6C;
ALTER TABLE alf_access_control_entry DROP CONSTRAINT FKFFF41F99B9553F6C;
DROP INDEX FKFFF41F9960601995;
ALTER TABLE alf_access_control_entry DROP CONSTRAINT FKFFF41F9960601995;
-- not required from 2.1-A TO 3.1
-- authority_id
ALTER TABLE alf_access_control_entry DROP (
   acl_id
);
-- not required from 2.1-A to 3.1
-- ALTER TABLE alf_access_control_entry RENAME COLUMN auth_id TO authority_id;
CREATE INDEX fk_alf_ace_auth ON alf_access_control_entry (authority_id);
ALTER TABLE alf_access_control_entry ADD CONSTRAINT fk_alf_ace_auth FOREIGN KEY (authority_id) REFERENCES alf_authority (id);
CREATE INDEX fk_alf_ace_perm ON alf_access_control_entry (permission_id);
ALTER TABLE alf_access_control_entry ADD CONSTRAINT fk_alf_ace_perm FOREIGN KEY (permission_id) REFERENCES alf_permission (id);
CREATE INDEX fk_alf_ace_ctx ON alf_access_control_entry (context_id);
ALTER TABLE alf_access_control_entry ADD CONSTRAINT fk_alf_ace_ctx FOREIGN KEY (context_id) REFERENCES alf_ace_context (id);
   

-- ------------------------------------------------- --
-- Ensure stats are up to date on all schema objects --
-- ------------------------------------------------- --
begin dbms_stats.gather_schema_stats(ownname => user, options => 'GATHER AUTO', estimate_percent => dbms_stats.auto_sample_size); end;;

CREATE TABLE NSI_ACE_TEMP AS 
SELECT CAST(min(ace1.id) AS NUMBER(19)) as id, ace1.version as version, ace1.permission_id, ace1.allowed, ace1.authority_id, ace1.applies, ace1.context_id 
FROM alf_access_control_entry ace1
GROUP BY ace1.permission_id, ace1.authority_id, ace1.allowed, ace1.applies, ace1.context_id, ace1.version;

UPDATE alf_acl_member mem
   SET ace_id = (SELECT min(ace1.id) FROM nsi_ace_temp ace1 
                     JOIN alf_access_control_entry ace2 
                             ON ace1.permission_id = ace2.permission_id AND
                                ace1.authority_id = ace2.authority_id AND 
                                ace1.allowed = ace2.allowed AND 
                                ace1.applies = ace2.applies 
                     WHERE ace2.id = mem.ace_id  );

CREATE INDEX fk_alf_aclm_acl ON alf_acl_member (acl_id);
CREATE INDEX fk_alf_aclm_ace ON alf_acl_member (ace_id);

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


-- Add constraint for duplicate acls
ALTER TABLE alf_access_control_entry
   ADD UNIQUE (permission_id, authority_id, allowed, applies, context_id);

   
ALTER TABLE alf_acl_member ADD CONSTRAINT fk_alf_aclm_acl FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id);
ALTER TABLE alf_acl_member ADD CONSTRAINT fk_alf_aclm_ace FOREIGN KEY (ace_id) REFERENCES alf_access_control_entry (id);


-- ------------------------------- --
-- NSI - ENABLE ALL FK CONSTRAINTS --
-- ------------------------------- --

alter table "ALF_TRANSACTION" enable constraint "FKB8761A3A9AE340B7";
alter table "ALF_STORE" enable constraint "FKBD4FF53D22DBA5BA";
alter table "ALF_NODE_STATUS" enable constraint "FK71C2002B7F2C8017";
alter table "ALF_NODE_STATUS" enable constraint "FK71C2002B9E57C13D";
alter table "ALF_NODE_PROPERTIES" enable constraint "FK7D4CF8EC40E780DC";
alter table "ALF_NODE_PROPERTIES" enable constraint "FK7D4CF8EC7F2C8017";
alter table "ALF_NODE_ASSOC" enable constraint "FKE1A550BCA8FC7769";
alter table "ALF_NODE_ASSOC" enable constraint "FKE1A550BCB69C43F3";
alter table "ALF_NODE_ASPECTS" enable constraint "FKD654E027F2C8017";
alter table "ALF_NODE" enable constraint "FK60EFB626D24ADD25";
alter table "ALF_NODE" enable constraint "FK60EFB626B9553F6C";
alter table "ALF_MAP_ATTRIBUTE_ENTRIES" enable constraint "FK335CAE26AEAC208C";
alter table "ALF_MAP_ATTRIBUTE_ENTRIES" enable constraint "FK335CAE262C5AB86C";
alter table "ALF_LIST_ATTRIBUTE_ENTRIES" enable constraint "FKC7D52FB02C5AB86C";
alter table "ALF_LIST_ATTRIBUTE_ENTRIES" enable constraint "FKC7D52FB0ACD8822C";
alter table "ALF_GLOBAL_ATTRIBUTES" enable constraint "FK64D0B9CF69B9F16A";
alter table "ALF_CHILD_ASSOC" enable constraint "FKFFC5468E8E50E582";
alter table "ALF_CHILD_ASSOC" enable constraint "FKFFC5468E74173FF4";
alter table "ALF_ATTRIBUTES" enable constraint "FK_ATTRIBUTES_N_ACL";           -- (optional)
alter table "ALF_ATTRIBUTES" enable constraint "FK_ATTR_N_ACL";                 -- (optional)


-- ------------------------------------------------- --
-- Ensure stats are up to date on all schema objects --
-- ------------------------------------------------- --
begin dbms_stats.gather_schema_stats(ownname => user, options => 'GATHER AUTO', estimate_percent => dbms_stats.auto_sample_size); end;;
   
--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V2.2-ACL-From-2.1-A';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V2.2-ACL-From-2.1-A', 'Manually executed script upgrade V2.2: Update acl schema',
    0, 82, -1, 120, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );
