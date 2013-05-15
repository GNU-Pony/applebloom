# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

PREFIX = /usr
DATA = /share
BIN = /bin
PKGNAME = applebloom
SHABANG = $(BIN)/bash
COMMAND = applebloom
LICENSES = $(PREFIX)$(DATA)

DICT = $(PREFIX)$(DATA)/$(PKGNAME)

WORDS = $(shell find dictionary | sed -e 's:^dictionary/::' | egrep -v '^\.' | egrep '\.(pony|human)$$')


all: applebloom doc

doc: info

info: applebloom.info.gz

%.info.gz: info/%.texinfo.install
	makeinfo "$<"
	gzip -9 -f "$*.info"

info/%.texinfo.install: info/%.texinfo
	cp "$<" "$@"
	sed -i 's:^@set DICT /usr/share/applebloom:@set DICT $(DICT):g' "$@"

applebloom: applebloom.sh
	cp "$<" "$@"
	sed -i 's:#!/bin/bash:#!$(SHEBANG)":' "$@"
	sed -i 's:dictionary=dictionary:dictionary="$(DICT)":' "$@"

install: applebloom applebloom.info.gz
	install -dm755 "$(DESTDIR)$(PREFIX)$(BIN)"
	install -m755 applebloom "$(DESTDIR)$(PREFIX)$(BIN)"
	install -dm755 "$(DESTDIR)$(DICT)"
	install -m755 -t "$(DESTDIR)$(DICT)" $(foreach WORD, $(WORDS), dictionary/$(WORD))
	install -dm755 "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	install -m644 COPYING LICENSE "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	install -dm755 "$(DESTDIR)$(PREFIX)$(DATA)/info"
	install -m644 applebloom.info.gz "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"

uninstall:
	rm -- "$(DESTDIR)$(PREFIX)$(BIN)/$(COMMAND)"
	rm -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)/COPYING"
	rm -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)/LICENSE"
	rmdir -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	rm -- "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"
	rm -r -- "$(DESTDIR)$(DICT)"

.PHONY: clean
clean:
	rm -f applebloom || true

