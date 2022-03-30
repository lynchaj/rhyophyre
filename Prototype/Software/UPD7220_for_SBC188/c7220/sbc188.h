#ifndef __SBC188_H
#define __SBC188_H 1

#ifdef DEBUG
#include <stdio.h>
extern unsigned char dbglvl;
#define debug(l,o) if(dbglvl>=l){o;}
#else
#define debug(l,o)
#endif

#include "mytypes.h"

#define __SDCC__ 0

#define IO_BASE  0x400

#define DEV_PPI  0x260+IO_BASE
#define DEV_UART 0x280+IO_BASE
#define DEV_RTC  0x300+IO_BASE
#define DEV_GDC  0x0B0+IO_BASE



#define CW     DEV_PPI+3
#define portC  DEV_PPI+2
#define portB  DEV_PPI+1
#define portA  DEV_PPI


#define uart_rbr (DEV_UART)
#define uart_thr (DEV_UART)

#define uart_ier (DEV_UART+1)
#define uart_iir (DEV_UART+2)
#define uart_lcr (DEV_UART+3)
#define uart_mcr (DEV_UART+4)
#define uart_lsr (DEV_UART+5)
#define uart_msr (DEV_UART+6)
#define uart_scr (DEV_UART+7)

#define uart_dll (DEV_UART+0)
#define uart_dlm (DEV_UART+1)

#define dev_rtc	 (DEV_RTC)

#define gdc_status  (DEV_GDC)
#define gdc_command (DEV_GDC+1)
#define gdc_param   (DEV_GDC)
#define gdc_read    (DEV_GDC+1)



#define lights(n) outp(portB,(n))

#if 0
extern int errno;		/* should be in stdlib */
extern void exit(int);		/* should be in stdlib */

extern void msdelay(void);
extern void delay_100_us(void);
extern void delay_50_us(void); 
extern void delay_25_us(void);
extern void lock_di(void);
extern void unlock_ei(void);
extern void wait_interrupt(void);

extern unsigned long int strtoul(const char *cptr, char **endptr, int radix);
#endif


#endif  // __SBC188_H
