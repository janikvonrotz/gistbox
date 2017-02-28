sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf --restore-file etc/nginx/conf.d/sebastianvonrotz.ch.conf ~/sebastianvonrotz.ch.conf -t 2015-08-17

sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf --list-current-files -t 2015-08-17
