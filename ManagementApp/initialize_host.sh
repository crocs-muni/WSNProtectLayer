#!/bin/sh

DATABASE="WSNProtectLayer";
USER="root";
HOST="localhost";

while getopts ":u:h:d:" opt; do
	case $opt in
		u)
			USER=$OPTARG
			;;
		h)
			HOST=$OPTARG
			;;
		d)
			DATABASE=$OPTARG
			;;
		\?)
			echo "Invalid argument -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

SQL="INSERT INTO node VALUES ";

for i in `ls -1 /dev/mote_telos*`; do
	TMP=`echo $i | sed -e 's/\/dev\/mote_telos\([0-9]\{1,2\}\)/(\1, "\0")/'`
	SQL=$SQL$TMP
done

SQL=$SQL";"

#echo $SQL;

echo "Please enter $USER:$DATABASE@$HOST password:"
echo $SQL | mysql -u $USER -p -h $HOST $DATABASE
