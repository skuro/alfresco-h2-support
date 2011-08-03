--
-- Title:      Update for permissions schema changes
-- Database:   DB2
-- Since:      V2.1.a Schema 81
-- Author:     
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

CREATE TABLE ALF_ACL_CHANGE_SET ( 
	ID BIGINT GENERATED BY DEFAULT AS IDENTITY, 
	VERSION BIGINT NOT NULL, 
	PRIMARY KEY (ID) 
);

-- Add to ACL
ALTER TABLE ALF_ACCESS_CONTROL_LIST 
	ADD COLUMN ACL_ID VARCHAR(36) NOT NULL DEFAULT 'UNSET' 
	ADD COLUMN LATEST SMALLINT NOT NULL DEFAULT 1 
	ADD COLUMN ACL_VERSION BIGINT NOT NULL DEFAULT 1 
	ADD COLUMN INHERITS_FROM BIGINT 
	ADD COLUMN TYPE INTEGER NOT NULL DEFAULT 0 
	ADD COLUMN INHERITED_ACL BIGINT 
	ADD COLUMN IS_VERSIONED SMALLINT NOT NULL DEFAULT 0 
	ADD COLUMN REQUIRES_VERSION SMALLINT NOT NULL DEFAULT 0 
	ADD COLUMN ACL_CHANGE_SET BIGINT;

CREATE INDEX FK_ALF_ACL_ACS ON ALF_ACCESS_CONTROL_LIST (ACL_CHANGE_SET);
ALTER TABLE ALF_ACCESS_CONTROL_LIST ADD CONSTRAINT FK_ALF_ACL_ACS FOREIGN KEY (ACL_CHANGE_SET) REFERENCES ALF_ACL_CHANGE_SET (ID);
CREATE INDEX IDX_ALF_ACL_INH ON ALF_ACCESS_CONTROL_LIST (INHERITS, INHERITS_FROM);

UPDATE ALF_ACCESS_CONTROL_LIST SET ACL_ID = CAST(CHAR(ID) AS VARCHAR(36));

ALTER TABLE ALF_ACCESS_CONTROL_LIST ADD CONSTRAINT FK_ALF_ACL_UNIQUE UNIQUE ( ACL_ID, LATEST, ACL_VERSION) ;

-- Create ACL member list
CREATE TABLE ALF_ACL_MEMBER ( 
	ID BIGINT GENERATED BY DEFAULT AS IDENTITY, 
	VERSION BIGINT NOT NULL, 
	ACL_ID BIGINT NOT NULL, 
	ACE_ID BIGINT NOT NULL, 
	POS INTEGER NOT NULL, 
	PRIMARY KEY (ID), 
	UNIQUE (ACL_ID, ACE_ID, POS) 
);

CREATE INDEX FK_ALF_ACLM_ACL ON ALF_ACL_MEMBER (ACL_ID);
ALTER TABLE ALF_ACL_MEMBER ADD CONSTRAINT FK_ALF_ACLM_ACL FOREIGN KEY (ACL_ID) REFERENCES ALF_ACCESS_CONTROL_LIST (ID);
CREATE INDEX FK_ALF_ACLM_ACE ON ALF_ACL_MEMBER (ACE_ID);

-- Create ACE context
CREATE TABLE ALF_ACE_CONTEXT ( 
	ID BIGINT GENERATED BY DEFAULT AS IDENTITY, 
	VERSION BIGINT NOT NULL, 
	CLASS_CONTEXT VARCHAR(1024), 
	PROPERTY_CONTEXT VARCHAR(1024), 
	KVP_CONTEXT VARCHAR(1024), 
	PRIMARY KEY (ID) 
);

-- migrate data - build equivalent ACL entries
INSERT INTO ALF_ACL_MEMBER (VERSION, ACL_ID, ACE_ID, POS) SELECT 1, ace.ACL_ID, ace.ID, 0 FROM ALF_ACCESS_CONTROL_ENTRY ace join alf_access_control_list acl on acl.id = ace.acl_id;

CREATE TABLE t_alf_authority
(
	id BIGINT GENERATED BY DEFAULT AS IDENTITY,
	version BIGINT NOT NULL,
	authority VARCHAR(100),
	crc BIGINT,
	PRIMARY KEY(id)	
);

INSERT INTO t_alf_authority (version, authority) SELECT a.version, a.recipient FROM alf_authority a;
DROP TABLE alf_authority;
RENAME t_alf_authority TO alf_authority;
CREATE INDEX idx_alf_auth_aut ON alf_authority (authority);
CREATE UNIQUE INDEX authority ON alf_authority (authority, crc);

--ASSIGN:ace_max_id=next_val
select case when max(id) is not null then max(id)+1 else 1 end as next_val from ALF_ACCESS_CONTROL_ENTRY;

-- Extend ACE
CREATE TABLE T_ALF_ACCESS_CONTROL_ENTRY ( 
	ID BIGINT GENERATED BY DEFAULT AS IDENTITY (start with ${ace_max_id}), 
	VERSION BIGINT NOT NULL, 
	PERMISSION_ID BIGINT NOT NULL, 
	AUTHORITY_ID BIGINT NOT NULL DEFAULT -1, 
	ALLOWED SMALLINT NOT NULL, 
	APPLIES INTEGER NOT NULL DEFAULT 0, 
	CONTEXT_ID BIGINT, 
	PRIMARY KEY (ID) 
);

