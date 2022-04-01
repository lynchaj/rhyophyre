/* z180hc.h
 */
#ifndef __Z180HC_H
#define __Z180HC_H 1
#include "mytypes.h"

#define   Z180_IO_BASE  0x40  /* zero is the Reset default */
#define   Z8S180        1     /* extra registers */


#ifndef hcIObase
#define hcIObase  0x80
#endif

#define  PPI      hcIObase

#define PPI0a   PPI                /* port A on the 8255 */
#define PPI0b   (PPI0a + 1)
#define PPI0c   (PPI0b + 1)
#define PPI0ctl (PPI0c + 1)

#define PPI1a   (PPI + 4)           /* printer port for HC */
#define PPI1b   (PPI1a + 1)
#define PPI1c   (PPI1b + 1)
#define PPI1ctl (PPI1c + 1)


#define  RTC      (hcIObase + 8)

#define  ACR      (hcIObase + 20)
#define  ROM      (ACR + 2)

#ifdef __SDCC__
__sfr __at (RTC)   dev_rtc;

__sfr __at (ACR)   dev_acr;
__sfr __at (ROM)   dev_rom;

#endif   // __SDCC__



#define CPM_SECTOR_SIZE   128
#define SECTOR_SIZE       512
#define PAGE_SIZE        4096
#define BANK_SIZE       32768

#define FLOPPY_MAX 2

extern   dword tick_count;
extern   byte  countdown;
extern   word clock_freq;     /* CPU clock frequency */
extern   byte delay16count;   /* count for delay loop based on clock freq. */
extern   byte processor_bits; /* low bit is 'S' processor flag */



void panic(byte);
void usec16_delay(void);
void speed_check(void);

#endif  //__Z180HC_H 

