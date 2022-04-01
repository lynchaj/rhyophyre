; delay.s -- delays @ 9.216 Mhz, 3 w.s.

	.module	delay

	.area	_CODE
	.z180

;
;  void wait(uint16 sec100);	/* wait in 1/100 seconds, up to 256 */
;
_wait::			; wait in centiseconds up to 256
	pop	hl	; get return address out of the way
	pop	bc	; get count in BC
	push	bc	; put back in stack

	ld	b,c	; use only the B as a counter
w1:	call	_delay1cs
	djnz	w1
	jp	(hl)	; return through a register


_delay1cs::		; delay 1/100 second (centisecond)
	call	_delay1ms	; 1
	call	_delay1ms	; 2
	call	_delay1ms	; 3
	call	_delay1ms	; 4
	call	_delay1ms	; 5
	call	_delay1ms	; 6
	call	_delay1ms	; 7
	call	_delay1ms	; 8
	call	_delay1ms	; 9
_delay1ms::	call	_delay512
_delay512::	call	_delay256
_delay256::	call	_delay128
_delay128::	call	_delay64
_delay64::	call	_delay32
_delay32::	call	_delay16
_delay16::	call	_delay8
_delay8::
	nop
	nop
	nop
	nop
_delay2::		; not accurate at all
	ret



; call xxx	16 + 5*3	31
; ret		 9 + 3*3	18	49
; nop		 3 + 1*3	 6	55
; nop				 6	61
; nop				 6	67
; nop				 6	73

;	delay 4			37 clocks
;	delay 5			46 clocks
;	delay 6			55 clocks
;	delay 7			64.5 clks
;	delay 8			74 clocks



