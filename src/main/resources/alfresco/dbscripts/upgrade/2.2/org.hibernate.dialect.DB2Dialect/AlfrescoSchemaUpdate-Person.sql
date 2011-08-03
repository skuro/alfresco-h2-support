--
-- Title:      Move user name to be part of the association QNAME
-- Database:   DB2
-- Since:      V2.1.a Schema 81
-- Author:     
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- Path was previously unused and unindex - new we use it the index is required.

UPDATE ALF_CHILD_ASSOC SET QNAME_NS_ID = ( SELECT ID FROM ALF_NAMESPACE N WHERE N.URI = 'http://www.alfresco.org/model/content/1.0'), QNAME_LOCALNAME = ( SELECT LOWER(P.STRING_VALUE) FROM ALF_NODE_PROPERTIES P JOIN ALF_QNAME Q ON P.QNAME_ID = Q.ID JOIN ALF_NAMESPACE N ON Q.NS_ID = N.ID WHERE P.NODE_ID = ALF_CHILD_ASSOC.CHILD_NODE_ID AND Q.LOCAL_NAME ='userName' AND N.URI = 'http://www.alfresco.org/model/content/1.0' ) WHERE EXISTS ( SELECT 0 FROM ALF_NODE_PROPERTIES PP JOIN ALF_QNAME QQ ON PP.QNAME_ID = QQ.ID JOIN ALF_NAMESPACE NN ON QQ.NS_ID = NN.ID WHERE PP.NODE_ID = ALF_CHILD_ASSOC.CHILD_NODE_ID AND QQ.LOCAL_NAME ='userName' AND NN.URI = 'http://www.alfresco.org/model/content/1.0' );

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V2.2-Person-3';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V2.2-Person-3', 'Manually executed script upgrade V2.2: Person user name also in the association qname',
    0, 1007, -1, 1008, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );