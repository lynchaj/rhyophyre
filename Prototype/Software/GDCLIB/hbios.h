//
// Created by Robert Gowin Jr on 4/10/22.
//

#ifndef GDCLIB_HBIOS_H
#define GDCLIB_HBIOS_H

#include <stdint.h>

uint8_t  hbios_get_bank(void);
uint32_t hbios_get_timer_tick(void);
uint32_t hbios_get_version(void);
uint8_t  hbios_write_char(char ch);


#endif //GDCLIB_HBIOS_H
