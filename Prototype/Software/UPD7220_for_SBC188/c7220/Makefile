# To compile using SDCC, add '-compiler=sdcc' to CC and remove -Werror from CFLAGS.

CC=zcc +cpm
CFLAGS := -O2 -Wall -Werror -DDEBUG=1

all:	C7220.COM

C7220.COM: c7220.o
	$(CC) $(CFLAGS) $(OFLAG) c7220.o -o c7220 -create-app

c7220.o: c7220.c rhyophyre.h mytypes.h

clean:
	rm -f *.o *.lis *.map C7220.COM c7220


