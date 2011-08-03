--
-- Title:      Clean duplicate alf_node_status entries
-- Database:   Oracle
-- Since:      V3.1 schema 1011
-- Author:     Derek Hulley
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- Cleans out duplicate alf_node_status entries for V2.1 installations.
-- This script does not need to run if the server has already been upgraded to schema 90 or later

CREATE TABLE t_node_status_cnt
   (
      node_id NUMBER(19,0),
      count NUMBER(10,0),
      PRIMARY KEY (node_id)
   );
INSERT INTO t_node_status_cnt
   (
      SELECT n.id, count(ns.node_id) FROM alf_node n join alf_node_status ns on (ns.node_id = n.id) group by n.id
   );
CREATE TABLE t_node_status
   (
      node_id NUMBER(19,0),
      transaction_id NUMBER(19,0),
      PRIMARY KEY (node_id)
   );
INSERT INTO t_node_status
   (
      SELECT cnt.node_id, -1 FROM t_node_status_cnt cnt WHERE cnt.count > 1
   );
UPDATE t_node_status t set t.transaction_id =
   (
      SELECT max(transaction_id) FROM alf_node_status WHERE node_id = t.node_id
   );
DELETE FROM alf_node_status WHERE node_id in (SELECT node_id FROM t_node_status);
INSERT INTO alf_node_status (protocol, identifier, guid, node_id, transaction_id, version)
   (
      SELECT n.protocol, n.identifier, n.uuid, n.id, tns.transaction_id, 0 FROM t_node_status tns join alf_node n on (n.id = tns.node_id)
   );

DROP TABLE t_node_status;
DROP TABLE t_node_status_cnt;

DELETE FROM alf_node_status WHERE node_id is null;

UPDATE alf_node_status ns set ns.protocol =
  (
    SELECT n.protocol FROM alf_node n WHERE n.id = ns.node_id
  );

DELETE FROM alf_transaction WHERE id not in (SELECT transaction_id FROM alf_node_status);

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V2.2-CleanNodeStatuses';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V2.2-CleanNodeStatuses', 'Manually executed script upgrade V2.2: Clean alf_node_status table',
     0, 89, -1, 90, null, 'UNKOWN', ${true}, ${true}, 'Script completed'
   );
