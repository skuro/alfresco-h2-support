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
--
-- Title:      Activity tables
-- Database:   PostgreSQL
-- Since:      V3.0 Schema 126
-- Author:     janv

CREATE SEQUENCE alf_activity_feed_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_activity_feed
(
    id INT8 NOT NULL,
    post_id INT8,
    post_date TIMESTAMP NOT NULL,
    activity_summary VARCHAR(1024),
    feed_user_id VARCHAR(255),
    activity_type VARCHAR(255) NOT NULL,
    activity_format VARCHAR(10),
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    post_user_id VARCHAR(255) NOT NULL,
    feed_date TIMESTAMP NOT NULL,
    PRIMARY KEY (id)
);
CREATE INDEX feed_postdate_idx ON alf_activity_feed (post_date);
CREATE INDEX feed_postuserid_idx ON alf_activity_feed (post_user_id);
CREATE INDEX feed_feeduserid_idx ON alf_activity_feed (feed_user_id);
CREATE INDEX feed_sitenetwork_idx ON alf_activity_feed (site_network);
CREATE INDEX feed_activityformat_idx ON alf_activity_feed (activity_format);

CREATE SEQUENCE alf_activity_feed_control_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_activity_feed_control
(
    id INT8 NOT NULL,
    feed_user_id VARCHAR(255) NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    last_modified TIMESTAMP NOT NULL,
    PRIMARY KEY (id)
);
CREATE INDEX feedctrl_feeduserid_idx ON alf_activity_feed_control (feed_user_id);

CREATE SEQUENCE alf_activity_post_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_activity_post
(
    sequence_id INT8 NOT NULL,
    post_date TIMESTAMP NOT NULL,
    status VARCHAR(10) NOT NULL,
    activity_data VARCHAR(1024) NOT NULL,
    post_user_id VARCHAR(255) NOT NULL,
    job_task_node INT4 NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    activity_type VARCHAR(255) NOT NULL,
    last_modified TIMESTAMP NOT NULL,
    PRIMARY KEY (sequence_id)
);
CREATE INDEX post_jobtasknode_idx ON alf_activity_post (job_task_node);
CREATE INDEX post_status_idx ON alf_activity_post (status);


--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.0-ActivityTables';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.0-ActivityTables', 'Manually executed script upgrade V3.0: Activity Tables',
    0, 125, -1, 126, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );
