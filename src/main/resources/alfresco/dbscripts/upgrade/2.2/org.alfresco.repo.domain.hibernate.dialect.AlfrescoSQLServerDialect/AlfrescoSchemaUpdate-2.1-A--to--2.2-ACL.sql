--
-- Title:      Update for permissions schema changes
-- Database:   MS SQL
-- Since:      V2.2 Schema 85
-- Author:     
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

create table alf_acl_change_set (
	id numeric(19,0) identity not null,
	version numeric(19,0) not null,
	primary key (id)
);

-- Add to ACL
alter table alf_access_control_list add
	acl_id nvarchar(36) not null default 'UNSET',
	latest smallint not null default 1,
	acl_version numeric(19,0) not null default 1,
	inherits_from numeric(19,0),
	type integer not null default 0,
	inherited_acl numeric(19,0),
	is_versioned smallint not null default 0,
	requires_version smallint not null default 0,
	acl_change_set numeric(19,0);

create index fk_alf_acl_acs on alf_access_control_list (acl_change_set);
alter table alf_access_control_list add constraint fk_alf_acl_acs foreign key (acl_change_set) references alf_acl_change_set (id);
create index idx_alf_acl_inh on alf_access_control_list (inherits, inherits_from);

update alf_access_control_list set acl_id = id;

alter table alf_access_control_list add constraint fk_alf_acl_unique unique ( acl_id, latest, acl_version) ;

-- Create ACL member list
create table alf_acl_member (
	id numeric(19,0) identity not null,
	version numeric(19,0) not null,
	acl_id numeric(19,0) not null,
	ace_id numeric(19,0) not null,
	pos integer not null,
	primary key (id),
	unique (acl_id, ace_id, pos)
);

create index fk_alf_aclm_acl on alf_acl_member (acl_id);
alter table alf_acl_member add constraint fk_alf_aclm_acl foreign key (acl_id) references alf_access_control_list (id);
create index fk_alf_aclm_ace on alf_acl_member (ace_id);

-- Create ACE context
create table alf_ace_context ( 
	id numeric(19,0) identity not null,
	version numeric(19,0) not null,
	class_context nvarchar(1024),
	property_context nvarchar(1024),
	kvp_context nvarchar(1024),
	primary key (id)
);

-- migrate data - build equivalent ACL entries
insert into alf_acl_member (version, acl_id, ace_id, pos) select 1, ace.acl_id, ace.id, 0 from alf_access_control_entry ace join alf_access_control_list acl on acl.id = ace.acl_id;

-- Extend ACE
create table t_alf_access_control_entry (
	id numeric(19,0) identity not null,
	version numeric(19,0) not null,
	permission_id numeric(19,0) not null,
	authority_id numeric(19,0) not null,
	allowed smallint not null,
	applies integer not null default 0,
	context_id numeric(19,0),
	primary key (id));

set identity_insert t_alf_access_control_entry on;
insert into t_alf_access_control_entry (id, version, permission_id, allowed, authority_id) select ace.id, ace.version, ace.permission_id, ace.allowed, ace.authority_id from alf_access_control_entry ace;
set identity_insert t_alf_access_control_entry off;
drop table alf_access_control_entry;
exec sp_rename t_alf_access_control_entry, alf_access_control_entry;

alter table alf_acl_member add constraint fk_alf_aclm_ace foreign key (ace_id) references alf_access_control_entry;

create index fk_alf_ace_auth on alf_access_control_entry (authority_id);
create index fk_alf_ace_ctx on alf_access_control_entry (context_id);
create index fk_alf_ace_perm on alf_access_control_entry (permission_id);

-- remove unused
drop table alf_auth_ext_keys;

alter table alf_access_control_entry add constraint fk_alf_ace_auth foreign key (authority_id) references alf_authority;
alter table alf_access_control_entry add constraint fk_alf_ace_ctx foreign key (context_id) references alf_ace_context;

-- Create auth aliases table
create table alf_authority_alias ( 
	id numeric(19,0) identity not null,
	version numeric(19,0) not null,
	auth_id numeric(19,0) not null,
	alias_id numeric(19,0) not null,
	primary key (id),
	unique (auth_id, alias_id)
);
create index fk_alf_autha_ali on alf_authority_alias (alias_id);
alter table alf_authority_alias add constraint fk_alf_autha_ali foreign key (alias_id) references alf_authority (id);
create index fk_alf_autha_aut on alf_authority_alias (auth_id);
alter table alf_authority_alias add constraint fk_alf_autha_aut foreign key (auth_id) references alf_authority (id);

update alf_acl_member set ace_id = (select min(ace2.id) from alf_access_control_entry ace1 join alf_access_control_entry ace2 on ace1.permission_id = ace2.permission_id and ace1.authority_id = ace2.authority_id and ace1.allowed = ace2.allowed and ace1.applies = ace2.applies where ace1.id = alf_acl_member.ace_id  );

create table tmp_to_delete ( 
	id numeric(19,0) not null,
	primary key (id)
);

insert into tmp_to_delete select ace.id from alf_acl_member mem right outer join alf_access_control_entry ace on mem.ace_id = ace.id where mem.ace_id is null;
delete from alf_access_control_entry where id in (select id from tmp_to_delete);
drop table tmp_to_delete;

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
