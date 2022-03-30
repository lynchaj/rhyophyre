#ifndef __RHYOPHYRE_H__
#define __RHYOPHYRE_H__ 1 

#ifdef DEBUG
#include <stdio.h>
extern unsigned char dbglvl;
#define debug(l,o) if(dbglvl>=l){o;}
#else
#define debug(l,o)
#endif

#include "mytypes.h"

#define DEV_PPI  0x88
#define DEV_UART 0x40
#define DEV_RTC  0x84
#define DEV_GDC  0x90

#define CW     DEV_PPI+3
#define portC  DEV_PPI+2
#define portB  DEV_PPI+1
#define portA  DEV_PPI

#define dev_rtc	 (DEV_RTC)

#define gdc_status  (DEV_GDC)
#define gdc_command (DEV_GDC+1)
#define gdc_param   (DEV_GDC)
#define gdc_read    (DEV_GDC+1)

#define lights(n) outp(portB,(n))

#endif  // __RHYOPHYRE_H__
