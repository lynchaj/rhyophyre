## make test programs for the uPD7220 v2 board
#
#
#  call ccomp c700
#
DEBUG = -DDEBUG=0
OPTS = -Zi -G2 -Zp1 -W0 -Os
MODEL = /AT
#
.c.obj:
        cl -c $(MODEL) $(OPTS) $(DEBUG) $*.c

.obj.exe:
        link /ma $**;

all:    d7220.exe c7220.exe



clean:
        del *.exe
        del *.obj


### Dependencies
sbc188.h:       mytypes.h
c7220.obj:      c7220.c sbc188.h
c7220.exe:      c7220.obj
ut7220.obj:     ut7220.c sbc188.h
d7220.obj:      d7220.c sbc188.h
d7220.exe:      d7220.obj

