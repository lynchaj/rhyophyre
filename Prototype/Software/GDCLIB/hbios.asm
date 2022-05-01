
;
; uint16_t hbios_bc_ac(uint16_t func_device) __smallc __z88dk_fastcall
;

INCLUDE "hbios.inc"

SECTION code_clib
SECTION code_arch

PUBLIC _hbios_bc_ac, _hbios_bc_dehl, _hbios_bce_a

._hbios_bc_ac

    ld b,h
    ld c,l

    call __HB_INVOKE

    ld h,a
    ld l,c

    ret

;
; uint32_t hbios_bc_dehl(uint16_t func_device) __smallc __z88dk_fastcall
;

._hbios_bc_dehl

    ld b, h
    ld c, l

    call __HB_INVOKE

    ret

;
; uint8_t hbios_bce_a(char ch, uint16_t func_device) _smallc
;

._hbios_bce_a

    ld hl,2
    add hl, sp    ; skip over return address on stack
    ld c,(hl)
    inc hl
    ld b,(hl)      ;bc = func_device
    inc hl
    ld e,(hl)      ;e = ch

    call __HB_INVOKE

    ld l,a
    ret
