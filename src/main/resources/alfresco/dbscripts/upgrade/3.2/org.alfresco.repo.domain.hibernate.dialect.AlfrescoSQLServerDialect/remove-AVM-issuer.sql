--
-- Title:      Upgrade to V3.2 - Remove AVM Issuer 
-- Database:   SQL Server
-- Since:      V3.2 schema 2008
-- Author:     janv
--
-- remove AVM node issuer - replace with identity id
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

-- -----------------------------
-- Enable identity --
-- -----------------------------

ALTER TABLE avm_nodes DROP CONSTRAINT fk_avm_n_acl;
ALTER TABLE avm_nodes DROP CONSTRAINT fk_avm_n_store;

CREATE TABLE t_avm_nodes (
   id numeric(19,0) identity NOT NULL,
   class_type nvarchar(20) NOT NULL,
   vers numeric(19,0) NOT NULL,
   version_id int NOT NULL,
   guid nvarchar(36) NULL,
   creator nvarchar(255) NOT NULL,
   owner nvarchar(255) NOT NULL,
   lastModifier nvarchar(255) NOT NULL,
   createDate numeric(19, 0) NOT NULL,
   modDate numeric(19, 0) NOT NULL,
   accessDate numeric(19, 0) NOT NULL,
   is_root tinyint NULL,
   store_new_id numeric(19, 0) NULL,
   acl_id numeric(19, 0) NULL,
   deletedType int NULL,
   layer_id numeric(19, 0) NULL,
   indirection nvarchar(511) NULL,
   indirection_version int NULL,
   primary_indirection tinyint NULL,
   opacity tinyint NULL,
   content_url nvarchar(128) NULL,
   mime_type nvarchar(64) NULL,
   encoding nvarchar(16) NULL,
   length numeric(19, 0) NULL,
   PRIMARY KEY (id),
   CONSTRAINT fk_avm_n_acl FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id),
   CONSTRAINT fk_avm_n_store FOREIGN KEY (store_new_id) REFERENCES avm_stores (id)
 );

CREATE INDEX fk_avm_n_acl ON t_avm_nodes (acl_id);
CREATE INDEX fk_avm_n_store ON t_avm_nodes (store_new_id);

-- migrate data 

SET IDENTITY_INSERT t_avm_nodes ON;

INSERT INTO t_avm_nodes ( 
   id, class_type, vers, version_id, guid, creator, owner, lastModifier, createDate, modDate, accessDate,
   is_root, store_new_id, acl_id, deletedType, layer_id, indirection, indirection_version,
   primary_indirection, opacity, content_url, mime_type, encoding, length 
   )
SELECT
   id, class_type, vers, version_id, guid, creator, owner, lastModifier, createDate, modDate, accessDate,
   is_root, store_new_id, acl_id, deletedType, layer_id, indirection, indirection_version,
   primary_indirection, opacity, content_url, mime_type, encoding, length
FROM avm_nodes WHERE avm_nodes.id != 0;

SET IDENTITY_INSERT t_avm_nodes OFF;

INSERT INTO t_avm_nodes ( 
   class_type, vers, version_id, guid, creator, owner, lastModifier, createDate, modDate, accessDate,
   is_root, store_new_id, acl_id, deletedType, layer_id, indirection, indirection_version,
   primary_indirection, opacity, content_url, mime_type, encoding, length 
   )
SELECT
   class_type, vers, version_id, guid, creator, owner, lastModifier, createDate, modDate, accessDate,
   is_root, store_new_id, acl_id, deletedType, layer_id, indirection, indirection_version,
   primary_indirection, opacity, content_url, mime_type, encoding, length
FROM avm_nodes WHERE avm_nodes.id = 0;

-- drop existing foreign keys

ALTER TABLE avm_aspects DROP CONSTRAINT fk_avm_nasp_n;
ALTER TABLE avm_child_entries DROP CONSTRAINT fk_avm_ce_child;
ALTER TABLE avm_child_entries DROP CONSTRAINT fk_avm_ce_parent;
ALTER TABLE avm_history_links DROP CONSTRAINT fk_avm_hl_ancestor;
ALTER TABLE avm_history_links DROP CONSTRAINT fk_avm_hl_desc;
ALTER TABLE avm_merge_links DROP CONSTRAINT fk_avm_ml_from;
ALTER TABLE avm_merge_links DROP CONSTRAINT fk_avm_ml_to;
ALTER TABLE avm_node_properties DROP CONSTRAINT fk_avm_nprop_n;
ALTER TABLE avm_stores DROP CONSTRAINT fk_avm_s_root;
ALTER TABLE avm_version_roots DROP CONSTRAINT fk_avm_vr_root;

-- switch tables
DROP TABLE avm_nodes;
EXEC sp_rename 't_avm_nodes', 'avm_nodes';

update avm_aspects set node_id = (select max(id) from avm_nodes) where node_id = 0;
update avm_child_entries set parent_id = (select max(id) from avm_nodes) where parent_id = 0;
update avm_child_entries set child_id = (select max(id) from avm_nodes) where child_id = 0;
update avm_history_links set ancestor = (select max(id) from avm_nodes) where ancestor = 0;
update avm_history_links set descendent = (select max(id) from avm_nodes) where descendent = 0;
update avm_merge_links set mfrom = (select max(id) from avm_nodes) where mfrom = 0;
update avm_merge_links set mto = (select max(id) from avm_nodes) where mto = 0;
update avm_node_properties set node_id = (select max(id) from avm_nodes) where node_id = 0;
update avm_stores set current_root_id = (select max(id) from avm_nodes) where current_root_id = 0;
update avm_version_roots set root_id = (select max(id) from avm_nodes) where root_id = 0;

-- recreate foreign keys

ALTER TABLE avm_aspects ADD CONSTRAINT fk_avm_nasp_n FOREIGN KEY (node_id) REFERENCES avm_nodes (id);
ALTER TABLE avm_child_entries  ADD CONSTRAINT fk_avm_ce_child FOREIGN KEY (child_id) REFERENCES avm_nodes (id);
ALTER TABLE avm_child_entries  ADD CONSTRAINT fk_avm_ce_parent FOREIGN KEY (parent_id) REFERENCES avm_nodes (id);
ALTER TABLE avm_history_links ADD CONSTRAINT fk_avm_hl_ancestor FOREIGN KEY (ancestor) REFERENCES avm_nodes (id);
ALTER TABLE avm_history_links ADD CONSTRAINT fk_avm_hl_desc FOREIGN KEY (descendent) REFERENCES avm_nodes (id);
ALTER TABLE avm_merge_links ADD CONSTRAINT fk_avm_ml_from FOREIGN KEY (mfrom) REFERENCES avm_nodes (id);
ALTER TABLE avm_merge_links ADD CONSTRAINT fk_avm_ml_to FOREIGN KEY (mto) REFERENCES avm_nodes (id);
ALTER TABLE avm_node_properties ADD CONSTRAINT fk_avm_nprop_n FOREIGN KEY (node_id) REFERENCES avm_nodes (id);
ALTER TABLE avm_stores ADD CONSTRAINT fk_avm_s_root FOREIGN KEY (current_root_id) REFERENCES avm_nodes (id);
ALTER TABLE avm_version_roots ADD CONSTRAINT fk_avm_vr_root FOREIGN KEY (root_id) REFERENCES avm_nodes (id);

-- drop issuer table

DROP TABLE avm_issuer_ids;

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.2-Remove-AVM-Issuer';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.2-Remove-AVM-Issuer', 'Manually executed script upgrade V3.2 to remove AVM Issuer',
     0, 2007, -1, 2008, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
   );
