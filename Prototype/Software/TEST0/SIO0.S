;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  sio0.s -- driver for Serial I/O on a Z180
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Copyright (C) 2014 John R. Coffman.  All rights reserved.
;   Provided for hobbyist use on the Z180 SBC Mark IV board.
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
	.module	sio0
	.z180
.include "z180cpu.s"

	.globl	_Yputchar, _Qstatus
	.globl	_delay8

; just temporary:

	.area	_CODE

_Yputchar::
	pop	hl
	pop	bc
	push	bc
	push	hl

TDRE    =       0x02            ; transmit data register empty
putchar0:
        in0     a,(stat0)
        and     a,#TDRE
        jr      z,putchar0

        out0    (tdr0),c
	ld	l,c
	ld	h,#0		; return an 'int'
        ret


; return the number of characters waiting in the input queue
;
_Qstatus::
 	in0	a,(stat0)
	add	a,a		; test RDRF (0x80)
	sbc	a,a		; A=0 or -1
	neg			; A=0 or 1
	ld	l,a
	ld	h,#0		; return an 'int'
	ret			; return 0 or 1


; get a character from SIO0, waiting for one to arrive
;
getloop:
	call	_delay8		; insert a wait
_Ygetchar::
 	in0	a,(stat0)	; read status
	add	a,a		; RDRF 
	jr	nc,getloop	; wait for input to arrive
	in0	l,(rdr0)	; get input character
	ld	h,#0		; return an 'int'
	ret

