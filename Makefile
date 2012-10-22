
VERSION=1.8
UUCP_LOCK_DIR=/var/lock

RM=rm -f
CC=gcc
LD=$(CC)
PREFIX ?= $(HOME)
BINDIR ?= $(PREFIX)/bin

CPPFLAGS=-DVERSION_STR=\"$(VERSION)\" \
         -DUUCP_LOCK_DIR=\"$(UUCP_LOCK_DIR)\" \
         -DHIGH_BAUD

CFLAGS = -Wall -Wextra -g
LDFLAGS= -ggdb

ifdef DEBUG
OPT=-O0
else
OPT=-Os
endif

ifndef NO_LTO
LDFLAGS += -flto $(CFLAGS) $(OPT)
CFLAGS  += -flto
else
CFLAGS  += $(OPT)
endif

picocom : picocom.o term.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o : %.c term.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

doc : picocom.8 picocom.8.html picocom.8.ps

changes :
	svn log -v . > CHANGES

picocom.8 : picocom.8.xml
	xmlmp2man < $< > $@

picocom.8.html : picocom.8.xml
	xmlmp2html < $< > $@

picocom.8.ps : picocom.8
	groff -mandoc -Tps $< > $@

install :
	mkdir -p $(BINDIR)
	install -t $(BINDIR) picocom
	install -t $(BINDIR) pcxm pcym pczm pcasc

uninstall:
	$(RM) $(BINDIR)/picocom
	$(RM) $(BINDIR)/pcxm $(BINDIR)/pcym $(BINDIR)/pczm $(BINDIR)/pcasc

clean:
	$(RM) picocom.o term.o
	$(RM) *~
	$(RM) \#*\#

distclean: clean
	$(RM) picocom

realclean: distclean
	$(RM) picocom.8
	$(RM) picocom.8.html
	$(RM) picocom.8.ps
	$(RM) CHANGES
