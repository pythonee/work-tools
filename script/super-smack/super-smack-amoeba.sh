#!/bin/sh

ARGS_COUNT=$#

# check the number of args
if [ ${ARGS_COUNT} -lt 3 ]
then
	echo "usage: ./super-smack-amoeba.sh clients loops times"
	exit
fi

# check awk file existed or not 
if [ ! -f ./super-smack.awk ] 
then
	echo "file super-smack.awk not found"
	exit
fi

SMACK_FILE=./smacks/select-key-amoeba.smack
# check smack file existed or not
if [ ! -f ${SMACK_FILE} ] 
then
	echo "smack file not found, path ${SMACK_FILE}"
	exit
fi

################################
# position args
# 1, concurrent clients number
# 2, client load loops
# 3, repeat times
################################
CLIENTS=${1}
LOOPS=${2}
TIMES=${3}

BACKEND="mysql"

AMOEBA_SERVER_IP=10.18.223.155

CAGENT_PATH=/usr/local/cc/cagent


TODAY=`date +%Y_%m_%d`

OUTPUT_FILE=AMOEBA_${CLIENTS}_${LOOPS}_${TODAY}.txt

CURRENT_RUN=0

# Add header
echo "Total Max_Q Min_Q Max_Conn Min_Conn Avg_Conn TPS" > ${OUTPUT_FILE}

while [ ${CURRENT_RUN} -lt ${TIMES} ]
do
	echo "start ${CLIENTS} ${LOOPS} ${CURRENT_RUN} run"

	# restart amoeba at the beginning
	ssh root@${AMOEBA_SERVER_IP} "cd ${CAGENT_PATH}; rm -rf log/ ; nohup ./stop.sh < /dev/null > /dev/null 2>&1; ./startup.sh </dev/null >/dev/null 2>&1  &"

	# poll to ask amoeba server whether restart done
	while sleep 1
	do 
		READY=`ssh root@${AMOEBA_SERVER_IP} "netstat -apn | grep 8066 | wc -l"`	

		if [ ${READY} -eq 1 ]
		then
			echo "restart ameoba done"
			ssh root@${AMOEBA_SERVER_IP} "ulimit -HSn 8192"	
			ulimit -HSn 8192
			
			echo "max open file " `ulimit -Sn`
			echo "max user process " `ulimit -u`

			super-smack -d ${BACKEND} ${SMACK_FILE} ${CLIENTS} ${LOOPS} | awk -f ./super-smack.awk >> ${OUTPUT_FILE}
			break
		else
			echo "amoeba have not restart yet..."
		fi
	done
	
	CURRENT_RUN=`expr ${CURRENT_RUN} + 1`
done

# calculate the average tps 
cat ${OUTPUT_FILE} | awk \
'BEGIN { tps_sum=0; times=0 } \
$0 { if(NR > 1) { tps_sum = tps_sum + $7; times = times + 1} } \
END { printf( "avg tps: %.2f\n", tps_sum/times ); }' | tee -a ${OUTPUT_FILE}

echo "done"

