# Automatic block media recovery
In this lab we will see how Active Data Guard Automatic Block media recovery works.

Block corruptions are a common source of database outages. A database block is
corrupted when its content has changed from what Oracle Database expects to find. If
not prevented or repaired, block corruption can bring down the database and possibly
result in the loss of key business data.

Data Guard maintains a copy of your data in a standby database that is continuously updated with changes from the primary database. Data Guard validates all changes before they are applied to the standby database, preventing physical corruptions that occur in the storage layer from causing data loss and downtime. The primary database automatically attempts to repair the corrupted block in real time by fetching a good version of the same block from an Active Data Guard physical standby database. This process works in both ways. 

In this lab we will introduce a block corruption in the database and see Active Data Guard repairing it.

> **Warning** on copying and pasting commands with multiple lines from the browser screen; when you copy from outside of the Remote Desktop environment and paste inside the Remote Desktop environment, additional **enters** or CRLF characters are pasted causing some commands to fail. 

## Preparation

First download the 3 sql scripts we will need in this Lab.

[01_abmr.sql](./scripts/01_abmr.sql)

[02_abmr.sql](./scripts/02_abmr.sql)

[03_abmr.sql](./scripts/03_abmr.sql)


Also find back the ssh keys which were created in Lab 1 and Lab 2 in order to connect to the hosts where the primary and standby database are located. 

We need 4 sessions

1. 2 sessions to the primary as the oracle user
2. 2 sessions to the standby as the oracle user

The first session will be used to perform the actions in the database, the second session per environment is used to put a tail on the alert log.

On the first sesssion of the primary, set the environment and log on to the database

````
[oracle@vmadgholad1 ~]$ . oraenv
ORACLE_SID = [DGHOL] ?
The Oracle base remains unchanged with value /u01/app/oracle
[oracle@vmadgholad1 ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sun Feb 28 09:39:05 2021
Version 19.9.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.9.0.0.0

SQL>
````

Then alter your session to connect to the pdb.

````
SQL> alter session set container=mypdb;

Session altered.

SQL>
````

on the second sesion, set the environment and put a tail -f on the alert log.

````
[opc@vmadgholad1 ~]$ sudo su - oracle
Last login: Sun Feb 28 09:36:30 UTC 2021
[oracle@vmadgholad1 ~]$ . oraenv
ORACLE_SID = [DGHOL] ?
The Oracle base has been set to /u01/app/oracle
[oracle@vmadgholad1 ~]$ tail -f $ORACLE_BASE/diag/rdbms/dghol_fra1sw/DGHOL/trace/alert_DGHOL.log
````

Repeat these steps on the standby consoles.

## Step 1: Setup the environment

In the SQL Plus console from the primary database, run the 01_abmr.sql script. 
You can open this script and copy/paste this or copy it over to the host, just as you prefer.

This script will create a tablespace, adds a table in it and inserts a row. This will also return the rowid. Take a note of this number as you will need it in step 2, the step that will introduce corruption.

````
SQL> show con_name

CON_NAME
------------------------------
MYPDB
SQL> @01_abmr.sql
SQL> set feed on;
SQL> Col owner format a20;
SQL> var rid varchar2(25);
SQL> col segment_name format a20;
SQL>
SQL> drop tablespace corruptiontest including contents and datafiles;
drop tablespace corruptiontest including contents and datafiles
*
ERROR at line 1:
ORA-00959: tablespace 'CORRUPTIONTEST' does not exist


SQL> create tablespace corruptiontest datafile '/home/oracle/corruptiontest01.dbf' size 1m;

Tablespace created.

SQL> create table will_be_corrupted(myfield varchar2(50)) tablespace corruptiontest;

Table created.

SQL> insert into will_be_corrupted(myfield) values ('This will have a problem') returning rowid into :rid;

1 row created.

SQL> print

RID
--------------------------------------------------------------------------------------------------------------------------------
AAASGFAANAAAAAPAAA

SQL> Commit;

Commit complete.

SQL> Alter system checkpoint;

System altered.

SQL> select * from will_be_corrupted;

MYFIELD
--------------------------------------------------
This will have a problem

1 row selected.

SQL> --select owner, segment_name,tablespace_name,file_id,block_id from dba_extents where segment_name='WILL_BE_CORRUPTED'; -- will be segment id
SQL> select dbms_rowid.ROWID_BLOCK_NUMBER(ROWID, 'SMALLFILE') FROM will_be_corrupted where myfield='This will have a problem';

DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID,'SMALLFILE')
------------------------------------------------
					      15

