#!/bin/sh
. /home/oracle/myenv

read -s -p "New Sys password: " NEWPASS

${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' << EOF
 alter user sys identified by "${NEWPASS}" container=all;
EOF
