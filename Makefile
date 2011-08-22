SHELL    = /bin/sh
PREFIX   = /usr/local
execdir  = $(PREFIX)/bin

datadir  = $(PREFIX)/share
mandir   = $(datadir)/man

PROGRAM  = git-sub
SOURCES  = git-sub.bash
RONN     = ronn --date=2011-08-20 \
					 --organization='Greg Osuri'

all: $(PROGRAM)

$(PROGRAM): $(SOURCES)
	rm -f $@
	cat $(SOURCES) > $@+
	bash -n $@+
	mv $@+ $@
	chmod 0755 $@

$(PROGRAM).1.roff: $(PROGRAM).1.ronn
	$(RONN) $^ > $@

$(PROGRAM).1.html: $(PROGRAM).1.ronn
	$(RONN) -5 $^ > $@

doc: $(PROGRAM).1.roff $(PROGRAM).1.html

run: all
	./$(PROGRAM)

install: $(PROGRAM)
	install -d "$(execdir)"
	install -m 0755 $(PROGRAM) "$(execdir)/$(PROGRAM)"
	install -d "$(mandir)/man1"
	install -m 0644 $(PROGRAM).1.roff "$(mandir)/man1/$(PROGRAM).1"

uninstall:
	rm -f $(execdir)/$(PROGRAM)
	rm -f $(mandir)/man1/$(PROGRAM).1

clean:
	rm -f $(PROGRAM)
	rm -f $(PROGRAM).1
	rm -f $(PROGRAM).1.html

pages: $(PROGRAM).1.html
	cp $^ pages/$^

.PHONY: run install site clean pages
