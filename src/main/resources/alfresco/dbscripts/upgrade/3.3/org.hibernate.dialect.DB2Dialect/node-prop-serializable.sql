--
-- Title:      Upgrade to V3.3
-- Database:   DB2
-- Since:      V3.3 schema 4106
-- Author:     janv
--
-- upgrade alf_node_properties.serializable
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- just change type in column from varchar(16384) to blob doesn't work. So have to create
-- temp table, copy values over, drop old table and rename temporary.
-- Oracle approach also doesn't work.

CREATE TABLE t_alf_node_properties
(
    node_id BIGINT NOT NULL,
    actual_type_n INTEGER NOT NULL,
    persisted_type_n INTEGER NOT NULL,
    boolean_value SMALLINT,
    long_value BIGINT,
    float_value FLOAT,
    double_value DOUBLE PRECISION,
    string_value VARCHAR(1024),
    serializable_value BLOB,
    qname_id BIGINT NOT NULL,
    list_index INTEGER NOT NULL,
    locale_id BIGINT NOT NULL,
    PRIMARY KEY (node_id, qname_id, list_index, locale_id)
);


INSERT INTO t_alf_node_properties
   (
      node_id, actual_type_n, persisted_type_n, boolean_value, long_value, float_value,
      double_value, string_value, serializable_value, qname_id, list_index, locale_id
   )
   SELECT 
      node_id, actual_type_n, persisted_type_n, boolean_value, long_value, float_value,
      double_value, string_value, serializable_value, qname_id, list_index, locale_id
   FROM 
      alf_node_properties;

DROP TABLE alf_node_properties;
RENAME t_alf_node_properties TO alf_node_properties;

--adding indexes 
CREATE INDEX fk_alf_nprop_n ON alf_node_properties (node_id);
CREATE INDEX fk_alf_nprop_qn ON alf_node_properties (qname_id);
CREATE INDEX fk_alf_nprop_loc ON alf_node_properties (locale_id);

-- adding constraints
ALTER TABLE alf_node_properties ADD CONSTRAINT fk_alf_nprop_loc FOREIGN KEY (locale_id) REFERENCES alf_locale (id);
ALTER TABLE alf_node_properties ADD CONSTRAINT fk_alf_nprop_n FOREIGN KEY (node_id) REFERENCES alf_node (id);
ALTER TABLE alf_node_properties ADD CONSTRAINT fk_alf_nprop_qn FOREIGN KEY (qname_id) REFERENCES alf_qname (id);

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.3-Node-Prop-Serializable';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.3-Node-Prop-Serializable', 'Manually executed script upgrade V3.3',
     0, 4105, -1, 4106, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
   );
