CC=zcc +cpm -compiler=sdcc
#CFLAGS := -O2 -Wall -Werror -DDEBUG=1
CFLAGS := -O2 -Wall -DDEBUG=1

all: KOCH.COM D7220.COM

KOCH.COM: koch.o gdc7220.o
	$(CC) $(CFLAGS) $(OFLAG) koch.o gdc7220.o -o koch -lmath48 -create-app

D7220.COM: d7220.o gdc7220.o
	$(CC) $(CFLAGS) $(OFLAG) d7220.o gdc7220.o -o d7220 -create-app

gdc7220.o: gdc7220.c gdc7220.h rhyophyre.h
koch.o: koch.c gdc7220.h
d7220.o: d7220.c gdc7220.h

clean:
	rm -f *.o *.lis *.map koch KOCH.COM d7220 D7220.COM


