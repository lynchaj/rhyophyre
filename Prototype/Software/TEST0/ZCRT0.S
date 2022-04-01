DEBUG=1
;  modified 1/23/2014 for the N8VEM Z180 SBC Mark IV cpu board -- John Coffman
;  modified 4/22/2011 for the N8VEM Home Computer Z180 -- John Coffman
;
;--------------------------------------------------------------------------
;  zcrt0.s - Generic crt0.s for a Z80
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

        .module zcrt0
.include "z180cpu.s"
.include "ubios00.s"
.include "mark4.inc"
.include "mfpic.inc"
.include "pages.inc"

       	.globl	_main
	.globl	dispatch3
dispatch3	=	0	; quiet the linker
;;	.globl	UBIOS_entry
UBIOS_entry	=  0xFF80

	.area	_HEADER (ABS)
	;; Reset vector
	.org 	0
	jp	___init___

	.blkb	5
;	.org	8	; RST 8 vector

	jp	UBIOS_entry	; link to UBIOS

	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
	.area	_IDATA		; really for DEBUG
        .area   _GSINIT
        .area   _GSFINAL

	.area	_HICODE
	.area	_DATA
_s__DATA::
	.area	_BSEG
        .area   _BSS
        .area   _HEAP


        .area   _CODE
___init___::
	;; Stack at the top of memory.
	ld	sp,#UBIOS_ORG

;;; .include "rom2ram.s"

        ;; Initialize global variables
        call    gsinit
	call	_main
; return code is in HL
	jr	__exit
_exit::
	pop	hl		; throw away return address
	pop	hl		; get exit code (INT)
__exit:
	ld	a,l		; return code to A
.if DEBUG
	out	(port_B),a
.endif

; HL=exit code

	di
	halt			; SLP is Z180 only



.if DEBUG
;
;	void lites(int display)
;
;
_lites::
	pop	hl
	ex	(sp),hl
	ld	a,l
	out	(port_B),a
	ex	(sp),hl
	jp	(hl)
.endif


	.globl	s__DATA, s__HEAP

        .area   _GSINIT
gsinit::
; zero the _DATA, _BSEG, _BSS areas, but not the _HEAP
zap_start::
	ld	de,#s__DATA
	ld	hl,#s__HEAP
	xor	a,a			; A=0, Carry=0
	sbc	hl,de			; sets all the flags
	ld	b,h
	ld	c,l			; BC=count, BC>=1
	ld	h,d
	ld	l,e   			; HL=start
	ld	(hl),a			; zap byte 0
	inc	de			; DE=destination
	dec	bc			; one less
	ldir
zap_done::

        .area   _GSFINAL
        ret

	.area	_DATA
	.ds	2		; guarantee at least 2 bytes to zap
; This saves all the testing for 0 or 1 counts above

.include "heap.s"
