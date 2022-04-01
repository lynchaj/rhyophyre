#  Use 'nmake' from Open Watcom 1.9 (open source)
#     This is the closest of them all to Unix 'make'
# 
#  MSC 7.00 'nmake' may also be used without modification
#
#  The scripts below now use the UnxUtils.zip package from:
#       http://sourceforge.net/
#
#  SDCC -- prefer 3.0.0 to 3.3.0
#  	The newer version results in excessively long compilation times
#	without producing more compact code
#

CC = sdcc -mz80
CCOPT =
#CCOPT = -D__SDCC__=1
#COPTS = $(CCOPT) --max-allocs-per-node 1000  # use with SDCC 3.3.0 (25000 for better code)
COPTS = $(CCOPT)

AS = sdasz80
#AOPTS = -plosff
AOPTS = -plosff
#LD = $(CC)
LD = sdldz80
LOPTS = --verbose --code-loc 0x100
RM = rm -f
HEX2BIN = ./hex2bin
BIN2HEX = bin2hex

HFILES = z180.h z180hc.h mytypes.h cprintf.h rhyophyre.inc clock.h
SFILES = z180hc.s z180cpu.s errors.s table.s literhyo.s
TEST0 = ycrt0.rel cprintf.rel sio0.rel delay.rel literhyo.rel io.rel cpu.rel \
	echo.rel clk-cal.rel nvtest.rel
ZIP0 = test0.bin *.txt *.c *.h *.s *.inc *.lnk Makefile

.SUFFIXES:       .s .rel .ihx .bin

.c.rel:
	$(CC) -c $(COPTS) -o $*.rel  $*.c

.s.rel:
	$(AS) $(AOPTS) $*.rel $*.s

.ihx.hex:
	copy $*.ihx $*.hex

.ihx.bin:
	$(HEX2BIN) -l 8000  $*.ihx



all:	test0.bin

distro:	test0.zip

halt.bin:	halt.s
	tasm -80 -b halt.s halt.bin

test0.ihx:	test0.rel $(TEST0) test0.lnk
	$(LD) -nf test0.lnk

test0.bin:	test0.ihx
	$(HEX2BIN) -l 2000 $*.ihx

test0.zip:	test0.bin
	pkzip test0 $(ZIP0)	



tidy:
	$(RM) *.tmp
	$(RM) *.lst
	$(RM) *.sym
	$(RM) *.asm
	$(RM) *.noi

clean:  tidy
	$(RM) *.ihx
	$(RM) *.hex
	$(RM) *.rel
	$(RM) *.map
	$(RM) *.bin

spotless:	clean
	$(RM) *.zip




# Dependencies

test0.rel:	test0.c $(HFILES)
test0.bin:	test0.ihx
cprintf.rel:    cprintf.c $(HFILES)
echo.rel:	echo.c $(HFILES)
nvtest.rel:	nvtest.c $(HFILES)
ycrt0.rel:	ycrt0.s z180cpu.s
delay.rel:	delay.s
sio0.rel:	sio0.s z180cpu.s
lites.rel:	lites.s mark4.inc
literhyo.rel:   literhyo.s rhyophyre.inc
io.rel:		io.s
cpu.rel:	cpu.s z180cpu.s
clk-cal.rel:	clk-cal.s

# end Makefile
