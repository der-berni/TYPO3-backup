#!/bin/bash

# (c) Copyright
# der-berni

__PROGNAME=$(basename $0)
__SCRIPT_VERSION=13.281

__DATE=`date +"%Y-%m-%d"`
__CURDIR=$(dirname $0)
cd ${__CURDIR}

__CONFIG_FILE=
__BACKUP_DIR=
__BACKUP_DEST=
__BACKUP_DAYS=
__TYPO_VERSION=

function __deleteOldBackup {
	__OLDESTBACKUP=$(ls -tr1 ${__BACKUP_DEST}/${__INSTANZE_NAME}/*.tar.gz 2>/dev/null | awk 'NR==1{print}')
	__OLDESTBACKUP=${__OLDESTBACKUP##*/}
	__OLDESTBACKUP=${__OLDESTBACKUP#*_}
	__OLDESTBACKUP=${__OLDESTBACKUP%%_*}
	echo "Delete oldest Backup from     : ${__OLDESTBACKUP}"
	echo "rm -rf ${__BACKUP_DEST}/${__INSTANZE_NAME}/backup_${__OLDESTBACKUP}_typo3_*.gz"
	rm -rf ${__BACKUP_DEST}/${__INSTANZE_NAME}/backup_${__OLDESTBACKUP}_typo3_*.gz
	__MYCOUNT=$(ls ${__BACKUP_DEST}/${__INSTANZE_NAME}/*.tar.gz 2>/dev/null | wc -l)
}

while :
do
    case "$1" in
      -p)
	  __BACKUP_DIR="$2"
	  shift 2
	  ;;
      -o)
	  __BACKUP_DEST="$2"
	  shift 2
	  ;;
      -c)
	  __BACKUP_DAYS="$2"
	  shift 2
	  ;;
      -h | --help)
	  echo "COMMAND [options] <parameters>"
	  echo "Parameter are mandatory:"
	  echo "-p <path instance>            : path of the site root directory"
	  echo "-o <path output>              : path to the backup directory"
	  echo "Parameter are optional :"
	  echo "-c <count>                    : number of how many backups to keep"
	  echo "-h                            : show this help"
	  exit 0
	  ;;
      *)  # No more options
	  break
	  ;;
    esac
done

echo "**********************************************************************"
echo "TYPO3 Backup v.${__SCRIPT_VERSION}"
echo "**********************************************************************"

if [[ -z "${__BACKUP_DIR}" && -z "${__BACKUP_DEST}" ]]; then
	./${__PROGNAME} -h
	exit 0
else

	echo "date                          : ${__DATE}"
	
	if [ -f "${__BACKUP_DIR}/typo3conf/localconf.php" ]; then
		__CONFIG_FILE="${__BACKUP_DIR}/typo3conf/localconf.php"
		__DB_NAME=$(cat ${__CONFIG_FILE} | grep '\$typo_db\ ' | cut -d "'" -f 2)
		__DB_USER=$(cat ${__CONFIG_FILE} | grep '\$typo_db_username\ ' | cut -d "'" -f 2)
		__DB_PASSWORD=$(cat ${__CONFIG_FILE} | grep '\$typo_db_password\ ' | cut -d "'" -f 2)
		__DB_HOST=$(cat ${__CONFIG_FILE} | grep '\$typo_db_host\ ' | cut -d "'" -f 2)
		__CONFIG_FILE="${__BACKUP_DIR}/t3lib/config_default.php"
		__TYPO_VERSION=$(cat ${__CONFIG_FILE} | grep "\$TYPO_VERSION =*" | cut -d "'" -f 2);
	elif [ -f "${__BACKUP_DIR}/typo3conf/LocalConfiguration.php" ]; then
		__CONFIG_FILE="${__BACKUP_DIR}/typo3conf/LocalConfiguration.php"
		__DB_NAME=$(cat ${__CONFIG_FILE} | grep \'database\'\ =\> | cut -d "'" -f 4)
		__DB_USER=$(cat ${__CONFIG_FILE} | grep \'username\'\ =\> | cut -d "'" -f 4)
		__DB_PASSWORD=$(cat ${__CONFIG_FILE} | grep \'password\'\ =\> | cut -d "'" -f 4)
		__DB_HOST=$(cat ${__CONFIG_FILE} | grep \'host\'\ =\> | cut -d "'" -f 4)
		__CONFIG_FILE="${__BACKUP_DIR}/sysext/core/Classes/Core/SystemEnvironmentBuilder.php"
		__TYPO_VERSION=$(cat ${__CONFIG_FILE} | grep "'TYPO3_version'," | cut -d "'" -f 4);
	fi

	if [ -z "${__CONFIG_FILE}" ]; then
		echo "ERROR                         : TYPO3 configuration not found"
		exit 1
	fi

	__INSTANZE_NAME=${__BACKUP_DIR##*/}
	
	if [[ ! -d ${__BACKUP_DEST}/${__INSTANZE_NAME} ]]; then
		mkdir -p  ${__BACKUP_DEST}/${__INSTANZE_NAME}
	fi
	
	if [[ -z "${__BACKUP_DAYS}" ]]; then
		__BACKUP_DAYS=0
	fi
	
	__MYCOUNT=$(ls ${__BACKUP_DEST}/${__INSTANZE_NAME}/*.tar.gz 2>/dev/null | wc -l)
	
	echo "TYPO3 path                    : \"${__BACKUP_DIR}\""
	echo "TYPO3 version                 : ${__TYPO_VERSION}"
	echo "Instance                      : \"${__INSTANZE_NAME}\""
	echo "Database                      : \"${__DB_NAME}\""
	echo "Total Backups                 : ${__MYCOUNT}"
	echo "Backups to keep               : ${__BACKUP_DAYS}"
	
	while [[ ${__MYCOUNT} -gt ${__BACKUP_DAYS} ]]; do
		__deleteOldBackup
	done
	
	echo "Create Backup of Database..."
	echo "mysqldump -u ${__DB_USER} -p${__DB_PASSWORD} -h ${__DB_HOST} ${__DB_NAME} | gzip -9 > \"${__BACKUP_DEST}/${__INSTANZE_NAME}/backup_${__DATE}_typo3_${__TYPO_VERSION}_database.sql.gz\""
	mysqldump -u ${__DB_USER} -p${__DB_PASSWORD} -h ${__DB_HOST} ${__DB_NAME} | gzip -9 > "${__BACKUP_DEST}/${__INSTANZE_NAME}/backup_${__DATE}_typo3_${__TYPO_VERSION}_database.sql.gz"

	echo "Create Backup of Files..."
	echo "tar czf \"${__BACKUP_DEST}/${__INSTANZE_NAME}/backup_${__DATE}_typo3_${__TYPO_VERSION}_files.tar.gz\" -P --exclude \"${__BACKUP_DIR}/typo3temp/*\" \"${__BACKUP_DIR}\""
	tar czf "${__BACKUP_DEST}/${__INSTANZE_NAME}/backup_${__DATE}_typo3_${__TYPO_VERSION}_files.tar.gz" -P --exclude "${__BACKUP_DIR}/typo3temp/*" "${__BACKUP_DIR}"
	
	echo "TYPO3 Backup success"
fi

exit 0
