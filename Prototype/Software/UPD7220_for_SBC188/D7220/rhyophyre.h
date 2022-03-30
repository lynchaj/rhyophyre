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

#define DEV_PPI          0x88
#define DEV_UART         0x40
#define DEV_RTC          0x84
#define DEV_GDC          0x90
#define DEV_RAMDAC_LATCH 0x94
#define DEV_RAMDAC       0x98

#define CW     DEV_PPI+3
#define portC  DEV_PPI+2
#define portB  DEV_PPI+1
#define portA  DEV_PPI

#define dev_rtc	 (DEV_RTC)

#define gdc_status  (DEV_GDC)
#define gdc_command (DEV_GDC+1)
#define gdc_param   (DEV_GDC)
#define gdc_read    (DEV_GDC+1)

#define ramdac_latch (DEV_RAMDAC_LATCH)
#define ramdac_base  (DEV_RAMDAC)

#define ramdac_address_wr (ramdac_base+0)
#define ramdac_address_rd (ramdac_base+3)
#define ramdac_palette_ram (ramdac_base+1)
#define ramdac_pixel_read_mask (ramdac_base+2)

#define ramdac_overlay_wr (ramdac_base+4)
#define ramdac_overlay_rd (ramdac_base+7)
#define ramdac_overlay_ram (ramdac_base+5)
#define ramdac_do_not_use  (ramdac_base+6)


#define lights(n) outp(portB,(n))

#endif  // __RHYOPHYRE_H__
