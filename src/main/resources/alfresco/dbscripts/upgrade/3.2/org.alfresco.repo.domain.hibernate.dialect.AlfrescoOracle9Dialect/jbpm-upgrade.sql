--
-- Title:      Upgrade to V3.2 - upgrade jbpm tables to jbpm 3.3.1 
-- Database:   Oracle
-- Since:      V3.2 schema 2013
-- Author:     
--
-- upgrade jbpm tables to jbpm 3.3.1
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

-- we mark next statements as optional to not fail the upgrade from 2.1.a  (as it doesn't contain jbpm)
--JBPM_ACTION
alter table JBPM_ACTION add 
   EXPRESSION_clob clob
; -- (optional)

update JBPM_ACTION set 
   EXPRESSION_clob = EXPRESSION_
; -- (optional)

alter table JBPM_ACTION drop column EXPRESSION_; -- (optional)
alter table JBPM_ACTION rename column EXPRESSION_clob to EXPRESSION_; -- (optional)


--JBPM_COMMENT
alter table JBPM_COMMENT add 
   MESSAGE_clob clob
; -- (optional)

update JBPM_COMMENT set 
   MESSAGE_clob = MESSAGE_
; -- (optional)

alter table JBPM_COMMENT drop column MESSAGE_; -- (optional)
alter table JBPM_COMMENT rename column MESSAGE_clob to MESSAGE_; -- (optional)


--JBPM_DELEGATION
alter table JBPM_DELEGATION add 
(
   CLASSNAME_clob clob, 
   CONFIGURATION_clob clob
); -- (optional)

update JBPM_DELEGATION set 
   CLASSNAME_clob = CLASSNAME_,
   CONFIGURATION_clob = CONFIGURATION_
; -- (optional)

alter table JBPM_DELEGATION drop 
(
   CLASSNAME_, 
   CONFIGURATION_
); -- (optional)

alter table JBPM_DELEGATION rename column CLASSNAME_clob to CLASSNAME_; -- (optional)
alter table JBPM_DELEGATION rename column CONFIGURATION_clob to CONFIGURATION_; -- (optional)


--JBPM_EXCEPTIONHANDLER
alter table JBPM_EXCEPTIONHANDLER add 
   EXCEPTIONCLASSNAME_clob clob
; -- (optional)

update JBPM_EXCEPTIONHANDLER set 
   EXCEPTIONCLASSNAME_clob = EXCEPTIONCLASSNAME_
; -- (optional)

alter table JBPM_EXCEPTIONHANDLER drop column EXCEPTIONCLASSNAME_; -- (optional)
alter table JBPM_EXCEPTIONHANDLER rename column EXCEPTIONCLASSNAME_clob to EXCEPTIONCLASSNAME_; -- (optional)


--JBPM_JOB
alter table JBPM_JOB add 
   EXCEPTION_clob clob
; -- (optional)

update JBPM_JOB set 
   EXCEPTION_clob = EXCEPTION_
; -- (optional)

alter table JBPM_JOB drop column EXCEPTION_; -- (optional)
alter table JBPM_JOB rename column EXCEPTION_clob to EXCEPTION_; -- (optional)


--JBPM_LOG
alter table JBPM_LOG add 
(
   MESSAGE_clob clob, 
   EXCEPTION_clob clob, 
   OLDSTRINGVALUE_clob clob, 
   NEWSTRINGVALUE_clob clob
); -- (optional)

update JBPM_LOG set 
   MESSAGE_clob = MESSAGE_, 
   CEXCEPTION_clob = EXCEPTION_, 
   OLDSTRINGVALUE_clob=OLDSTRINGVALUE_, 
   NEWSTRINGVALUE_clob=NEWSTRINGVALUE_
; -- (optional)

alter table JBPM_LOG drop 
(
   MESSAGE_, 
   EXCEPTION_, 
   OLDSTRINGVALUE_, 
   NEWSTRINGVALUE_
); -- (optional)

alter table JBPM_LOG rename column MESSAGE_clob to MESSAGE_; -- (optional)
alter table JBPM_LOG rename column EXCEPTION_clob to EXCEPTION_; -- (optional)
alter table JBPM_LOG rename column OLDSTRINGVALUE_clob to OLDSTRINGVALUE_; -- (optional)
alter table JBPM_LOG rename column NEWSTRINGVALUE_clob to NEWSTRINGVALUE_; -- (optional)


--JBPM_MODULEDEFINITION
alter table JBPM_MODULEDEFINITION modify (NAME_ varchar2(255 char));  -- (optional)

--JBPM_NODE
alter table JBPM_NODE add 
   DESCRIPTION_clob clob
; -- (optional)

update JBPM_NODE set 
   DESCRIPTION__clob = DESCRIPTION_
; -- (optional)

alter table JBPM_NODE drop column DESCRIPTION_; -- (optional)
alter table JBPM_NODE rename column DESCRIPTION_clob to DESCRIPTION_; -- (optional)


--JBPM_PROCESSDEFINITION
alter table JBPM_PROCESSDEFINITION add 
   DESCRIPTION_clob clob
; -- (optional)

update JBPM_PROCESSDEFINITION set 
   DESCRIPTION_clob = DESCRIPTION_
; -- (optional)

alter table JBPM_PROCESSDEFINITION drop column DESCRIPTION_; -- (optional)
alter table JBPM_PROCESSDEFINITION rename column DESCRIPTION_clob to DESCRIPTION_; -- (optional)

--JBPM_TASK
alter table JBPM_TASK add 
   DESCRIPTION_clob clob
; -- (optional)

update JBPM_TASK set 
   DESCRIPTION_clob = DESCRIPTION_
; -- (optional)

alter table JBPM_TASK drop column DESCRIPTION_; -- (optional)
alter table JBPM_TASK rename column DESCRIPTION_clob to DESCRIPTION_; -- (optional)

--JBPM_TASKINSTANCE
alter table JBPM_TASKINSTANCE add 
   DESCRIPTION_clob clob
; -- (optional)

update JBPM_TASKINSTANCE set 
   DESCRIPTION_clob = DESCRIPTION_
; -- (optional)

alter table JBPM_TASKINSTANCE drop column DESCRIPTION_; -- (optional)
alter table JBPM_TASKINSTANCE rename column DESCRIPTION_clob to DESCRIPTION_; -- (optional)

--JBPM_TRANSITION
alter table JBPM_TRANSITION add 
   DESCRIPTION_clob clob
; -- (optional)

update JBPM_TRANSITION set 
   DESCRIPTION_clob = DESCRIPTION_
; -- (optional)

alter table JBPM_TRANSITION drop column DESCRIPTION_; -- (optional)
alter table JBPM_TRANSITION rename column DESCRIPTION_clob to DESCRIPTION_; -- (optional)

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.2-Upgrade-JBPM';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.2-Upgrade-JBPM', 'Manually executed script upgrade V3.2 to jbpm version 3.3.1 usage',
     0, 2017, -1, 2018, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
   );