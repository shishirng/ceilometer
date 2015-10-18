#!/usr/bin/env bash
# run_check_vol_creation.sh

source ./common/queryevt.sh

chkfreq=60 #minutes
vc_threshold=95

#chkfreq=10080

while :

do
       compute_evtcnt volume.create.attempted 0 $chkfreq 0 0 0 0  cnt_attempted_rval ttc_attempted_rval
       compute_evtcnt volume.create.failed 0 $chkfreq 0 0 0 0  cnt_failed_rval ttc_failed_rval

       passperc=100

       if [ $cnt_attempted_rval -ne 0 ]; then
	passperc=$(( ( ( $cnt_attempted_rval - $cnt_failed_rval ) * 100 ) / $cnt_attempted_rval ))
        echo "volume creation pass rate $passperc"
       fi

       if [ $passperc -lt $vc_threshold ]; then

		#echo "To:Ravikanth.Maddikonda@ril.com" > /tmp/mail.txt
		echo "To:raghvendra.maloo@ril.com" > /tmp/mail.txt
		echo "Subject:Volume Creation Success Rate Below Threshold!" >> /tmp/mail.txt
		echo "Volume Creation Success Rate Drop ALERT!! Volume Creation Success rate for last $chkfreq minutes is $passperc%" >> /tmp/mail.txt

		#curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "Ravikanth.Maddikonda@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
		curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure

        fi

       compute_evtcnt snapshot.create.attempted 0 $chkfreq 0 0 0 0  cnt_attempted_rval ttc_attempted_rval
       compute_evtcnt snapshot.create.failed 0 $chkfreq 0 0 0 0  cnt_failed_rval ttc_failed_rval

       passperc=100

       if [ $cnt_attempted_rval -ne 0 ]; then
	passperc=$(( ( ( $cnt_attempted_rval - $cnt_failed_rval ) * 100 ) / $cnt_attempted_rval ))
        echo "snapshot creation pass rate $passperc"
       fi

       if [ $passperc -lt $vc_threshold ]; then

		#echo "To:Ravikanth.Maddikonda@ril.com" > /tmp/mail.txt
		echo "To:raghvendra.maloo@ril.com" > /tmp/mail.txt
		echo "Subject:Snapshot Creation Success Rate Below Threshold!" >> /tmp/mail.txt
		echo "Snapshot Creation Success Rate Drop ALERT!! Snapshot Creation Success rate for last $chkfreq minutes is $passperc%" >> /tmp/mail.txt

		#curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "Ravikanth.Maddikonda@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
		curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure

        fi

	chkfreq_min=`echo "$chkfreq""m"`
        sleep $chkfreq_min
done
