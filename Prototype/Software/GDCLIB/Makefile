CC=zcc +cpm
CFLAGS := -Wall -Werror -DDEBUG=1
#CFLAGS := -Wall -DDEBUG=1
OFLAG=-O2

all: KOCH.COM D7220.COM SHOWPCX.COM

KOCH.COM: koch.o gdc7220.o
	$(CC) $(CFLAGS) $(OFLAG) koch.o gdc7220.o -o koch -lmath48 -create-app

D7220.COM: d7220.o gdc7220.o
	$(CC) $(CFLAGS) $(OFLAG) d7220.o gdc7220.o -o d7220 -create-app

SHOWPCX.COM: showpcx.o pcx.o gdc7220.o
	$(CC) $(CFLAGS) $(OFLAG)  showpcx.o pcx.o gdc7220.o -o showpcx -create-app

gdc7220.o: gdc7220.c gdc7220.h rhyophyre.h
koch.o: koch.c gdc7220.h
d7220.o: d7220.c gdc7220.h
showpcx.o: showpcx.c pcx.h gdc7220.h
pcx.o: pcx.c pcx.h gdc7220.h

clean:
	rm -f *.o *.lis *.map koch KOCH.COM d7220 D7220.COM showpcx SHOWPCX.COM


