/* nvtest.c */
#include "cprintf.h"
#include "clock.h"

#define NVRAM 31
#define  ON 1
#define OFF 0

const byte nvValue[NVRAM+1] = {
	255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 
	255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0
};
const byte nvBits[NVRAM+1] = {
	0x80, 0x10, 0x02, 0x40, 0x08, 0x01, 0x20, 0x04, 
	0x80, 0x10, 0x02, 0x40, 0x08, 0x01, 0x20, 0x04, 
	0x80, 0x10, 0x02, 0x40, 0x08, 0x01, 0x20, 0x04, 
	0x80, 0x10, 0x02, 0x40, 0x08, 0x01, 0x20, 0x04 };

static byte test(byte *patt)
{
	byte i;
	byte nv[NVRAM];

	put_nvram(patt);
	get_nvram(nv);
	for (i=0; i<NVRAM; i++) if (patt[i] != nv[i]) return 1;
	return 0;
}

int nvtest(void)
{
	byte nvsave[NVRAM];
	byte err, wp;

	wp = rtc_get_loc(7|CLK) & 0x80;
	printf("  DS1302 write protect is %s\n", wp ? "ON" : "OFF");
	get_nvram(nvsave);
	if (wp) rtc_WP(OFF);
	printf("   Using test pattern 1\n");
	err = test(nvValue);
	printf("   Using test pattern 2\n");
	err += test(nvValue+1);
	printf("   Using test pattern 3\n");
	err += test(nvBits);
	printf("   Using test pattern 4\n");
	err += test(nvBits+1);
	put_nvram(nvsave);
	if (wp) {
		rtc_WP(ON);
		printf("  DS1302 write protect is re-enabled\n");
	}

	return err;
}

