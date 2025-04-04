#!/bin/bash
LOCATIONS_FILE="/Users/davidbland/Code/backup-script/locations.cfg"
LOCATION_NUM=0
LINE_COUNT=1
RESTORE_NUM=0

usage() {
	echo "-B  Backup all locations"
	echo "-L [n]  Specify backup location"
	echo "-R [n]  Specify which backup to restore"
}

listlocations() {
	while IFS= read	-r location; do
		echo "$LINE_COUNT: $location"
		((LINE_COUNT++))
	done < "$LOCATIONS_FILE"
}

compressfile() {
	REMOTE=$1
	BACKUP=$2
	PATH_AND_FILE=$3
	TIMESTAMP=$4
	DEST=$5
	JUST_PATH=$(dirname "$PATH_AND_FILE")
	JUST_FILE=$(basename "$PATH_AND_FILE")

	ORIGINAL_SIZE=$(ssh "$REMOTE" "ls -l '$JUST_PATH/$JUST_FILE' | awk '{print \$5}'")
	TAR_SIZE=$(ssh "$REMOTE" "tar -czf - -C $JUST_PATH $JUST_FILE" | tee "$DEST/$TIMESTAMP/$JUST_FILE.tar.gz" | wc -c)
	
	echo "${REMOTE} - ${TIMESTAMP} - Original Size: $ORIGINAL_SIZE bytes, Compressed Size: $TAR_SIZE bytes" >> "/Users/davidbland/.backup/alien_log" 

	if [ $? -eq 0 ]; then
		echo "tar created successfully"
	else
		echo "failed to create tar and transport"
		exit 1
	fi
}

backup() {
	TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
	
	for line in "$@"; do
		IFS=":" read -r -a array <<< "$line"
		BACKUP="${array[1]}"
		REMOTE="${array[0]}"
	
		IFS="/" read -r -a array2 <<< "$BACKUP"
		LASTINDEX=$((${#array2[@]} - 1))
		DEST="/Users/davidbland/.backup/${array2[${LASTINDEX}]}-${REMOTE}"
		mkdir -p "$DEST/$TIMESTAMP"
	
		excluded_files=($(ssh -n "$REMOTE" "find '$BACKUP' -name '*.xyzar'"))
		rsync -avz --exclude="*.xyzar" "$REMOTE:$BACKUP/" "$DEST/$TIMESTAMP"

		while IFS= read -r file; do
		    compressfile "$REMOTE" "$BACKUP" "$file" "$TIMESTAMP" "$DEST"
		done < <(ssh -n "$REMOTE" "find '$BACKUP' -name '*.xyzar'")
			
		if [ $? -eq 0 ]; then
			echo "backup successfully" 
		else
			echo "Failed to backup" 
			exit 1
		fi
	done
}

startRestoreOrBackup() {
	LOCATIONS=()

	while IFS= read -r line; do
		LOCATIONS+=("$line")
	done < "locations.cfg"

	if [[ $LOCATION_NUM -gt 0 ]]
	then
		SINGLE_LOCATION=("${LOCATIONS[$LOCATION_NUM - 1]}")
		if [[ $RESTORE_NUM -gt 0 ]]
		then
			restore "${SINGLE_LOCATION[@]}"
		else
			backup "${SINGLE_LOCATION[@]}" 	
		fi
	elif [[ $BACKUP_OPT == true ]]
	then
		backup "${LOCATIONS[@]}"		
	else
		echo "Please select a location to restore from"
	fi
}

restore() {
	# Restor files
	for line in "$@"; do
		IFS=":" read -r -a array <<< "$line"
		BACKUP="${array[1]}"
		REMOTE="${array[0]}"

		IFS="/" read -r -a array2 <<< "$BACKUP"
		LASTINDEX=$((${#array2[@]} - 1))
		DEST="/Users/davidbland/.backup/${array2[${LASTINDEX}]}-${REMOTE}"
		echo "Removing files from ${REMOTE}:${BACKUP}"	
		ssh ${REMOTE} "mkdir -p ${BACKUP}/.tmp && mv ${BACKUP}/* ${BACKUP}/.tmp"
			
		LATEST_DIR=$(ls -1 "$DEST" | sort -r | head -n ${RESTORE_NUM} | tail -n 1)

		rsync -avz "$DEST/$LATEST_DIR/" "$REMOTE:$BACKUP" 
	done
}

while getopts ":hBL:R:" opt; do
	case $opt in
		h) 
			usage
			;;
		B)
			BACKUP_OPT=true
			;;
		L)
			LOCATION_NUM="$OPTARG"
			;;
		R)
			RESTORE_NUM=${OPTARG:-1}
			;;
	esac
done

if [[ $OPTIND == 1 ]]
then
	listlocations
fi

if [[ "${BACKUP_OPT}" == true && "${RESTORE_NUM}" -gt 0 ]]
then
	echo "You can not backup and restore at the same time"
elif [[ "${BACKUP_OPT}" == true || "${RESTORE_NUM}" -gt 0 ]]
then
	startRestoreOrBackup	
fi
