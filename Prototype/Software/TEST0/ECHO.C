/* echo.c -- character echo test */
#include "cprintf.h"


void Yputchar(char ch);
#define putchar(x) Yputchar(x)
int Ygetchar(void);
#define getchar Ygetchar
int Qstatus(void);

/* character echo test at the serial keyboard */

int echotest(void)
{
#define START 0x80000
	long i;
	char ch;
#define ESC 033
	printf("Keyboard echo test:\n"
	       "  Characters echoed as typed; end test with <ESC>\n");

	i = START;
	while (--i) {
		if (Qstatus()) {
			ch = getchar();
			i = START;
			if (ch == ESC) return 0;	/* signal no error */
			putchar(ch);
		}
	}
	return 1;	/* signal error */
}