INSERT INTO T_ALF_ACCESS_CONTROL_ENTRY (ID, VERSION, PERMISSION_ID, ALLOWED, AUTHORITY_ID) SELECT ACE.ID, ACE.VERSION, ACE.PERMISSION_ID, ACE.ALLOWED, A.ID FROM ALF_ACCESS_CONTROL_ENTRY ACE, ALF_AUTHORITY A WHERE A.AUTHORITY = ACE.AUTHORITY_ID;
DROP TABLE ALF_ACCESS_CONTROL_ENTRY;
RENAME T_ALF_ACCESS_CONTROL_ENTRY TO ALF_ACCESS_CONTROL_ENTRY;
CREATE INDEX FK_ALF_ACE_AUTH ON ALF_ACCESS_CONTROL_ENTRY (AUTHORITY_ID);
CREATE INDEX FK_ALF_ACE_CTX ON ALF_ACCESS_CONTROL_ENTRY (CONTEXT_ID);
CREATE INDEX FK_ALF_ACE_PERM ON ALF_ACCESS_CONTROL_ENTRY (PERMISSION_ID);

-- remove unused
DROP TABLE ALF_AUTH_EXT_KEYS;

ALTER TABLE ALF_ACCESS_CONTROL_ENTRY ADD CONSTRAINT FK_ALF_ACE_AUTH FOREIGN KEY (AUTHORITY_ID) REFERENCES ALF_AUTHORITY;
CREATE INDEX FK_ALF_ACE_AUTH ON ALF_ACCESS_CONTROL_ENTRY (AUTHORITY_ID);
ALTER TABLE ALF_ACCESS_CONTROL_ENTRY ADD CONSTRAINT FK_ALF_ACE_CTX FOREIGN KEY (CONTEXT_ID) REFERENCES ALF_ACE_CONTEXT;
CREATE INDEX FK_ALF_ACE_CTX ON ALF_ACCESS_CONTROL_ENTRY (CONTEXT_ID);
ALTER TABLE ALF_ACCESS_CONTROL_ENTRY ADD CONSTRAINT FK_ALF_ACE_PERM FOREIGN KEY (PERMISSION_ID) REFERENCES ALF_PERMISSION;
CREATE INDEX FK_ALF_ACE_PERM ON ALF_ACCESS_CONTROL_ENTRY (PERMISSION_ID);

--add constarints
alter table alf_acl_member add constraint fk_alf_aclm_ace foreign key (ace_id) references alf_access_control_entry;

-- Create auth aliases table
CREATE TABLE ALF_AUTHORITY_ALIAS ( 
	ID BIGINT GENERATED BY DEFAULT AS IDENTITY, 
	VERSION BIGINT NOT NULL, 
	AUTH_ID BIGINT NOT NULL, 
	ALIAS_ID BIGINT NOT NULL, 
	PRIMARY KEY (ID), 
	UNIQUE (AUTH_ID, ALIAS_ID) 
);
CREATE INDEX FK_ALF_AUTHA_ALI ON ALF_AUTHORITY_ALIAS (ALIAS_ID);
ALTER TABLE ALF_AUTHORITY_ALIAS ADD CONSTRAINT FK_ALF_AUTHA_ALI FOREIGN KEY (ALIAS_ID) REFERENCES ALF_AUTHORITY (ID);
CREATE INDEX FK_ALF_AUTHA_AUT ON ALF_AUTHORITY_ALIAS (AUTH_ID);
ALTER TABLE ALF_AUTHORITY_ALIAS ADD CONSTRAINT FK_ALF_AUTHA_AUT FOREIGN KEY (AUTH_ID) REFERENCES ALF_AUTHORITY (ID);

UPDATE ALF_ACL_MEMBER MEM SET ACE_ID = (SELECT MIN(ACE2.ID) FROM ALF_ACCESS_CONTROL_ENTRY ACE1 JOIN ALF_ACCESS_CONTROL_ENTRY ACE2 ON ACE1.PERMISSION_ID = ACE2.PERMISSION_ID AND ACE1.AUTHORITY_ID = ACE2.AUTHORITY_ID AND ACE1.ALLOWED = ACE2.ALLOWED AND ACE1.APPLIES = ACE2.APPLIES WHERE ACE1.ID = MEM.ACE_ID  );

CREATE TABLE TMP_TO_DELETE ( 
	ID BIGINT NOT NULL, 
	PRIMARY KEY (ID)
);

INSERT INTO TMP_TO_DELETE ( SELECT ACE.ID FROM ALF_ACL_MEMBER MEM RIGHT OUTER JOIN ALF_ACCESS_CONTROL_ENTRY ACE ON MEM.ACE_ID = ACE.ID WHERE MEM.ACE_ID IS NULL);
DELETE FROM ALF_ACCESS_CONTROL_ENTRY ACE WHERE ACE.ID IN (SELECT ID FROM TMP_TO_DELETE);
DROP TABLE TMP_TO_DELETE;

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V2.2-ACL';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V2.2-ACL', 'Manually executed script upgrade V2.2: Update acl schema',
    0, 119, -1, 120, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );