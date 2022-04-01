/* test0.c */
#define DATE "2014/08/03"
#include <stdlib.h>
#include "mytypes.h"
#include "z180.h"
#include "cprintf.h"


void Yputchar(char ch);
#define putchar(x) Yputchar(x)
int Ygetchar(void);
#define getchar Ygetchar
void wait(uint16 csec);
void lite_off(void);
void lite_on(void);
byte cpu_type(void);
int echotest(void);
int nvtest(void);


/*
; (dev_sd) board status register bits:
SD_CS		=	1<<2	; chip select bit in (dev_sd)
SD_WP		=	1<<4	; Write Protect status
SD_CD		=	1<<5	; Card Detect status
SD_IEN	=	1<<6	; interrupt enable
SD_IPEND	=	1<<7	; interrupt pending
*/
#define SD_CS (1<<2)
#define SD_WP (1<<4)
#define SD_CD (1<<5)
#define SD_IEN (1<<6)
#define SD_IPEND (1<<7)
#define SD_ALL (SD_CS|SD_WP|SD_CD|SD_IEN|SD_IPEND)


int old_P10(byte device)
{
	byte tem;

	device = (device & 0xF0) + 9;
	tem = inp(device);
	if (tem & ~SD_ALL) return 0;

	if (tem & SD_IPEND) {
		outp(device, tem);
		tem = !(inp(device) & SD_IPEND);
	}
	else { /* no IPEND */
		outp(device, tem ^ SD_CD);
		tem = !!(inp(device) & SD_IPEND);
	}
	return tem;
}


int check_P10(void)
{
	word device;
	byte err = !old_P10(0x89);

	for (device=0; !err && device<0xFF; device+=0x10) {
		if (device>=0x40 && device<0x8F) continue;
		err |= old_P10(device);
	}
	return err;
}


void putstr(char *str)
{
	char ch;

	ch = *str++;
	while (ch) {
		if (ch == '\n') putchar('\r');
		putchar(ch);
		ch = *str++;
	}
}


void numout(uint8 n)
{

	lite_off();
	wait(75);
	while (n--) {
		lite_on();
		wait(25);
		lite_off();
		wait(35);
	}
	wait(100);
}

byte check_cts(void)
{
	byte cts;

	cts = inp(CNTLB0);
	
	if (cts & (1<<5)) return 0;
	return 1;
}

byte cputype;			/* saved CPU type 1=80180, 2=SL1960, 3=full 8S180 */
const char str[] = "\n\nBegin Test 4:\n    Hi there!!\n";
const char qbf[] = "The quick brown fox jumps over the lazy dog.\n";
const char * const ptype[] = {
	"Z80",
	"Z80180 vintage",
	"Z180 SL1960 retard",
	"Z180 advanced S-class",
	};

#define NLINE 18

void main(void)
{
	uint8 i, j;

/*	if ( check_P10() ) return; */

	wait(150);

	numout(5);
	cputype = cpu_type();
	numout(cputype ? cputype : 25);
	do {
		i = check_cts();
		if (i==0) numout(4);
	} while (!i);
	numout(1);

	putstr(str);

	printf("%s\n","Hello World!\n");
	for (i=0; i<NLINE; i++) {
		for (j=0; j<i; j++) putchar(' ');
		putstr(qbf);
	}
#if 0

	printf(	"Test 1:  passed   (5 flashes)\n"
				"    The board I/O jumpers (P10) are set to 0x80 -- (off, on, on, on)\n"
				"\n"
				"Test 2:  passed   (%d flashes)\n"
				"    The processor is level %d, a %s processor\n\n",
										(word)cputype, (word)cputype, ptype[cputype]);
	printf(	"Test 3:  passed   (1 flash)\n"
				"    The serial connection is providing the CTS signal\n\n");

	printf(	"Test 4:  passed   (you can read this)\n"
				"    Serial output at 9600 baud, with an 18.432 Mhz oscillator\n"
				"      (9.216 Mhz osc ==> 4800 baud, 4.608 Mhz osc ==> 2400 baud)\n\n");

	printf(	"Test 5: ");
	if (echotest() == 1) printf("\nfailed\n\n");
	else printf("\nTest 5:  passed\n\n");

	printf(	"Test 6:  NVRAM check\n");
		i = nvtest();
	printf(	"  -- ");
	if (i) printf("failed %d", i);
	else printf("passed all");
	printf(" read/write tests\n\n");

	printf(	"Test 7:  SD card check\n"
				"   Each time you type a character, the state of the Card Detect and\n"
				"   Write Protect switches will be printed.  This checks the soldering\n"
				"   of the SD socket, and the correct installation of the P4 jumpers.\n"
				"   SDcards are hot-swappable; they may be inserted and removed any time\n"
				"   they are not being accessed.  A change in CD generates an interrupt.\n"
				"   Exit the test by typing <ESC>.\n");
	while ( getchar() != 033 ) {
		i = inp(0x89);
		outp(0x89, i & 32);
		printf("\n");
		printf("    Card Detect: %s\n", i&32 ? "yes" : "no");
		printf("  Write Protect: %s\n", i&16 ? "yes" : "no");
		printf("      Interrupt: %s\n", i&128 ? "pending" : "clear");
	}

	printf(	"\nEnd of TEST0.BIN (" DATE "), \"Goodbye!\"\n <cpu halt>");
#endif
	return;
}


