INSTALL_DESTDIR ?= /usr/local/bin

.PHONY: all aa-client install clean

DEBUG ?=

ifdef DEBUG
	RELEASE :=
	TARGETDIR=../target/debug
else
	RELEASE := --release
	TARGETDIR=../target/release
endif

AACLIENT=$(TARGETDIR)/aa-client
.PHONY: all aa-client install clean
all: aa-client


aa-client: $(AACLIENT)

$(AACLIENT):
	cargo build $(RELEASE) --bin aa-client

install: aa-client
	install -D -m0755 $(TARGETDIR)/aa-client $(INSTALL_DESTDIR)

.PHONY: uninstall remake
uninstall:
	rm -f $(TARGETDIR)/aa-client $(INSTALL_DESTDIR)/aa-client

remake: uninstall aa-client

clean:
	cargo clean

