#!/bin/sh
. /home/oracle/myenv

mkdir -p /u01/app/oracle/oradata/fra

${ORACLE_HOME}/bin/sqlplus -s "/ as sysdba" << EOF
 alter system set db_recovery_file_dest_size=50G scope=both;
 alter system set db_recovery_file_dest='/u01/app/oracle/oradata/fra' scope=both;
 alter system set log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=${STBYUNQ}' scope=both;
 --alter system set DB_NAME=${ORACLE_SID} scope=spfile;
 alter system set DB_UNIQUE_NAME=${STBYUNQ} scope=spfile;
 alter system set LOG_ARCHIVE_CONFIG='DG_CONFIG=(${STBYUNQ},${PRIMUNQ})' scope=spfile;
 alter system set LOG_ARCHIVE_DEST_2= 'SERVICE=${PRIMTNS} ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=${PRIMUNQ}' scope=spfile;
 alter system set REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE scope=spfile;
 alter system set FAL_SERVER=${PRIMTNS} scope=spfile;
 alter system set STANDBY_FILE_MANAGEMENT=AUTO scope=spfile;
 alter system set DG_BROKER_START=TRUE scope=spfile;
 alter system set archive_lag_target=300 scope=spfile;
 shutdown immediate;
 startup mount
 alter database archivelog;
 alter database flashback on;
 alter database open;
 alter database add standby logfile size 50m;
 alter database add standby logfile size 50m;
 alter database add standby logfile size 50m;
EOF