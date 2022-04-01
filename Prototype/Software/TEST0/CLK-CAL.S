DEBUG=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; clk-cal.s -- Z180 SBC Mark IV  Clock-Calendar-NVRAM module
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  SDCC 3.0.0
;
; Copyright (C) 2013 John R. Coffman.  All rights reserved.
; Provided for hobbyist use on the N8VEM SBC Mark IV board.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.include "mark4.inc"

	.module clk_cal
	.z80


	.globl	_RTC_dev
	.area	_CODE
_RTC_dev:	.db	dev_rtc


READ_CMD        =       0x81
WRITE_CMD       =       0x80

; bits in the 'dev_rtc' command register
;
nRST	=	0x10		; ~RST bit
RW	=	0x20		; Read/~Write direction
CLK	=	0x40		; Clock
DataOut	=	0x80		; Data Out
DataIn	=	0x01		; Data In

	.area	_CODE
reset_on:
	ld	a,(_RTC_dev)	; let 'mark4.c' specify this
.if DEBUG
	cp	a,#0x70
	jr	z,ro2
	lites	0x69
	stop
ro2:
.endif
	ld	c,a		; use device code in C register

	ld	d,#(RW)		; set READ
	ld	a,#~(nRST+CLK+DataOut)	; set RESET, clear CLK, clear DOut
and_lat:
	and	a,d		; AND bits
out_lat:
	out	(c),a	; output to latch
delay:	ld	d,a		; save latch state in D
	.globl	_delay2
	call	_delay2
	ret



reset_off:
	ld	a,#(nRST)	; deassert RESET
or_lat:
	or	a,d		; OR values
	out	(c),a	; output to latch
	jr	delay		; take a little more time


; byte_out
;
;  Call with:
;	latch status in D
;	byte to put out in E

byte_out:
	ld	b,#8		; count 8 bits
byte2:
	ld	a,#~(RW+CLK)	; clear CLK, set WRITE
	and	a,d		; **
	add	a,a		; shift by 1
	rrc	e		; low bit to Carry
	rra			; hi bit of A is DataOut
	call	out_lat		; output
	ld	a,#CLK		; set CLK
	call	or_lat		; put out the bit
	djnz	byte2		; loop through 8 bits

	ret			; byte has been put out
; ends with CLK high


; byte_in
;
;  Call with:
;	latch status in D
;
;  Return with:
;	byte read in E
;	latch status in D

byte_in:
	ld	b,#8		; count 8 bits
byte4:
	ld	a,#~CLK		; clear CLK
	and	a,d
	ld	d,#(nRST+RW)	; clear nRST, set READ
	call	or_lat		;
	nop

	in	a,(c)	; read a bit into Data_0
	rra
	rr	e		; low bit of A is now hi bit of E

	ld	a,#CLK		; set CLK
	call	or_lat
	djnz	byte4

	ret			; return byte in E
; ends with CLK high






; /* void rtc_set_loc(byte reg, byte value); */

; _rtc_set_loc(byte reg_number, byte value)
;
;   Call with:
;       arg1    (byte)number         (needs to be shifted by 1)
;               the address contains the clock/ram bit;
;               both will be shifted to the correct position
;	arg2	value to store in location
;
;   Return with
;	nothing
;
_rtc_set_loc::
	push	de
	push	bc

	call	reset_on
	call	reset_off

	ld	hl,#2+4		; get arg1 offset
	add	hl,sp
	ld	a,(hl)		; get byte number (arg1)
	inc	hl
	and	a,#0x3F		; insurance, bit 0x20 is RAM/CLK bit
	add	a,a		; shift by 1
	or	a,#WRITE_CMD	;
	ld	e,a		; command byte to E register
	call	byte_out	; put out the command byte

	ld	e,(hl)		; byte to put out in E
	call	byte_out	; put out the data byte

	call	reset_on	; end of operation

	pop	bc
	pop	de
	ret


; /* byte rtc_get_loc(byte address); */

; _rtc_get_loc(byte reg_number)
;
;   Call with:
;       arg1    (byte)number         (needs to be shifted by 1)
;               the address contains the clock/ram bit;
;               both will be shifted to the correct position
;
;   Return with
;       L reg   data value read in
;
_rtc_get_loc::
	push	de
	push	bc

	call	reset_on
	call	reset_off
