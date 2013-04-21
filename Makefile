XCODEBUILD=/usr/bin/xcodebuild
project = contacts
srcdir = contacts
mandir = man
bindir = bin
prefix = /usr/local
mans = $(addprefix $(mandir)/,*.1)
srcfiles = $(addprefix $(srcdir)/,contacts.m)

# distribution variables
VERSIONNUM:=$(shell git describe --abbrev=0 --tags)
BUILDNUM:=$(shell git rev-parse --short HEAD)
distdir = $(project)-$(VERSIONNUM)

# ronn/man variables
rdate = `date +'%Y-%m-%d'`
rmanual = BSD General Commands Manual
rorg = protozoic

all: $(bindir)/contacts $(mans)

# run xcodebuild if src has changed.  Make bin/ if it doesn't exist.
$(bindir)/contacts: $(srcfiles) | $(bindir)
	xcodebuild
	mv build/Release/contacts bin/

# make bin/
$(bindir):
	-mkdir $(bindir)

# make man/
$(mandir):
	-mkdir $(mandir)

# copy man files to man/ - make man/ if it doesn't exist.
$(mandir)/%.1: $(srcdir)/%.1 | $(mandir)
	cp $< $(mandir)/

# install files to their proper locations.
install: bin/contacts man
	-mkdir $(prefix)
	-mkdir $(prefix)/bin
	-mkdir -p $(prefix)/share/man
	install $(bindir)/* $(prefix)/bin/
	install -m 644 $(mandir)/* $(prefix)/share/$(mandir)/

# make the man files from the ronn files if needed
$(srcdir)/%.1: $(srcdir)/%.1.ronn
	ronn -r --date=$(rdate) --manual="$(rmanual)" --organization="$(rorg)" $(srcdir)/$*.1.ronn

# remove generated man files
cleanroff: cleanman
	-rm $(srcdir)/*.1

# remove installed man files
cleanman:
	-rm -rf $(mandir)

dist: all
	-mkdir -p $(distdir)
	git archive master | tar -x -C $(distdir)
	-cp $(srcdir)/Info.plist $(distdir)/$(srcdir)/Info.plist
	tar czf $(distdir).tgz $(distdir)
	rm -rf $(distdir)

distclean: clean cleantgz

clean: cleanman
	-rm -rf build
	-rm -rf bin
	-rm -f *~
	-rm -f $(srcdir)/Info.plist

cleantgz:
	-rm -f $(distdir).tgz
