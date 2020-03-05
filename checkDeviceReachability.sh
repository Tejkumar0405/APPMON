#!/bin/bash
#------------------------------------------------------------------------------
#
# Name         : checkDeviceReachability.sh
# Description  : Check device reachability from VEMS
# Author       : Vikram Shekhar
#
# Copyright(c) 2014, Verizon Wireless. All rights reserved.
# Confidential and Proprietary.
#
#------------------------------------------------------------------------------
PATH=/usr/bin:/bin
export PATH

#*****************************************************************
#
# Execute initial checks
#
#*****************************************************************
initialChecks()
{
  # check if user is root
  [ "`/usr/bin/id -u`" != 0 ] && /bin/echo -e "\nYou must be root user to execute the tool.\n" && exit 1
}

#*****************************************************************
#
# Set logging with date_time
#
#*****************************************************************
vlog()
{
    /bin/echo -e "`/bin/date +'%d/%m/%y:%H:%M:%S'`: $*" | tee -a $LOG
}

#------------------------------------------------------------------------------
#
# Check connection to database
#
#------------------------------------------------------------------------------
checkReachability ()
{
  vlog "Begin reachability check"
  if [ -d /opt/postgres/postgresql/postgres/bin ]; then
    PGSQL=/opt/postgres/postgresql/postgres/bin/psql
  elif [ -d /opt/vems/postgresql/postgres/bin ]; then
    PGSQL=/opt/vems/postgresql/postgres/bin/psql
  else
    echo "Cannot find DB client cannot connect do db."
    return;
  fi

  #DB_ARGS="-h dbvip -p 55432 -U admin"
  DB_ARGS="-p 55432 -U admin"
  DB_NAME=WASP_DB
  DB_QUERY="select rd.ipaddress as \"Device IP Address\", to_timestamp(sr.periodfrom/1000) as \"Unreachable From\", to_timestamp(sr.periodto/1000) as \"Unreachable To\" from resourcedetails rd, system_reachability sr where rd.resourceid = sr.resourceid and sr.isreachable = 1;"
  DB_RESULT=`$PGSQL $DB_ARGS -c "$DB_QUERY" $DB_NAME`

  QUERY_TOTAL_DEVICES_COUNT="select count(*) from resourcedetails where resourcetypeid not in (0,107,108);"
  QUERY_CURRENT_UNREACHABLE_COUNT="select count(rd.ipaddress) from resourcedetails rd, resourcereachabilitystatus rrs where rd.resourceid = rrs.resourceid and rrs.snmpstatus != 1 and rd.resourcetypeid not in (0,107,108);"
  CURRENT_UNREACHABLE_COUNT=`$PGSQL $DB_ARGS -t -c "$QUERY_CURRENT_UNREACHABLE_COUNT" $DB_NAME`
  CURRENT_TOTAL_DEVICES_COUNT=`$PGSQL $DB_ARGS -t -c "$QUERY_TOTAL_DEVICES_COUNT" $DB_NAME`

  UNREACHABLE_PERCENT=`echo "$CURRENT_UNREACHABLE_COUNT * 100 / $CURRENT_TOTAL_DEVICES_COUNT" | bc`
  
  echo "$DB_RESULT" | $TEELOG
  vlog "End reachability check\n"
  echo "Number of devices currently unreachable are: $CURRENT_UNREACHABLE_COUNT" | $TEELOG
  echo "Total number of managed devices are: $CURRENT_TOTAL_DEVICES_COUNT" | $TEELOG
  echo "$UNREACHABLE_PERCENT% of Devices managed by VEMS are currently unreachable." | $TEELOG
  echo
}

#------------------------------------------------------------------------------
#
# Display user input
#
#------------------------------------------------------------------------------
display_usage()
{
  vlog "Check device reachability from VEMS:"
  vlog "$0 [-h]"
  vlog "-h  :  Display this message"
}

#------------------------------------------------------------------------------
#
# Begin Main
#
#------------------------------------------------------------------------------
# Set initial variables
#
HOSTNAME=`hostname`
LOCAL_PROC=$$

LOG_HOME=/var/log
LOG=${LOG_HOME}/`basename $0`.log
TEELOG="tee -a $LOG"

initialChecks
checkReachability

exit 0

