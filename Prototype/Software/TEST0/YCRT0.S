;  modified 07/10/2014 for testing the Z180 Mark IV board -- John Coffman
;  modified 12/13/2013 for the Z180 SBC Mark IV board -- John Coffman
;  modified 4/22/2011 for the N8VEM Home Computer Z180 -- John Coffman
;
;--------------------------------------------------------------------------
;  ycrt0.s - Bootstrap crt0.s for a Z180
;
;  Copyright (C) 2000, Michael Hope
;
;  This library is free software; you can redistribute it and/or modify it
;  under the terms of the GNU General Public License as published by the
;  Free Software Foundation; either version 2.1, or (at your option) any
;  later version.
;
;  This library is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License 
;  along with this library; see the file COPYING. If not, write to the
;  Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
;   MA 02110-1301, USA.
;
;  As a special exception, if you link this library with other files,
;  some of which are compiled with SDCC, to produce an executable,
;  this library does not by itself cause the resulting executable to
;  be covered by the GNU General Public License. This exception does
;  not however invalidate any other reasons why the executable file
;   might be covered by the GNU General Public License.
;--------------------------------------------------------------------------

        .module ycrt0
        .hd64
.include "z180cpu.s"
.include "mark4.inc"

	.globl	_main

	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
        .area   _GSINIT
        .area   _GSFINAL

	.area	_DATA
	.area	_BSEG
        .area   _BSS
        .area   _HEAP

	.area	_CODE
loc0::
	jp	___init___
     	.ds	0x100-(.-loc0)

___init___::
	di	; DELETE THIS IN THE FUTURE
is_Z180:
	ld	a,#Z180_IO_BASE
	out0	(icr),a
	ld	a,#0xF0
	out0	(cbr),a
;
	ld	sp,#0xFF00
; initialize the Z180 internal registers
	ld	hl,#Ytab
	call	Init_from_Table

; initialize global variables
        call    gsinit

	ld	hl,#argv
	push	hl
	ld	hl,#0
	push	hl
	call	_main
	pop	af
	pop	af

_exit::
1$:
	di				; all interrupts off
	ld	a,#0			; SD_CS off
	out	(dev_sd),a
	halt
	jr	1$

; arguments to main
argv:	.dw	0,0


;
;  Table of Z180 registes to be set up VERY early
;
;  entries consist of
;	.DB	reg, value
;
Ytab::
	.db	icr, Z180_IO_BASE	; must be first !!!
        .db     rcr, 0x7F               ; turn off Refresh
	.db	cbr, 0xF0		; actually done at RST 0 reset vector
	.db	cmr, 0x00		; Clock Multiplier; xtal*1 selected
        .db     ccr, 0x00               ; Cpu control; xtal/2 selected
        .db     cbar, 0x80              ; Common 0 at 0x0000 (can't change), 
                                        ; Bank at 0x0000, Common 1 at 0x8000
	.db	dev_xmem, 0x00		; use ROM and on-bord RAM
;	.db	bbr, 0x00		; done by reset, or by 'chain'

; some SIO and DMA setup
	.db	asext0, 0x00		; ASCI extension control register 0
	.db	asext1, 0x00		; ASCI extension control register 1
        .db     cntla0, 0x65            ; 8bits, noPar, 2stop
        .db     cntla1, 0x05            ; don't use TEND0, 8bits,noPar,2stop
	.db	cntlb0, 0x21		; PS=1 (div 30) DR=0 (div 16) SSS=001
				; PHI=18432k/2, /30, /16, SSS=/2**1 = 9600
        .db     dmode, 0x00             ; use DREQ0
        .db     dcntl, 0xFA             ; Mem ws = 3, IO Wait States = 4,
                                        ; DMA1=edge, DMA0=level, DMA1=READ
        .db     iar1b, 0x00             ; defaults (use DMA ch 1)
	
; init the SD card interface
	.db	dev_sd, 0x00		; turn off CS

; end of table at EOF register code
	.db	-1



; Initialize Z180 stuff from a table of values
;
; enter with HL = address of table
;
Init_from_Table::
	ld	b,#0		; for Z180 CPU internal registers
ift1:
	ld	c,(hl)		; get device code
	inc	hl
	inc	c		; test for -1
	ret	z		; return if END marker

	dec	c		; restore device code
	ld	a,(hl)		; get value
	inc	hl
	out	(c),a		; output to (C) -- actually (BC)
	jr	ift1		; loop back
	

        .area   _GSINIT
gsinit::
	ld	a,#0
	out	(0xD9),a

        .area   _GSFINAL
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
