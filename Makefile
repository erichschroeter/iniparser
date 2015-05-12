#
# iniparser Makefile
#
prefix ?= /usr
exec_prefix ?= $(prefix)
libdir ?= $(exec_prefix)/lib
includedir ?= $(exec_prefix)/include

# Compiler settings
CC      ?= gcc
CFLAGS	?= -O2
CFLAGS  += -fPIC -Wall -ansi -std=c99 -pedantic
INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 644

# Ar settings to build the library
AR	    ?= ar
ARFLAGS = rcv

SHLD = ${CC} ${CFLAGS}
LDSHFLAGS = -shared -Wl,-Bsymbolic
LDFLAGS += -Wl,-rpath -Wl,/usr/lib -Wl,-rpath,/usr/lib

# Set RANLIB to ranlib on systems that require it (Sun OS < 4, Mac OSX)
# RANLIB  = ranlib
RANLIB = true

RM      ?= rm -f


# Implicit rules

SUFFIXES = .o .c .h .a .so .sl

COMPILE.c	?= $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c

ifndef V
QUIET_AR	= @echo "AR	$@";
QUIET_CC	= @echo "CC	$@";
QUIET_LINK	= @echo "LINK	$@";
QUIET_RANLIB	= @echo "RANLIB	$@";
endif

.c.o:
	$(QUIET_CC)$(COMPILE.c) $(OUTPUT_OPTION) $<


SRCS = src/iniparser.c \
	   src/dictionary.c

OBJS = $(SRCS:.c=.o)


default:	libiniparser.a libiniparser.so

libiniparser.a:	$(OBJS)
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

libiniparser.so:	$(OBJS)
	$(QUIET_LINK)$(SHLD) $(LDSHFLAGS) $(LDFLAGS) -o $@.0 $(OBJS) \
		-Wl,-soname=`basename $@`.0

install:	default
	mkdir -p $(DESTDIR)$(libdir)
	$(INSTALL) -m 0644 libiniparser.a $(DESTDIR)$(libdir)
	$(INSTALL) -m 0755 libiniparser.so.0 $(DESTDIR)$(libdir)
	mkdir -p $(DESTDIR)$(includedir)/iniparser
	$(INSTALL_DATA) src/iniparser.h src/dictionary.h $(DESTDIR)$(includedir)/iniparser

clean:
	$(RM) $(OBJS)

veryclean:
	$(RM) $(OBJS) libiniparser.a libiniparser.so*
	rm -rf ./html ; mkdir html
	cd test ; $(MAKE) veryclean

docs:
	@(cd doc ; $(MAKE))
	
check: default
	@(cd test ; $(MAKE))

.PHONY: default clean veryclean docs check install
