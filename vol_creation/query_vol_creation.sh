#!/usr/bin/env bash
# query_availability.sh

source ./querycommon.sh

function usage {
  echo "Usage: $0 [OPTION]..."
  echo "Query Volume Creation Failure"
  echo ""
  echo "  -S, --seconds        	Failure during these many seconds before to now"
  echo "  -X, --minutes        	Failure during these many minutes before to now"
  echo "  -H, --hours        	Failure during these many hours before to now"
  echo "  -D, --days        	Failure during these many days before to now"
  echo "  -W, --weeks        	Failure during these many weeks before to now"
  echo "  -M, --months        	Failure during these many months before to now"
  echo ""
}

seconds=0
minutes=0
months=0
weeks=0
days=0
hours=0

while [ $# -gt 0 ]; do
  case "$1" in
	-S|--seconds) seconds=$2; shift;;
	-X|--minutes) minutes=$2; shift;;
    	-H|--hours) hours=$2; shift;;
	-D|--days) days=$2; shift;;
	-W|--weeks) weeks=$2; shift;;
	-M|--months) months=$2; shift;;
  esac
  shift
done

#echo "hours=$hours, days=$days, weeks=$weeks, months=$months"

if  [ \( $seconds -eq 0 -a $minutes -eq 0 -a $hours -eq 0  -a   $days -eq 0  -a  $weeks -eq 0  -a  $months -eq 0  \) ] ; then

	usage
	exit 1
fi

compute_evtcnt volume.create.attempted $seconds $minutes $hours $days $weeks $months  cnt_attempted_rval ttc_attempted_rval
compute_evtcnt volume.create.failed $seconds $minutes $hours $days $weeks $months  cnt_failed_rval ttc_failed_rval

passperc=$(( ( ( $cnt_attempted_rval - $cnt_failed_rval ) * 100 ) / $cnt_attempted_rval ))

echo -e "             ----------------------------------"
echo -e "             Volume Creation Pass Rate : $passperc%"
echo -e "             From : [$ttc_failed_rval]       "
echo -e "             ----------------------------------"
