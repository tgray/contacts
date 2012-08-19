XCODEBUILD=/usr/bin/xcodebuild
srcdir = contacts
mandir = man
prefix = /usr/local

all: bin/contacts man

bin/contacts:  $(srcdir)/contacts.m
	xcodebuild
	-mkdir bin
	mv build/Release/contacts bin/

man: $(mandir)/contacts.1

$(mandir)/contacts.1: $(srcdir)/contacts.1
	-mkdir $(mandir)
	cp $(srcdir)/contacts.1 $(mandir)/

install: bin/contacts man
	install bin/contacts $(prefix)/usr/bin
	install -m 644 $(mandir)/contacts.1 $(prefix)/$(mandir)

distclean: clean

clean:
	\rm -rf build
	\rm -rf bin
	\rm -rf $(mandir)
	\rm -f *~
