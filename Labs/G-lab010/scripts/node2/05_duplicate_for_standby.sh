#!/bin/sh
. /home/oracle/myenv


${ORACLE_HOME}/bin/sqlplus -s "/ as sysdba" << EOF
 shutdown abort
 startup nomount
EOF

read -s -p "Sys password: " SYSPASS

${ORACLE_HOME}/bin/rman << EOFF
 set echo on
 connect target sys/${SYSPASS}@${PRIMTNS}
 connect auxiliary sys/${SYSPASS}@${STBYTNS}

 run {
 # create some channels for parallism
 allocate channel ch1 type disk;
 allocate channel ch2 type disk;
 allocate channel ch3 type disk;
 allocate channel ch4 type disk;

 allocate auxiliary channel stby1 type disk;

 duplicate target database for standby from active database
    nofilenamecheck;
 }
EOFF

${ORACLE_HOME}/bin/sqlplus -s "/ as sysdba" << EOFFF
 alter database recover managed standby database disconnect nodelay;
 alter system set log_archive_dest_2='' scope=both;
EOFFF
