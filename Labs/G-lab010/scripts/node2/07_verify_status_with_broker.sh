#!/bin/sh
. /home/oracle/myenv


${ORACLE_HOME}/bin/dgmgrl << EOF
 connect / ;
 show configuration lag verbose;
EOF
