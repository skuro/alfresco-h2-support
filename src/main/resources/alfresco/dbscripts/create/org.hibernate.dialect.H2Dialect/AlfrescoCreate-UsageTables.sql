-- Copyright (c) 2011 Carlo Sciolla
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
-- and associated documentation files (the "Software"), to deal in the Software without restriction, 
-- including without limitation the rights to use, copy, modify, merge, publish, distribute, 
-- sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
-- is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
-- BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
-- DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
--
-- Title:      User usage tables
-- Database:   PostgreSQL
-- Since:      V3.4 Schema 4110
-- Author:     Derek Hulley
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

CREATE SEQUENCE alf_usage_delta_seq START WITH 1 INCREMENT BY 1; -- (optional)
CREATE TABLE alf_usage_delta
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    node_id INT8 NOT NULL,
    delta_size INT8 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_usaged_n FOREIGN KEY (node_id) REFERENCES alf_node (id)
); -- (optional)
CREATE INDEX fk_alf_usaged_n ON alf_usage_delta (node_id); -- (optional)

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.4-UsageTables';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.4-UsageTables', 'Manually executed script upgrade V3.4: Usage Tables',
    0, 113, -1, 114, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );
