--
-- Title:      Upgrade to V3.2 - upgrade jbpm tables to jbpm 3.3.1 
-- Database:   DB2
-- Since:      V3.2 schema 2013
-- Author:     
--
-- upgrade jbpm tables to jbpm 3.3.1
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- just change type in columns from varchar(4000) to clob(255) doesn't work. So have to create
-- temp table, copy values over, drop old table and rename temporary.
-- Oracle approach also doesn't work. 

-- we mark next statement as optional to not fail the upgrade from 2.1.a  (as it doesn't contain jbpm)

--JBPM_ACTION
--ASSIGN:jbpm_action_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_ACTION; -- (optional)

create table T_JBPM_ACTION (
        ID_ bigint generated by default as identity (start with ${jbpm_action_max_id}),
        class char(1) not null,
        NAME_ varchar(255),
        ISPROPAGATIONALLOWED_ smallint,
        ACTIONEXPRESSION_ varchar(255),
        ISASYNC_ smallint,
        REFERENCEDACTION_ bigint,
        ACTIONDELEGATION_ bigint,
        EVENT_ bigint,
        PROCESSDEFINITION_ bigint,
        TIMERNAME_ varchar(255),
        DUEDATE_ varchar(255),
        REPEAT_ varchar(255),
        TRANSITIONNAME_ varchar(255),
        TIMERACTION_ bigint,
        EXPRESSION_ clob(255),
        EVENTINDEX_ integer,
        EXCEPTIONHANDLER_ bigint,
        EXCEPTIONHANDLERINDEX_ integer,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_ACTION 
   (
      ID_, class, NAME_, ISPROPAGATIONALLOWED_, ACTIONEXPRESSION_, ISASYNC_, REFERENCEDACTION_, ACTIONDELEGATION_, 
      EVENT_, PROCESSDEFINITION_, TIMERNAME_, DUEDATE_, REPEAT_, TRANSITIONNAME_, TIMERACTION_, EXPRESSION_, 
      EVENTINDEX_, EXCEPTIONHANDLER_, EXCEPTIONHANDLERINDEX_
   )
   select 
      j.ID_, j.class, j.NAME_, j.ISPROPAGATIONALLOWED_, j.ACTIONEXPRESSION_, j.ISASYNC_, j.REFERENCEDACTION_, j.ACTIONDELEGATION_, 
      j.EVENT_, j.PROCESSDEFINITION_, j.TIMERNAME_, j.DUEDATE_, j.REPEAT_, j.TRANSITIONNAME_, j.TIMERACTION_, j.EXPRESSION_, 
      j.EVENTINDEX_, j.EXCEPTIONHANDLER_, j.EXCEPTIONHANDLERINDEX_
   from JBPM_ACTION j
; -- (optional)

drop table JBPM_ACTION; -- (optional) 
rename T_JBPM_ACTION to JBPM_ACTION; -- (optional)

--JBPM_COMMENT
--ASSIGN:jbpm_comment_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_COMMENT; -- (optional)

create table T_JBPM_COMMENT (
        ID_ bigint generated by default as identity (start with ${jbpm_comment_max_id}),
        VERSION_ integer not null,
        ACTORID_ varchar(255),
        TIME_ timestamp,
        MESSAGE_ clob(255),
        TOKEN_ bigint,
        TASKINSTANCE_ bigint,
        TOKENINDEX_ integer,
        TASKINSTANCEINDEX_ integer,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_COMMENT
   (
      ID_, VERSION_, ACTORID_, TIME_, MESSAGE_, TOKEN_, 
      TASKINSTANCE_, TOKENINDEX_, TASKINSTANCEINDEX_
   )
   select 
      j.ID_, j.VERSION_, j.ACTORID_, j.TIME_, j.MESSAGE_, j.TOKEN_, 
      j.TASKINSTANCE_, j.TOKENINDEX_, j.TASKINSTANCEINDEX_
   from JBPM_COMMENT j
; -- (optional)

drop table JBPM_COMMENT; -- (optional)
rename T_JBPM_COMMENT to JBPM_COMMENT; -- (optional)

--JBPM_DELEGATION
--ASSIGN:jbpm_delegation_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_DELEGATION; -- (optional)

create table T_JBPM_DELEGATION (
        ID_ bigint generated by default as identity (start with ${jbpm_delegation_max_id}),
        CLASSNAME_ clob(255),
        CONFIGURATION_ clob(4000),
        CONFIGTYPE_ varchar(255),
        PROCESSDEFINITION_ bigint,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_DELEGATION
   (
      ID_, CLASSNAME_, CONFIGURATION_, CONFIGTYPE_, PROCESSDEFINITION_
   )
   select
      j.ID_, j.CLASSNAME_, j.CONFIGURATION_, j.CONFIGTYPE_, j.PROCESSDEFINITION_
   from JBPM_DELEGATION j
; -- (optional)

drop table JBPM_DELEGATION; -- (optional)
rename T_JBPM_DELEGATION to JBPM_DELEGATION; -- (optional)

--JBPM_EXCEPTIONHANDLER
--ASSIGN:jbpm_exceprionhandler_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_EXCEPTIONHANDLER; -- (optional)

create table T_JBPM_EXCEPTIONHANDLER (
        ID_ bigint generated by default as identity (start with ${jbpm_exceprionhandler_max_id}),
        EXCEPTIONCLASSNAME_ clob(255),
        TYPE_ char(1),
        GRAPHELEMENT_ bigint,
        PROCESSDEFINITION_ bigint,
        GRAPHELEMENTINDEX_ integer,
        NODE_ bigint,
        TRANSITION_ bigint,
        TASK_ bigint,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_EXCEPTIONHANDLER
   (
      ID_, EXCEPTIONCLASSNAME_, TYPE_, GRAPHELEMENT_, 
      PROCESSDEFINITION_, GRAPHELEMENTINDEX_, NODE_, TRANSITION_, TASK_
   )
   select 
      j.ID_, j.EXCEPTIONCLASSNAME_, j.TYPE_, j.GRAPHELEMENT_, 
      j.PROCESSDEFINITION_, j.GRAPHELEMENTINDEX_, j.NODE_, j.TRANSITION_, j.TASK_
   from JBPM_EXCEPTIONHANDLER j
; -- (optional)

drop table JBPM_EXCEPTIONHANDLER; -- (optional)
rename T_JBPM_EXCEPTIONHANDLER to JBPM_EXCEPTIONHANDLER; -- (optional)

--JBPM_JOB
--ASSIGN:jbpm_job_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_JOB; -- (optional)

create table T_JBPM_JOB (
        ID_ bigint generated by default as identity (start with ${jbpm_job_max_id}),
        CLASS_ char(1) not null,
        VERSION_ integer not null,
        DUEDATE_ timestamp,
        PROCESSINSTANCE_ bigint,
        TOKEN_ bigint,
        TASKINSTANCE_ bigint,
        ISSUSPENDED_ smallint,
        ISEXCLUSIVE_ smallint,
        LOCKOWNER_ varchar(255),
        LOCKTIME_ timestamp,
        EXCEPTION_ clob(255),
        RETRIES_ integer,
        NAME_ varchar(255),
        REPEAT_ varchar(255),
        TRANSITIONNAME_ varchar(255),
        ACTION_ bigint,
        GRAPHELEMENTTYPE_ varchar(255),
        GRAPHELEMENT_ bigint,
        NODE_ bigint,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_JOB
   (
      ID_, CLASS_, VERSION_, DUEDATE_, PROCESSINSTANCE_, TOKEN_, 
      TASKINSTANCE_, ISSUSPENDED_, ISEXCLUSIVE_, LOCKOWNER_, LOCKTIME_, 
      EXCEPTION_, RETRIES_, NAME_, REPEAT_, TRANSITIONNAME_, ACTION_, 
      GRAPHELEMENTTYPE_, GRAPHELEMENT_, NODE_
   )
   select 
      j.ID_, j.CLASS_, j.VERSION_, j.DUEDATE_, j.PROCESSINSTANCE_, j.TOKEN_, 
      j.TASKINSTANCE_, j.ISSUSPENDED_, j.ISEXCLUSIVE_, j.LOCKOWNER_, j.LOCKTIME_, 
      j.EXCEPTION_, j.RETRIES_, j.NAME_, j.REPEAT_, j.TRANSITIONNAME_, j.ACTION_, 
      j.GRAPHELEMENTTYPE_, j.GRAPHELEMENT_, j.NODE_
   from JBPM_JOB j
; -- (optional)

drop table JBPM_JOB; -- (optional)
rename T_JBPM_JOB to JBPM_JOB; -- (optional)

--JBPM_LOG
--ASSIGN:jbpm_log_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_LOG; -- (optional)

create table T_JBPM_LOG (
        ID_ bigint generated by default as identity (start with ${jbpm_log_max_id}),
        CLASS_ char(1) not null,
        INDEX_ integer,
        DATE_ timestamp,
        TOKEN_ bigint,
        PARENT_ bigint,
        MESSAGE_ clob(255),
        EXCEPTION_ clob(255),
        ACTION_ bigint,
        NODE_ bigint,
        ENTER_ timestamp,
        LEAVE_ timestamp,
        DURATION_ bigint,
        NEWLONGVALUE_ bigint,
        TRANSITION_ bigint,
        CHILD_ bigint,
        SOURCENODE_ bigint,
        DESTINATIONNODE_ bigint,
        VARIABLEINSTANCE_ bigint,
        OLDBYTEARRAY_ bigint,
        NEWBYTEARRAY_ bigint,
        OLDDATEVALUE_ timestamp,
        NEWDATEVALUE_ timestamp,
        OLDDOUBLEVALUE_ double,
        NEWDOUBLEVALUE_ double,
        OLDLONGIDCLASS_ varchar(255),
        OLDLONGIDVALUE_ bigint,
        NEWLONGIDCLASS_ varchar(255),
        NEWLONGIDVALUE_ bigint,
        OLDSTRINGIDCLASS_ varchar(255),
        OLDSTRINGIDVALUE_ varchar(255),
        NEWSTRINGIDCLASS_ varchar(255),
        NEWSTRINGIDVALUE_ varchar(255),
        OLDLONGVALUE_ bigint,
        OLDSTRINGVALUE_ clob(255),
        NEWSTRINGVALUE_ clob(255),
        TASKINSTANCE_ bigint,
        TASKACTORID_ varchar(255),
        TASKOLDACTORID_ varchar(255),
        SWIMLANEINSTANCE_ bigint,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_LOG
   (
      ID_, CLASS_, INDEX_, DATE_, TOKEN_, PARENT_, MESSAGE_, EXCEPTION_, ACTION_, 
      NODE_, ENTER_, LEAVE_, DURATION_, NEWLONGVALUE_, TRANSITION_, CHILD_, 
      SOURCENODE_, DESTINATIONNODE_, VARIABLEINSTANCE_, OLDBYTEARRAY_, NEWBYTEARRAY_, 
      OLDDATEVALUE_, NEWDATEVALUE_, OLDDOUBLEVALUE_, NEWDOUBLEVALUE_, OLDLONGIDCLASS_,
      OLDLONGIDVALUE_, NEWLONGIDCLASS_, NEWLONGIDVALUE_, OLDSTRINGIDCLASS_, 
      OLDSTRINGIDVALUE_, NEWSTRINGIDCLASS_, NEWSTRINGIDVALUE_, OLDLONGVALUE_, 
      OLDSTRINGVALUE_, NEWSTRINGVALUE_, TASKINSTANCE_, TASKACTORID_, TASKOLDACTORID_, 
      SWIMLANEINSTANCE_
   )
   select
      j.ID_, j.CLASS_, j.INDEX_, j.DATE_, j.TOKEN_, j.PARENT_, j.MESSAGE_, j.EXCEPTION_, j.ACTION_, 
      j.NODE_, j.ENTER_, j.LEAVE_, j.DURATION_, j.NEWLONGVALUE_, j.TRANSITION_, j.CHILD_, 
      j.SOURCENODE_, j.DESTINATIONNODE_, j.VARIABLEINSTANCE_, j.OLDBYTEARRAY_, j.NEWBYTEARRAY_, 
      j.OLDDATEVALUE_, j.NEWDATEVALUE_, j.OLDDOUBLEVALUE_, j.NEWDOUBLEVALUE_, j.OLDLONGIDCLASS_,
      j.OLDLONGIDVALUE_, j.NEWLONGIDCLASS_, j.NEWLONGIDVALUE_, j.OLDSTRINGIDCLASS_, 
      j.OLDSTRINGIDVALUE_, j.NEWSTRINGIDCLASS_, j.NEWSTRINGIDVALUE_, j.OLDLONGVALUE_, 
      j.OLDSTRINGVALUE_, j.NEWSTRINGVALUE_, j.TASKINSTANCE_, j.TASKACTORID_, j.TASKOLDACTORID_, 
      j.SWIMLANEINSTANCE_
   from JBPM_LOG j
; -- (optional)
drop table JBPM_LOG; -- (optional)
rename T_JBPM_LOG to JBPM_LOG; -- (optional)

--JBPM_MODULEDEFINITION
--ASSIGN:jbpm_moduledefinition_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_MODULEDEFINITION; -- (optional)

create table T_JBPM_MODULEDEFINITION (
        ID_ bigint generated by default as identity (start with ${jbpm_moduledefinition_max_id}),
        CLASS_ char(1) not null,
        NAME_ varchar(255),
        PROCESSDEFINITION_ bigint,
        STARTTASK_ bigint,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_MODULEDEFINITION
   (
      ID_, CLASS_, NAME_, PROCESSDEFINITION_, STARTTASK_
   )
   select
      j.ID_, j.CLASS_, j.NAME_, j.PROCESSDEFINITION_, j.STARTTASK_
   from JBPM_MODULEDEFINITION j
; -- (optional)

drop table JBPM_MODULEDEFINITION; -- (optional)
rename T_JBPM_MODULEDEFINITION to JBPM_MODULEDEFINITION; -- (optional)

--JBPM_NODE
--ASSIGN:jbpm_node_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_NODE; -- (optional)

create table T_JBPM_NODE (
        ID_ bigint generated by default as identity (start with ${jbpm_node_max_id}),
        CLASS_ char(1) not null,
        NAME_ varchar(255),
        DESCRIPTION_ clob(255),
        PROCESSDEFINITION_ bigint,
        ISASYNC_ smallint,
        ISASYNCEXCL_ smallint,
        ACTION_ bigint,
        SUPERSTATE_ bigint,
        SUBPROCNAME_ varchar(255),
        SUBPROCESSDEFINITION_ bigint,
        DECISIONEXPRESSION_ varchar(255),
        DECISIONDELEGATION bigint,
        SCRIPT_ bigint,
        SIGNAL_ integer,
        CREATETASKS_ smallint,
        ENDTASKS_ smallint,
        NODECOLLECTIONINDEX_ integer,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_NODE
   (
      ID_, CLASS_, NAME_, DESCRIPTION_, PROCESSDEFINITION_, ISASYNC_, 
      ISASYNCEXCL_, ACTION_, SUPERSTATE_, SUBPROCNAME_, 
      SUBPROCESSDEFINITION_, DECISIONEXPRESSION_, DECISIONDELEGATION, 
      SCRIPT_, SIGNAL_, CREATETASKS_, ENDTASKS_, NODECOLLECTIONINDEX_
   )
   select 
      j.ID_, j.CLASS_, j.NAME_, j.DESCRIPTION_, j.PROCESSDEFINITION_, j.ISASYNC_, 
      j.ISASYNCEXCL_, j.ACTION_, j.SUPERSTATE_, j.SUBPROCNAME_, 
      j.SUBPROCESSDEFINITION_, j.DECISIONEXPRESSION_, j.DECISIONDELEGATION, 
      j.SCRIPT_, j.SIGNAL_, j.CREATETASKS_, j.ENDTASKS_, j.NODECOLLECTIONINDEX_
   from JBPM_NODE j 
; -- (optional)

drop table JBPM_NODE; -- (optional)
rename T_JBPM_NODE to JBPM_NODE; -- (optional)

--JBPM_PROCESSDEFINITION
--ASSIGN:jbpm_processdefinition_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_PROCESSDEFINITION; -- (optional)

create table T_JBPM_PROCESSDEFINITION (
        ID_ bigint generated by default as identity (start with ${jbpm_processdefinition_max_id}),
        CLASS_ char(1) not null,
        NAME_ varchar(255),
        DESCRIPTION_ clob(255),
        VERSION_ integer,
        ISTERMINATIONIMPLICIT_ smallint,
        STARTSTATE_ bigint,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_PROCESSDEFINITION 
   (
      ID_, CLASS_, NAME_, DESCRIPTION_, VERSION_, 
      ISTERMINATIONIMPLICIT_, STARTSTATE_
   )
   select
      j.ID_, j.CLASS_, j.NAME_, j.DESCRIPTION_, j.VERSION_, 
      j.ISTERMINATIONIMPLICIT_, j.STARTSTATE_
   from JBPM_PROCESSDEFINITION j
; -- (optional)

drop table JBPM_PROCESSDEFINITION; -- (optional)
rename T_JBPM_PROCESSDEFINITION to JBPM_PROCESSDEFINITION; -- (optional)

--JBPM_TASK
--ASSIGN:jbpm_task_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_TASK; -- (optional)

create table T_JBPM_TASK (
        ID_ bigint generated by default as identity (start with ${jbpm_task_max_id}),
        NAME_ varchar(255),
        DESCRIPTION_ clob(255),
        PROCESSDEFINITION_ bigint,
        ISBLOCKING_ smallint,
        ISSIGNALLING_ smallint,
        CONDITION_ varchar(255),
        DUEDATE_ varchar(255),
        PRIORITY_ integer,
        ACTORIDEXPRESSION_ varchar(255),
        POOLEDACTORSEXPRESSION_ varchar(255),
        TASKMGMTDEFINITION_ bigint,
        TASKNODE_ bigint,
        STARTSTATE_ bigint,
        ASSIGNMENTDELEGATION_ bigint,
        SWIMLANE_ bigint,
        TASKCONTROLLER_ bigint,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_TASK
   (
      ID_, NAME_, DESCRIPTION_, PROCESSDEFINITION_, ISBLOCKING_, ISSIGNALLING_, 
      CONDITION_, DUEDATE_, PRIORITY_, ACTORIDEXPRESSION_, POOLEDACTORSEXPRESSION_, 
      TASKMGMTDEFINITION_, TASKNODE_, STARTSTATE_, ASSIGNMENTDELEGATION_, 
      SWIMLANE_, TASKCONTROLLER_
   )
   select
      j.ID_, j.NAME_, j.DESCRIPTION_, j.PROCESSDEFINITION_, j.ISBLOCKING_, j.ISSIGNALLING_, 
      j.CONDITION_, j.DUEDATE_, j.PRIORITY_, j.ACTORIDEXPRESSION_, j.POOLEDACTORSEXPRESSION_, 
      j.TASKMGMTDEFINITION_, j.TASKNODE_, j.STARTSTATE_, j.ASSIGNMENTDELEGATION_, 
      j.SWIMLANE_, j.TASKCONTROLLER_
   from JBPM_TASK j
; -- (optional)

drop table JBPM_TASK; -- (optional)
rename T_JBPM_TASK to JBPM_TASK; -- (optional)

--JBPM_TASKINSTANCE
--ASSIGN:jbpm_taskinstance_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_TASKINSTANCE; -- (optional)

create table T_JBPM_TASKINSTANCE (
        ID_ bigint generated by default as identity (start with ${jbpm_taskinstance_max_id}),
        CLASS_ char(1) not null,
        VERSION_ integer not null,
        NAME_ varchar(255),
        DESCRIPTION_ clob(255),
        ACTORID_ varchar(255),
        CREATE_ timestamp,
        START_ timestamp,
        END_ timestamp,
        DUEDATE_ timestamp,
        PRIORITY_ integer,
        ISCANCELLED_ smallint,
        ISSUSPENDED_ smallint,
        ISOPEN_ smallint,
        ISSIGNALLING_ smallint,
        ISBLOCKING_ smallint,
        TASK_ bigint,
        TOKEN_ bigint,
        PROCINST_ bigint,
        SWIMLANINSTANCE_ bigint,
        TASKMGMTINSTANCE_ bigint,
        JBPM_ENGINE_NAME varchar(50),
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_TASKINSTANCE
   (
      ID_, CLASS_, VERSION_, NAME_, DESCRIPTION_, ACTORID_, CREATE_, 
      START_, END_, DUEDATE_, PRIORITY_, ISCANCELLED_, ISSUSPENDED_, 
      ISOPEN_, ISSIGNALLING_, ISBLOCKING_, TASK_, TOKEN_, PROCINST_, 
      SWIMLANINSTANCE_, TASKMGMTINSTANCE_
   )
   select
      j.ID_, j.CLASS_, j.VERSION_, j.NAME_, j.DESCRIPTION_, j.ACTORID_, j.CREATE_, 
      j.START_, j.END_, j.DUEDATE_, j.PRIORITY_, j.ISCANCELLED_, j.ISSUSPENDED_, 
      j.ISOPEN_, j.ISSIGNALLING_, j.ISBLOCKING_, j.TASK_, j.TOKEN_, j.PROCINST_, 
      j.SWIMLANINSTANCE_, j.TASKMGMTINSTANCE_
   from JBPM_TASKINSTANCE j
; -- (optional)
drop table JBPM_TASKINSTANCE; -- (optional)
rename T_JBPM_TASKINSTANCE to JBPM_TASKINSTANCE; -- (optional)

--JBPM_TRANSITION
--ASSIGN:jbpm_transition_max_id=next_val
SELECT CASE WHEN MAX(ID_) IS NOT NULL THEN MAX(ID_)+1 ELSE 1 END AS next_val FROM JBPM_TRANSITION; -- (optional)

create table T_JBPM_TRANSITION (
        ID_ bigint generated by default as identity (start with ${jbpm_transition_max_id}),
        NAME_ varchar(255),
        DESCRIPTION_ clob(255),
        PROCESSDEFINITION_ bigint,
        FROM_ bigint,
        TO_ bigint,
        CONDITION_ varchar(255),
        FROMINDEX_ integer,
        primary key (ID_)
    ); -- (optional)

insert into T_JBPM_TRANSITION
   (
      ID_, NAME_, DESCRIPTION_, PROCESSDEFINITION_, FROM_, TO_, 
      CONDITION_, FROMINDEX_
   )
   select
      j.ID_, j.NAME_, j.DESCRIPTION_, j.PROCESSDEFINITION_, j.FROM_, j.TO_, 
      j.CONDITION_, j.FROMINDEX_
   from JBPM_TRANSITION j
; -- (optional)

drop table JBPM_TRANSITION; -- (optional)
rename T_JBPM_TRANSITION to JBPM_TRANSITION; -- (optional)

--adding indexes    
create index IDX_ACTION_ACTNDL on JBPM_ACTION (ACTIONDELEGATION_); -- (optional)
create index IDX_ACTION_PROCDF on JBPM_ACTION (PROCESSDEFINITION_); -- (optional)
create index IDX_ACTION_EVENT on JBPM_ACTION (EVENT_); -- (optional)
create index IDX_COMMENT_TSK on JBPM_COMMENT (TASKINSTANCE_); -- (optional)
create index IDX_COMMENT_TOKEN on JBPM_COMMENT (TOKEN_); -- (optional)
create index IDX_DELEG_PRCD on JBPM_DELEGATION (PROCESSDEFINITION_); -- (optional)
create index IDX_JOB_TSKINST on JBPM_JOB (TASKINSTANCE_); -- (optional)
create index IDX_JOB_TOKEN on JBPM_JOB (TOKEN_); -- (optional)
create index IDX_JOB_PRINST on JBPM_JOB (PROCESSINSTANCE_); -- (optional)
create index IDX_MODDEF_PROCDF on JBPM_MODULEDEFINITION (PROCESSDEFINITION_); -- (optional)
create index IDX_PSTATE_SBPRCDEF on JBPM_NODE (SUBPROCESSDEFINITION_); -- (optional)
create index IDX_NODE_PROCDEF on JBPM_NODE (PROCESSDEFINITION_); -- (optional)
create index IDX_NODE_ACTION on JBPM_NODE (ACTION_); -- (optional)
create index IDX_NODE_SUPRSTATE on JBPM_NODE (SUPERSTATE_); -- (optional)
create index IDX_PROCDEF_STRTST on JBPM_PROCESSDEFINITION (STARTSTATE_); -- (optional)
create index IDX_TASK_PROCDEF on JBPM_TASK (PROCESSDEFINITION_); -- (optional)
create index IDX_TASK_TSKNODE on JBPM_TASK (TASKNODE_); -- (optional)
create index IDX_TASK_TASKMGTDF on JBPM_TASK (TASKMGMTDEFINITION_); -- (optional)
create index IDX_TSKINST_TMINST on JBPM_TASKINSTANCE (TASKMGMTINSTANCE_); -- (optional)
create index IDX_TSKINST_SLINST on JBPM_TASKINSTANCE (SWIMLANINSTANCE_); -- (optional)
create index IDX_TASKINST_TOKN on JBPM_TASKINSTANCE (TOKEN_); -- (optional)
create index IDX_TASK_ACTORID on JBPM_TASKINSTANCE (ACTORID_); -- (optional)
create index IDX_TASKINST_TSK on JBPM_TASKINSTANCE (TASK_, PROCINST_); -- (optional)
create index IDX_TRANS_PROCDEF on JBPM_TRANSITION (PROCESSDEFINITION_); -- (optional)
create index IDX_TRANSIT_FROM on JBPM_TRANSITION (FROM_); -- (optional)
create index IDX_TRANSIT_TO on JBPM_TRANSITION (TO_); -- (optional)

-- adding constraints
alter table JBPM_ACTION add constraint FK_ACTION_REFACT foreign key (REFERENCEDACTION_) references JBPM_ACTION; -- (optional)
alter table JBPM_ACTION add constraint FK_CRTETIMERACT_TA foreign key (TIMERACTION_) references JBPM_ACTION; -- (optional)
alter table JBPM_ACTION add constraint FK_ACTION_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_ACTION add constraint FK_ACTION_EVENT foreign key (EVENT_) references JBPM_EVENT; -- (optional)
alter table JBPM_ACTION add constraint FK_ACTION_ACTNDEL foreign key (ACTIONDELEGATION_) references JBPM_DELEGATION; -- (optional)
alter table JBPM_ACTION add constraint FK_ACTION_EXPTHDL foreign key (EXCEPTIONHANDLER_) references JBPM_EXCEPTIONHANDLER; -- (optional)
alter table JBPM_COMMENT add constraint FK_COMMENT_TOKEN foreign key (TOKEN_) references JBPM_TOKEN; -- (optional)
alter table JBPM_COMMENT add constraint FK_COMMENT_TSK foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE; -- (optional)
alter table JBPM_DELEGATION add constraint FK_DELEGATION_PRCD foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_JOB add constraint FK_JOB_PRINST foreign key (PROCESSINSTANCE_) references JBPM_PROCESSINSTANCE; -- (optional)
alter table JBPM_JOB add constraint FK_JOB_ACTION foreign key (ACTION_) references JBPM_ACTION; -- (optional)
alter table JBPM_JOB add constraint FK_JOB_TOKEN foreign key (TOKEN_) references JBPM_TOKEN; -- (optional)
alter table JBPM_JOB add constraint FK_JOB_NODE foreign key (NODE_) references JBPM_NODE; -- (optional)
alter table JBPM_JOB add constraint FK_JOB_TSKINST foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_SOURCENODE foreign key (SOURCENODE_) references JBPM_NODE; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_DESTNODE foreign key (DESTINATIONNODE_) references JBPM_NODE; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_TOKEN foreign key (TOKEN_) references JBPM_TOKEN; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_TRANSITION foreign key (TRANSITION_) references JBPM_TRANSITION; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_TASKINST foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_CHILDTOKEN foreign key (CHILD_) references JBPM_TOKEN; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_OLDBYTES foreign key (OLDBYTEARRAY_) references JBPM_BYTEARRAY; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_SWIMINST foreign key (SWIMLANEINSTANCE_) references JBPM_SWIMLANEINSTANCE; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_NEWBYTES foreign key (NEWBYTEARRAY_) references JBPM_BYTEARRAY; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_ACTION foreign key (ACTION_) references JBPM_ACTION; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_VARINST foreign key (VARIABLEINSTANCE_) references JBPM_VARIABLEINSTANCE; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_NODE foreign key (NODE_) references JBPM_NODE; -- (optional)
alter table JBPM_LOG add constraint FK_LOG_PARENT foreign key (PARENT_) references JBPM_LOG; -- (optional)
alter table JBPM_MODULEDEFINITION add constraint FK_MODDEF_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_MODULEDEFINITION add constraint FK_TSKDEF_START foreign key (STARTTASK_) references JBPM_TASK; -- (optional)
alter table JBPM_NODE add constraint FK_DECISION_DELEG foreign key (DECISIONDELEGATION) references JBPM_DELEGATION; -- (optional)
alter table JBPM_NODE add constraint FK_NODE_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_NODE add constraint FK_NODE_ACTION foreign key (ACTION_) references JBPM_ACTION; -- (optional)
alter table JBPM_NODE add constraint FK_PROCST_SBPRCDEF foreign key (SUBPROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_NODE add constraint FK_NODE_SCRIPT foreign key (SCRIPT_) references JBPM_ACTION; -- (optional)
alter table JBPM_NODE add constraint FK_NODE_SUPERSTATE foreign key (SUPERSTATE_) references JBPM_NODE; -- (optional)
alter table JBPM_PROCESSDEFINITION add constraint FK_PROCDEF_STRTSTA foreign key (STARTSTATE_) references JBPM_NODE; -- (optional)
alter table JBPM_TASK add constraint FK_TASK_STARTST foreign key (STARTSTATE_) references JBPM_NODE; -- (optional)
alter table JBPM_TASK add constraint FK_TASK_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_TASK add constraint FK_TASK_ASSDEL foreign key (ASSIGNMENTDELEGATION_) references JBPM_DELEGATION; -- (optional)
alter table JBPM_TASK add constraint FK_TASK_SWIMLANE foreign key (SWIMLANE_) references JBPM_SWIMLANE; -- (optional)
alter table JBPM_TASK add constraint FK_TASK_TASKNODE foreign key (TASKNODE_) references JBPM_NODE; -- (optional)
alter table JBPM_TASK add constraint FK_TASK_TASKMGTDEF foreign key (TASKMGMTDEFINITION_) references JBPM_MODULEDEFINITION; -- (optional)
alter table JBPM_TASK add constraint FK_TSK_TSKCTRL foreign key (TASKCONTROLLER_) references JBPM_TASKCONTROLLER; -- (optional)
alter table JBPM_TASKINSTANCE add constraint FK_TSKINS_PRCINS foreign key (PROCINST_) references JBPM_PROCESSINSTANCE; -- (optional)
alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_TMINST foreign key (TASKMGMTINSTANCE_) references JBPM_MODULEINSTANCE; -- (optional)
alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_TOKEN foreign key (TOKEN_) references JBPM_TOKEN; -- (optional)
alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_SLINST foreign key (SWIMLANINSTANCE_) references JBPM_SWIMLANEINSTANCE; -- (optional)
alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_TASK foreign key (TASK_) references JBPM_TASK; -- (optional)
alter table JBPM_TRANSITION add constraint FK_TRANSITION_FROM foreign key (FROM_) references JBPM_NODE; -- (optional)
alter table JBPM_TRANSITION add constraint FK_TRANS_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_TRANSITION add constraint FK_TRANSITION_TO foreign key (TO_) references JBPM_NODE; -- (optional)
alter table JBPM_BYTEARRAY add constraint FK_BYTEARR_FILDEF foreign key (FILEDEFINITION_) references JBPM_MODULEDEFINITION; -- (optional)
alter table JBPM_DECISIONCONDITIONS add constraint FK_DECCOND_DEC foreign key (DECISION_) references JBPM_NODE; -- (optional)
alter table JBPM_EVENT add constraint FK_EVENT_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_EVENT add constraint FK_EVENT_TRANS foreign key (TRANSITION_) references JBPM_TRANSITION; -- (optional)
alter table JBPM_EVENT add constraint FK_EVENT_NODE foreign key (NODE_) references JBPM_NODE; -- (optional)
alter table JBPM_EVENT add constraint FK_EVENT_TASK foreign key (TASK_) references JBPM_TASK; -- (optional)
alter table JBPM_MODULEINSTANCE add constraint FK_TASKMGTINST_TMD foreign key (TASKMGMTDEFINITION_) references JBPM_MODULEDEFINITION; -- (optional)
alter table JBPM_PROCESSINSTANCE add constraint FK_PROCIN_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION; -- (optional)
alter table JBPM_RUNTIMEACTION add constraint FK_RTACTN_ACTION foreign key (ACTION_) references JBPM_ACTION; -- (optional)
alter table JBPM_SWIMLANE add constraint FK_SWL_ASSDEL foreign key (ASSIGNMENTDELEGATION_) references JBPM_DELEGATION; -- (optional)
alter table JBPM_SWIMLANE add constraint FK_SWL_TSKMGMTDEF foreign key (TASKMGMTDEFINITION_) references JBPM_MODULEDEFINITION; -- (optional)
alter table JBPM_TASKACTORPOOL add constraint FK_TASKACTPL_TSKI foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE; -- (optional)
alter table JBPM_TASKCONTROLLER add constraint FK_TSKCTRL_DELEG foreign key (TASKCONTROLLERDELEGATION_) references JBPM_DELEGATION; -- (optional)
alter table JBPM_TOKEN add constraint FK_TOKEN_NODE foreign key (NODE_) references JBPM_NODE; -- (optional)
alter table JBPM_VARIABLEACCESS add constraint FK_VARACC_PROCST foreign key (PROCESSSTATE_) references JBPM_NODE; -- (optional)
alter table JBPM_VARIABLEACCESS add constraint FK_VARACC_SCRIPT foreign key (SCRIPT_) references JBPM_ACTION; -- (optional)
alter table JBPM_VARIABLEINSTANCE add constraint FK_VAR_TSKINST foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE; -- (optional)

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
