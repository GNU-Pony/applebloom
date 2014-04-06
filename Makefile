# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.


# The package path prefix, if you want to install to another root, set DESTDIR to that root
PREFIX ?= /usr
# The command path excluding prefix
BIN ?= /bin
# The resource path excluding prefix
DATA ?= /share
# The command path including prefix
BINDIR ?= $(PREFIX)$(BIN)
# The resource path including prefix
DATADIR ?= $(PREFIX)$(DATA)
# The generic documentation path including prefix
DOCDIR ?= $(DATADIR)/doc
# The info manual documentation path including prefix
INFODIR ?= $(DATADIR)/info
# The license base path including prefix
LICENSEDIR ?= $(DATADIR)/licenses

# Bash command to use in shebangs
SHEBANG ?= $(BIN)/bash
# The name of the command as it should be installed
PKGNAME ?= applebloom
# The name of the package as it should be installed
COMMAND ?= applebloom

# The dictionary directory
DICT = $(DATADIR)/$(PKGNAME)

# The dictionary files to install
WORDS = $(shell find dictionary | sed -e 's:^dictionary/::' | egrep -v '^\.' | egrep '\.(pony|human)$$')


# Build rules

.PHONY: default
default: applebloom info

.PHONY: all
all: applebloom doc

.PHONY: doc
doc: info pdf dvi ps

obj/%.texinfo: info/%.texinfo
	mkdir -p obj
	cp "$<" "$@"
	sed -i 's:^@set DICT /usr/share/applebloom:@set DICT $(DICT):g' "$@"
	sed -i 's:^@set COMMAND applebloom:@set COMMAND $(COMMAND):g' "$@"

obj/fdl.texinfo: info/fdl.texinfo
	mkdir -p obj
	cp "$<" "$@"

.PHONY: info
info: applebloom.info
%.info: obj/%.texinfo obj/fdl.texinfo
	makeinfo "$<"

.PHONY: pdf
pdf: applebloom.pdf
%.pdf: obj/%.texinfo obj/fdl.texinfo
	cd obj && yes X | texi2pdf "../$<"
	mv "obj/$@" "$@"

.PHONY: dvi
dvi: applebloom.dvi
%.dvi: obj/%.texinfo obj/fdl.texinfo
	cd obj && yes X | $(TEXI2DVI) "../$<"
	mv "obj/$@" "$@"

.PHONY: ps
ps: applebloom.ps
%.ps: obj/%.texinfo obj/fdl.texinfo
	cd obj && yes X | texi2pdf --ps "../$<"
	mv "obj/$@" "$@"


applebloom: applebloom.sh
	cp "$<" "$@"
	sed -i 's:#!/bin/bash:#!$(SHEBANG):' "$@"
	sed -i 's:dictionary=dictionary:dictionary="$(DICT)":' "$@"
	sed -i "/gettext/s/applebloom/$(COMMAND)/" "$@"
	sed -i "s/export TEXTDOMAIN=applebloom/export TEXTDOMAIN=$(PKGNAME)/" "$@"
	sed -i "s:export TEXTDOMAINDIR=/usr/share/locale:export TEXTDOMAINDIR='$(DATADIR)/locale':" "$@"
	sed -i "s:applebloomrc:$(COMMAND)rc:g" "$@"
	sed -i "s:/applebloom/:/$(COMMAND)/:g" "$@"


# Install rules

.PHONY: install
install: install-base install-info

.PHONY: install
install-all: install-base install-doc

.PHONY: install-base
install-base: install-command install-dict install-license

.PHONY: install-command
install-command: applebloom
	install -dm755 -- "$(DESTDIR)$(BINDIR)"
	install -m755 "$<" -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"

.PHONY: install-dict
install-dict:
	install -dm755 -- "$(DESTDIR)$(DICT)"
	install -m755 -t "$(DESTDIR)$(DICT)" $(foreach WORD, $(WORDS), dictionary/$(WORD))

.PHONY: install-license
install-license:
	install -dm755 -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	install -m644 COPYING LICENSE -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)"

.PHONY: install-doc
install-doc: install-info install-pdf install-dvi install-ps

.PHONY: install-info
install-info: applebloom.info
	install -dm755 -- "$(DESTDIR)$(INFODIR)"
	install -m644 "$<" -- "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"

.PHONY: install-pdf
install-pdf: applebloom.pdf
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 "$<" -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"

.PHONY: install-dvi
install-dvi: applebloom.dvi
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 "$<" -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"

.PHONY: install-ps
install-ps: applebloom.ps
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 "$<" -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"


# Uninstall rules

.PHONY: uninstall
uninstall:
	-rm -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"
	-rm -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)/COPYING"
	-rm -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)/LICENSE"
	-rmdir -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	-rm -- "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"
	-rm -r -- "$(DESTDIR)$(DICT)"


# Clean rules

.PHONY: clean
clean:
	-rm -rf applebloom applebloom.{info,pdf,dvi,ps} obj

