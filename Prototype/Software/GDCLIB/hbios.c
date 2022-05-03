//
// Created by Robert Gowin Jr on 4/10/22.
//

#include "hbios.h"

#include <stdint.h>
#include <stdio.h>

uint16_t hbios_bc_ac(uint16_t func_device) __smallc __z88dk_fastcall;
uint32_t hbios_bc_dehl(uint16_t func_device) __smallc __z88dk_fastcall;
uint8_t  hbios_bce_a(char ch, uint16_t func_device) __smallc;

uint8_t hbios_get_bank(void)
{
    uint16_t ac = hbios_bc_ac(0xF300);
    uint8_t a = (ac >> 8) & 0xff;
    uint8_t c = ac & 0xff;
    printf("hbios_get_bank: a = 0x%02x, c = 0x%02x\n", a, c);
    return c;
}

uint32_t hbios_get_timer_tick(void)
{
    return hbios_bc_dehl(0xF8D0);
}

uint32_t hbios_get_version(void)
{
    return hbios_bc_dehl(0xF10);
}

uint8_t hbios_write_char(char ch)
{
    return hbios_bce_a(ch, 0x0200);
}