1 row selected.

SQL>
````

In this example, you will need to remember the number 15.

## Step 2: Corrupt the datafile
In the same session, execute script 02_abmr.sql.
This script will ask for a number. This is the number from the first step and this will be used to corrupt the datafile which the first script has created. 

````
SQL> @02_abmr.sql
SQL> host dd conv=notrunc bs=1 count=2 if=/dev/zero of=/home/oracle/corruptiontest01.dbf seek=$((&block_id*8192+16))
Enter value for block_id: 15
2+0 records in
2+0 records out
2 bytes (2 B) copied, 0.000608575 s, 3.3 kB/s

SQL>
````

At this point, we have a corrupt datafile, but the database is not aware of it yet. 


## Step 3: Access the table 

By accessing the table, Oracle will need to read the data. This demo database is not very active, so it will be necessary to flush the caches before we access the table. That way, the data needs to be read from disk. This data is corrupt and without any error returned to the user, Active Data Guard will repair the corrupt block before returning the query result. 

Use the script 03_abmr.sql for this. 

Monitor the alertlogs closely while executing this step.

In the sqlplus window we will see this

````
SQL> @03_abmr.sql
SQL> alter system flush buffer_cache;

System altered.

SQL> select * from will_be_corrupted;

MYFIELD
--------------------------------------------------
This will have a problem

1 row selected.

SQL>
````

and in alertlog from the primary database we notice that the automated block media recovery took place.

````
...
2021-02-28T09:51:48.021351+00:00
MYPDB(3):ALTER SYSTEM: Flushing buffer cache inst=0 container=3 global
MYPDB(3):Hex dump of (file 13, block 15) in trace file /u01/app/oracle/diag/rdbms/dghol_fra1sw/DGHOL/trace/DGHOL_ora_4300.trc
MYPDB(3):
MYPDB(3):Corrupt block relative dba: 0x0340000f (file 13, block 15)
MYPDB(3):Bad check value found during multiblock buffer read
MYPDB(3):Data in bad block:
MYPDB(3): type: 6 format: 2 rdba: 0x0340000f
MYPDB(3): last change scn: 0x0000.0000.003896dd seq: 0x1 flg: 0x16
MYPDB(3): spare3: 0x0
MYPDB(3): consistency value in tail: 0x96dd0601
MYPDB(3): check value in block header: 0x0
MYPDB(3): computed block checksum: 0x9127
MYPDB(3):
MYPDB(3):Reading datafile '/home/oracle/corruptiontest01.dbf' for corrupt data at rdba: 0x0340000f (file 13, block 15)
MYPDB(3):Reread (file 13, block 15) found same corrupt data (no logical check)
MYPDB(3):Starting background process ABMR
2021-02-28T09:51:48.090006+00:00
Corrupt Block Found
         TIME STAMP (GMT) = 02/28/2021 09:51:47
         CONT = 3, TSN = 6, TSNAME = CORRUPTIONTEST
         RFN = 13, BLK = 15, RDBA = 54525967
         OBJN = 74117, OBJD = 74117, OBJECT = WILL_BE_CORRUPTED, SUBOBJECT =
         SEGMENT OWNER = SYS, SEGMENT TYPE = Table Segment
2021-02-28T09:51:48.113521+00:00
ABMR started with pid=80, OS id=13327
2021-02-28T09:51:48.114720+00:00
Automatic block media recovery service is active.
2021-02-28T09:51:48.114946+00:00
MYPDB(3):Automatic block media recovery requested for (file# 13, block# 15)
2021-02-28T09:51:55.535547+00:00
Automatic block media recovery successful for (file# 13, block# 15)
2021-02-28T09:51:55.536073+00:00
MYPDB(3):Automatic block media recovery successful for (file# 13, block# 15)
2021-02-28T09:52:28.831408+00:00
MYPDB(3):Resize operation completed for file# 10, old size 430080K, new size 440320K
...
````

## Step 4: Cleanup

To clean this excercise, just drop the tablespace.
In the sqlplus window, use this command:

````
SQL> drop tablespace corruptiontest including contents and datafiles;

Tablespace dropped.

SQL>
````


## Summary
You have now seen Active Data Guard Automatic Block media recovery working.