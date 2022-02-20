project = contacts
srcdir = Sources/contacts-cli
mansubdir = man
binsubdir = bin
prefix ?= /usr/local
mandir ?= $(prefix)/share/$(mansubdir)/man1
mans = $(addprefix $(mansubdir)/,*.1)
srcfiles = $(addprefix $(srcdir)/,main.swift)
versionfiles = $(addprefix $(srcdir)/,version.json)

# distribution variables
VERSIONNUM:=$(shell test -d .git && git describe --abbrev=0 --tags)
BUILDNUM:=$(shell test -d .git && git rev-parse --short HEAD)
distdir = $(project)-$(VERSIONNUM)

# ronn/man variables
rdate = `date +'%Y-%m-%d'`
rmanual = contacts
rorg = protozoic

all: docs $(binsubdir)/contacts 

docs: $(mans)

test: 
	echo $(VERSIONNUM)
	echo ${prefix}
	echo ${mandir}

# run xcodebuild if src has changed.  Make bin/ if it doesn't exist.
$(binsubdir)/contacts: $(srcfiles) | $(binsubdir) version
	./version-update.sh $(srcdir)/version.json
	swift build -c release
	mv .build/release/contacts bin/

# make bin/
$(binsubdir):
	-mkdir -p $(binsubdir)

# make man/
$(mansubdir):
	-mkdir -p $(mansubdir)

# copy man files to man/ - make man/ if it doesn't exist.
$(mansubdir)/%.1: $(srcdir)/%.1 | $(mansubdir)
	cp $< $(mansubdir)/

# install files to their proper locations.
install: bin/contacts man
	-mkdir -p $(prefix)
	-mkdir -p $(prefix)/bin
	-mkdir -p $(mandir)
	install $(binsubdir)/* $(prefix)/bin/
	install -m 644 $(mansubdir)/* $(mandir)

# make the man files from the ronn files if needed
$(srcdir)/%.1: $(srcdir)/%.1.ronn
	ronn -r --date=$(rdate) --manual="$(rmanual)" --organization="$(rorg)" $(srcdir)/$*.1.ronn

# remove generated man files
cleanroff: cleanman
	-rm $(srcdir)/*.1

# remove installed man files
cleanman:
	-rm -rf $(mansubdir)

dist: all
	-mkdir -p $(distdir)
	git archive develop | tar -x -C $(distdir)
	tar czf $(distdir).tgz $(distdir)
	rm -rf $(distdir)

distclean: clean cleantgz

clean: cleanman
	-rm -rf build
	-rm -rf bin
	-rm -f *~

cleantgz:
	-rm -f $(distdir).tgz
