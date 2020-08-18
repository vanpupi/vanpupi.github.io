#!/bin/sh
. /home/oracle/myenv


${ORACLE_HOME}/bin/dgmgrl << EOF
 connect / ;
 create configuration HOLDG as primary database is ${PRIMUNQ} connect identifier is ${PRIMTNS};
 add database ${STBYUNQ} as connect identifier is ${STBYTNS} maintained as physical;
 enable configuration;
 edit database ${PRIMUNQ} set property TransportLagThreshold = 600;
 edit database ${STBYUNQ} set property TransportLagThreshold = 600;
 edit database ${PRIMUNQ} set property ApplyLagThreshold = 600;
 edit database ${STBYUNQ} set property ApplyLagThreshold = 600;
 edit database ${PRIMUNQ} set property TransportDisconnectedThreshold = 600;
 edit database ${STBYUNQ} set property TransportDisconnectedThreshold = 600;
EOF

${ORACLE_HOME}/bin/sqlplus -s "/ as sysdba" << EOFF
 alter system archive log current;
EOFF
