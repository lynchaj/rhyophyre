; determine processor type
;
; C-call:
;	byte cpu_type(void);
;
; returned codes:
;
;	0 means	Z80
;	1 means Z180 - 80180
;	2 means Z180 S-class, SL1960 version
;	3 means Z180 advanced S-class, with Baud Rate Generator
;
.include "z180cpu.s"

	.module	cpu

	.area	_CODE
	.z180
_cpu_type::
	ld	hl,#0		; L = 0 means Z80
	ld	de,#0x0506	; 5 x 6
	mlt	de		; DE = 30 if Z180
	ld	a,e		; check if multiply happened
	cp	a,#30
	ret	nz		; it is a Z80 if != 30

	inc	l		; flag Z180
        out0    (astc1l),d	; D = 0 at this point

        in0     a,(ccr)         ; supposedly only on S-class
        inc     a		; FF or 00 -> 0 or 1 (weak S-class or higher)
	add	a,l
	ld	l,a		; result to L and A

        in0     a,(astc1l)      ; counter reg
        inc     a		; FF or 00 -> 0 or 1 (super-S)
	add	a,l
	ld	l,a

	.z80			; do Z80 assembly below here
	ret



