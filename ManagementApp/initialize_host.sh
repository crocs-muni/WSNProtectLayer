#!/bin/sh

#print usage
function printHelp(){
	echo -e "Usage:" >&2
	echo -e "\t./initialize_host.sh [-u -s -d]\n" >&2
	echo -e "\t-u \tDatabase user, default: root" >&2
	echo -e "\t-d \tDatabase name, default: WSNProtectLayer" >&2
	echo -e "\t-s \tDatabase server, default: localhost\n" >&2

	echo -e "Example:" >&2
	echo -e "\t./initialize_host.sh -u root -d WSNProtectLayer -s localhost\n" >&2
}

DATABASE="WSNProtectLayer";
USER="root";
HOST="localhost";

while getopts ":u:s:d:h" opt; do
	case $opt in
		u)
			USER=$OPTARG
			;;
		s)
			HOST=$OPTARG
			;;
		d)
			DATABASE=$OPTARG
			;;
		h)
			printHelp
			exit 0
			;;
		\?)
			echo -e "Invalid argument -$OPTARG\n" >&2
			printHelp
			exit 1
			;;
		:)
			echo -e "Option -$OPTARG requires an argument.\n" >&2
			printHelp
			exit 1
			;;
	esac
done

SQL="INSERT INTO node VALUES ";

#build values
for i in `ls -1 /dev/mote_telos*`; do
	TMP=`echo $i | sed -e 's/\/dev\/mote_telos\([0-9]\{1,2\}\)/(\1, "\0")/'`
	SQL=$SQL$TMP","
done

#remove last ,
SQL=${SQL%","}

#add ; at end
SQL=$SQL";"

#add database structure before nodes
STRUCT=`cat WSNProtectLayer.sql`;
SQL=$STRUCT$SQL;

#echo $SQL;

#connect to database and save data
echo "Please enter $USER:$DATABASE@$HOST password:"
echo $SQL | mysql -u $USER -p -h $HOST $DATABASE
