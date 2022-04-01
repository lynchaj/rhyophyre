; io.s -- INP and OUTP -- input and output operations
;
;

	.globl	_outp
;	.globl	outp
;
;   void outp(byte port, byte data);
;
_outp::
	pop	hl		; get return address
	pop	bc		; get data:port in B:C
	push	bc		; restore the stack

	ld	a,b		; data to A
	ld	b,#0		; just in case we address Z180
	out	(c),a		; data out to world
	jp	(hl)		; return thru register


	.globl	_inp	
;	.globl	inp
;	
;   int inp(byte port);
;
_inp::
	pop	hl		; get return address
	pop	bc		; retrieve byte in C (port address)
	push	bc		; restore stack
	push	hl		; put return address back
	ld	b,#0		; may address Z180 port
	in	l,(c)		; input the byte
	ld	h,b		; make it an integer
	ret




