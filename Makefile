#!/usr/bin/make

ODIR=build

vpath %.html $(ODIR)

all: amba.md
	reveal-md --theme moon --static $(ODIR) $<

clean:
	rm -fr $(ODIR)
