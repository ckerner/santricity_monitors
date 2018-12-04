CURDIR=$(shell pwd)
LOCLDIR=/usr/local/bin

install: mon_progs

update: mon_progs

mon_progs:   .FORCE
	cp -p $(CURDIR)/check_longrunning.pl $(LOCLDIR)/check_longrunning.pl
	cp -p $(CURDIR)/check_failed_disks.pl $(LOCLDIR)/check_failed_disks.pl
	cp -p $(CURDIR)/set_md_time.pl $(LOCLDIR)/set_md_time.pl

clean:
	rm -f $(LOCLDIR)/check_longrunning.pl
	rm -f $(LOCLDIR)/check_failed_disks.pl
	rm -f $(LOCLDIR)/set_md_time.pl

cron:   .FORCE
	echo '#' >>/var/spool/cron/root
	echo '# Check long running disk controller processes every even hour' >>/var/spool/cron/root
	echo '# 20 00,02,04,06,08,10,12,14,16,18,20 * * * /usr/local/bin/check_longrunning.pl CTRL1 CTRL2 ...' >>/var/spool/cron/root
	echo '#' >>/var/spool/cron/root
	echo '# # Set the time on the Dell disk contollers' >>/var/spool/cron/root
	echo '# 10 00 * * * /usr/local/bin/set_md_time.pl CTRL1 CTRL2 ...' >>/var/spool/cron/root
	echo '#' >>/var/spool/cron/root
	echo '# # Check for failed disks every odd hour.          ' >>/var/spool/cron/root
	echo '# 20 01,03,05,07,09,11,13,15,17,19,21,23 * * * /usr/local/bin/check_failed_disks.pl CTRL1 CTRL2 ...' >>/var/spool/cron/root
	echo '#' >>/var/spool/cron/root

.FORCE:


