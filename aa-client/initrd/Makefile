#SYSTEMDSYSDIR=/usr/lib/systemd/system
SYSTEMDSYSDIR=$(shell pkg-config  --variable=systemdsystemunitdir systemd)
#DRACUTMODDIR=/usr/lib/dracut/modules.d/
DRACUTMODDIR=$(shell pkg-config  --variable=dracutmodulesdir dracut)
DRACUTAADIR=$(DRACUTMODDIR)/65aaclient
PREFIX?=/usr/local
BINDIR=$(PREFIX)/bin

.PHONY: all install uninstall
all: install

install:
	mkdir -p $(DESTDIR)$(SYSTEMDSYSDIR) $(DESTDIR)$(DRACUTAADIR) $(DESTDIR)$(BINDIR)
	#@ls -d $(SYSTEMDSYSDIR) $(DRACUTMODDIR)
	#@ls -d $(SYSTEMDSYSDIR) $(DRACUTAADIR)
	install aa-client.service $(DESTDIR)$(SYSTEMDSYSDIR)
	install module-setup.sh $(DESTDIR)$(DRACUTAADIR)
	install aa-client-service.sh $(DESTDIR)$(BINDIR)

uninstall:
	rm -f $(DESTDIR)$(SYSTEMDSYSDIR)/aa-client.service
	rm -rf $(DESTDIR)$(DRACUTAADIR)
	rm -f $(DESTDIR)$(BINDIR)/aa-client-service.sh


INITRD=/boot/initramfs-$(shell uname -r).img
ORIGINITRD=$(INITRD).orig
# aa-client is required when running dracut
initrd: # $(BINDIR)/aa-client
	test -e $(ORIGINITRD) || mv $(INITRD) $(ORIGINITRD)
	dracut -f $(INITRD) $(shell uname -r)
