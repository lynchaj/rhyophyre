TEST0.BIN for the SBC Z180 Mark IV

good for board versions 1.0 (with updates) and 2.0

TEST0.BIN should be burned to ROM (Flash chip is a good idea), and
the ROM inserted into the completed board.

TEST0.BIN requires that the Secure Digital circuitry be installed,
especially the activity LED D3. The bi-color red/green halt/run LED
D4 is also used as an indicator.

The testing assumes an 18.432Mhz oscillator for 9600 baud output.  If
a 9.216Mhz oscillator is used, serial output will be at 4800 baud;
and if a 4.608Mhz oscillator is used, serial output will be at 2400
baud.

========= The Tests =========

TEST 1:  Check correct installation of P10 jumpers for board address
0x80..0x8F:  (off, on, on, on).  The test consists of addressing the
SD card control register at 0x89.  If this register cannot be
detected, or it is detected at another address (e.g., old 0xD0
setting for P10), all testing will be abandoned, and the CPU will
halt.  This error condition is indicated by D4 green as long as the
Reset switch is depressed, but turning immediately red when Reset is
released.		[error condition:  D4 red]

Between TEST 1 and TEST 2, the SDcard activity LED D3 will flash 5
times.

TEST 2:  Determine the processor level in use.  I know of 3 versions
of the Zilog Z180 processor, the 33mhz Z8S18033 being the most
advanced.  The SL1960 variation of the Z8S180 lacks features of the
newer processors, and is flagged as a retard.  LED D3 will flash
once, twice, or three times to indicate the processor level detected.
	1 flash:	Z80180 original CPU
	2 flashes:	Z8S180 SL1960 CPU, limited features
	3 flashes:	Z8S180 advanced S-class CPU

TEST 3:  Check the serial interface signal CTS.  The Z180 ASCI0
implements hardware RTS/CTS flow control, so without CTS, serial
output is disabled.  If CTS is present, LED D3 will flash once.
     	[error condition:  D3 repeatedly flashes 4 times]
The error condition can be induced by disconnecting the serial
connection from its 10-pin header.

TEST 4:  Produce a page of ASCII text on the connected terminal. 
Besides, "Hello World!" there are 18 lines of the "... quick brown
fox ..."
	[error condition:  garbled terminal screen]

TEST 5:  Keyboard echo test.  This test will echo keyboard characters
as they are typed.  This includes all control characters, without
filtering or expanding; i.e., <CR> will echo as <CR>, not as
<CR><LF>.  Only <ESC> is handled specially--it ends the test.  If for
some reason the keyboard cannot be read, this test will time out.
	[error condition:  no bytes received; timeout]

TEST 6:  Check that the NVRAM chip is installed and operational.  A
series of test patterns are written to the DS1302, and the contents
are read back and checked.
	pattern 1:  alternating bytes of FF, 00, ...
	pattern 2:  alternating bytes of 00, FF,
	pattern 3:  rotating bit pattern starting 80, 10, ...
	pattern 4:  rotating bit pattern starting 10, 02, ...
If write-protect was on at the beginning of this test, it will be
restored at the end of the test.  The orginal contents of NVRAM will
be preserved, if possible.
	[error condition:  bytes read back not the same as written]

TEST 7:  Check the Secure Digital card socket switches to make sure
that the Card Detect and Write Protect switches are functional.  This
also checks that the two P4 SDcard personality jumpers are installed
correctly.  Each type a character is typed, the state of the CD and
WP bits will be displayed.  The test is exited by typing <ESC>. 
Pass/Fail of this test must be determined by the user.
	[error condition:  by user observation]

2014/08/03

