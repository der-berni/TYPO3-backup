About
-----

This script allow you to backup your TYPO3 installation (Files and Databse).
The script will backup and compress your TYPO3 files and the dump of the Database.


Installation
------------

1] Upload the script to any directory OR download the script with wget:
```
wget --no-check-certificate "https://raw.github.com/der-berni/TYPO3-backup/master/t3backup.sh"
```

2] Allow your user to execute this script with a chmod

3] Execute the script

backup your TYPO3 instance (mandatory)
```
./t3backup.sh -p "/var/www/dummy package/" -o "/var/www/backup"
```

backup your TYPO3 instance and keep 21 backups
```
./t3backup.sh -p "/var/www/dummy package/" -o "/var/www/backup" -c 21
```


Example of execution
------------

	**********************************************************************
	TYPO3 Backup v.13.281
	**********************************************************************
	date                          : 2013-10-08
	TYPO3 path                    : "/var/www/dummy package/"
	TYPO3 version                 : 4.5.30
	Instance                      : "dummy package"
	Database                      : "my_db"
	Total Backups                 : 21
	Backups to keep               : 21
	Delete oldest Backup from     : 2013-03-10
	rm -rf "/var/www/backup/dummy package/backup_2013-03-10_typo3_*.gz"
	Create Backup of Database...
	mysqldump -u root -pmypass -h localhost my_db | gzip -9 > "/var/www/backup/dummy package/backup_2013-10-08_typo3_4.5.30_database.sql.gz"
	Create Backup of Files...
	tar czf "/var/www/backup/dummy package/backup_2013-10-08_typo3_4.5.30_files.tar.gz" -P --exclude "/var/www/dummy package/typo3temp/*" "/var/www/dummy package/"
	TYPO3 Backup success
