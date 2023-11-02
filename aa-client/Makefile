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

all: aa-client


aa-client:
	cargo build $(RELEASE) --bin aa-client

install: aa-client
	install -D -m0755 $(TARGETDIR)/aa-client $(INSTALL_DESTDIR)

clean:
	cargo clean

