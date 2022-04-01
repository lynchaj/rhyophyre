/* clock.h */
#ifndef _CLOCK_H
#define _CLOCK_H 1
#include "mytypes.h"


/*  address RTC or RAM  */
#define	RAM	0x20
#define	CLK	0x00
#define AMASK  0x1F     /* masks address to 5 bits */

/*  bit set for all Commands  */
#define CMD    0x80

/*  Read or Write command  */
#define  READ  (CMD|1)
#define  WRITE (CMD|0)

/*  bit in the Control register  */
#define WP_ON  0x80
#define WP_OFF 0x00

/*  bit in the Seconds register  */
#define HALT   0x80
#define RUN    0x00

#define RTC_length   8

#define toupper(a) ((a)>='a'&&(a)<='z'?(a)-('a'-'A'):(a))

#define rtc_WP(on) rtc_set_loc(7|CLK,(on?0x80:0))
byte rtc_get_loc(byte address);
void rtc_set_loc(byte reg, byte value);
byte get_nvram(byte nvram[]);
void put_nvram(byte nvram[]);
void get_clock(byte clock[]);
void put_clock(byte clock[]);
byte to_bcd(byte decimal);
byte to_decimal(byte bcd);
dword get_phi80(void);

typedef
union CLK_CAL {
   struct NAME {
      byte  sec	:	7;
      byte  stop	:	1;
      byte  min;
      byte  hour;
      byte  day;
      byte  mth;
      byte  dow;
      byte  year;
      byte  ctrl;
   } rtc;
   byte array[RTC_length];
} T_CLOCK;

#if 0
extern const char *indent;
int Date(T_CLOCK*);
int Time(T_CLOCK*);
void set_indent(int8 amt);
byte boot_disk_query(const char *prompt, byte option);
int boot_option(const char *prompt, int option);
long numeric(const char *prompt, dword current);
int yesno(char *prompt, int ans);
int getline(char *buffer, int length);
#define GETLINE(b) getline(b,sizeof(b))
byte get_cpu_speed(byte speed, byte cpu);
byte get_wait(byte wait0);
byte get_IOwait(byte wait0);
void menu(char *prompt, char *choice[], byte first);
#endif

#endif  /* end clock.h */
