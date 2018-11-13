CURDIR=$(shell pwd)
LOCLDIR=/usr/local/bin

install: mon_progs

update: mon_progs

mon_progs:   .FORCE
	cp -p $(CURDIR)/check_longrunning.pl $(LOCLDIR)/check_longrunning.pl

clean:
	rm -f $(LOCLDIR)/check_longrunning.pl
	rm -Rf /var/log/snapshots

cron:   .FORCE
	echo '# ' >>/var/spool/cron/root
	echo '# Check the disk controllers for long running jobs' >>/var/spool/cron/root
	echo '#00 01,13 * * * /usr/local/bin/check_longrunning.pl C1 C2' >>/var/spool/cron/root

.FORCE:


