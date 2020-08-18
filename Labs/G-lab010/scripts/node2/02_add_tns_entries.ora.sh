#!/bin/sh
. /home/oracle/myenv


echo "${PRIMTNS} = (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = ${PRIM})(PORT = 1521))(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = ${PRIMUNQ})(UR=A)))
" >> $ORACLE_HOME/network/admin/tnsnames.ora
echo "${STBYTNS} = (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = ${STBY})(PORT = 1521))(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = ${STBYUNQ})(UR=A))) " >> $ORACLE_HOME/network/admin/tnsnames.ora

echo "Displaying tnsnames.ora: "
cat $ORACLE_HOME/network/admin/tnsnames.ora