; delay 4 usec here -- stream below is big enough
	ld	hl,#2+4		; arg offset
	add	hl,sp
	ld	a,(hl)		; get byte address
	and	a,#0x3F		; insurance, bit 0x20 is RAM/CLK bit
	add	a,a		; shift by 1
	or	a,#READ_CMD	;
	ld	e,a		; command to put out in C
	call	byte_out	; put out the command byte

	call	byte_in		; get byte in C
	call	reset_on	; re-assert RESET

	ld	l,e		; return value in L
	ld	h,#0		; return as 'int'
	pop	bc
	pop	de
	ret



; C-callable
;	byte get_nvram(byte nvram[]);
;
;	Return	== 0 if checksum valid
;		!= 0 if checksum invalid
;
_get_nvram::
	push	bc
	push	de

	call	reset_on
	call	reset_off
	ld	hl,#6		; address of argument offset
	add	hl,sp		;
	ld	e,(hl)		; low part of address
	inc	hl
	ld	d,(hl)		; 
	ex	de,hl		; HL is address of array

	ld	e,#0xFF		; read all of NVRAM
	call	byte_out
	ld	b,#31		; count 31 bytes
nv1:
	push	bc
	call	byte_in		; retrieve a byte
	ld	(hl),e		; save it
	inc	hl
	pop	bc
	dec	b
	jr	nz,nv1		; loop back for 31 bytes

	call	reset_on	; 

.if 0
	ld	b,#31		; B=31
	xor	a,a		; clear A
nv2:
	dec	hl		; now sum the array backwards
	add	(hl)		; one's complement add
	adc	#0		;  end around carry for one's complement
	djnz	nv2	

	inc	a		; convert -0 to +0
	jr	z,nv3
	dec	a
nv3:
	ld	l,a		; return byte
.endif

	pop	de		; restore
	pop	bc
	ret			; return




; C-callable
;	void put_nvram(byte nvram[]);
;
; return nothing

_put_nvram::
	push	bc
	push	de

	ld	hl,#6		; offset of argument
	add	hl,sp		;
	ld	e,(hl)		; low part of address
	inc	hl
	ld	d,(hl)		; DE is address of array
	ex	de,hl
	push	hl		; save for later

.if 0
	ld	b,#30		; B=30
	xor	a,a
nv5:
	add	(hl)		; one's complement addition
	adc	#0		; end around carry
	inc	hl
	djnz	nv5		; sum 30 bytes

	xor	a,#0xFF		; one's complement negation
	ld	(hl),a		; store checksum
.endif

	call	reset_on	; starts to use D register
	call	reset_off
	
	pop	hl		; restore address of array
	ld	e,#0xFE		; write all of NVRAM
	call	byte_out
	ld	b,#31		; count 31 bytes
nv6:
	push	bc
	ld	e,(hl)		; byte to store to NVRAM
	inc	hl
	call	byte_out	; store a byte
	pop	bc
	dec	b
	jr	nz,nv6		; loop back for 31 bytes

	call	reset_on	; 

	pop	de		; restore
	pop	bc
	ret			; return




; C-callable
;	void get_clock(byte clock[]);
;
_get_clock::
	push	bc
	push	de

	call	reset_on
	call	reset_off
	ld	hl,#6		; address of argument offset
	add	hl,sp		;
	ld	e,(hl)		; low part of address
	inc	hl
	ld	d,(hl)		; 
	ex	de,hl		; HL is address of array

	ld	e,#0xBF		; read all of CLOCK
	call	byte_out
	ld	b,#8		; count 8 bytes
ck1:
	push	bc
	call	byte_in		; retrieve a byte
	ld	(hl),e		; save it
	inc	hl
	pop	bc
	dec	b
	jr	nz,ck1		; loop back for 31 bytes

	call	reset_on	; 

	pop	de		; restore
	pop	bc
	ret			; return




; C-callable
;	void put_clock(byte clock[]);
;
; return nothing

_put_clock::
	push	bc
	push	de

	ld	hl,#6		; offset of argument
	add	hl,sp		;
	ld	e,(hl)		; low part of address
	inc	hl
	ld	d,(hl)		; DE is address of array
	ex	de,hl

	call	reset_on	; starts to use D register
	call	reset_off
	
	ld	e,#0xBE		; write all of CLOCK
	call	byte_out
	ld	b,#8		; count 8 bytes
ck6:
	push	bc
	ld	e,(hl)		; byte to store to NVRAM
	inc	hl
	call	byte_out	; store a byte
	pop	bc
	dec	b
	jr	nz,ck6		; loop back for 31 bytes

	call	reset_on	; 

	pop	de		; restore
	pop	bc
	ret			; return










