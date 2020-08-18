#!/bin/sh
export MY_ENV_FILE=/home/oracle/myenv

read -p "What is the Oracle instance running [ORCL]: " ORACLE_SID
read -p "What is internal IP of the first node: " PRIM
read -p "What is internal IP of the second node: " STBY
read -p "What will be the tns entry for the primary [CLHOLVM1]: " PRIMTNS
read -p "What will be the tns entry for the Standby [CLHOLVM2]: " STBYTNS
read -p "What is Primary DB Unique name [ORCLA]: " PRIMUNQ
read -p "What is Standby DB Unique name [ORCLB]: " STBYUNQ

ORACLE_SID=${ORACLE_SID:-ORCL}
PRIMUNQ=${PRIMUNQ:-ORCLA}
STBYUNQ=${STBYUNQ:-ORCLB}
PRIMTNS=${PRIMTNS:-CLHOLVM1}
STBYTNS=${STBYTNS:-CLHOLVM2}

echo "export ORACLE_SID=${ORACLE_SID}" > ${MY_ENV_FILE} 
echo "export PRIM=${PRIM}" >> ${MY_ENV_FILE} 
echo "export STBY=${STBY}" >> ${MY_ENV_FILE} 
echo "export PRIMUNQ=${PRIMUNQ}" >> ${MY_ENV_FILE} 
echo "export STBYUNQ=${STBYUNQ}" >> ${MY_ENV_FILE}
echo "export PRIMTNS=${PRIMTNS}" >> ${MY_ENV_FILE}
echo "export STBYTNS=${STBYTNS}" >> ${MY_ENV_FILE}
