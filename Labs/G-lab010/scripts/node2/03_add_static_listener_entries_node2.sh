#!/bin/sh
. /home/oracle/myenv

echo "SID_LIST_LISTENER = (SID_LIST = (SID_DESC = (GLOBAL_DBNAME = ${STBYUNQ}_DGMGRL)(ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1)(SID_NAME=ORCL)))" >> $ORACLE_HOME/network/admin/listener.ora

echo "Reloading the listener..."
$ORACLE_HOME/bin/lsnrctl reload

echo "Displaying tnsnames.ora: "
cat $ORACLE_HOME/network/admin/listener.ora
