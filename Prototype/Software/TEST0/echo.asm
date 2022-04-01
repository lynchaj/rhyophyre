;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module echo
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _echotest
	.globl _Qstatus
	.globl _Ygetchar
	.globl _Yputchar
	.globl _cprintf
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;echo.c:13: int echotest(void)
;	---------------------------------
; Function echotest
; ---------------------------------
_echotest::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;echo.c:20: "  Characters echoed as typed; end test with <ESC>\n");
	ld	hl, #___str_0
	push	hl
	call	_cprintf
	pop	af
;echo.c:22: i = START;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
	ld	-2 (ix), #0x08
	xor	a, a
	ld	-1 (ix), a
;echo.c:23: while (--i) {
00105$:
	ld	a, -4 (ix)
	add	a, #0xff
	ld	c, a
	ld	a, -3 (ix)
	adc	a, #0xff
	ld	b, a
	ld	a, -2 (ix)
	adc	a, #0xff
	ld	e, a
	ld	a, -1 (ix)
	adc	a, #0xff
	ld	d, a
	ld	-4 (ix), c
	ld	-3 (ix), b
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	Z,00107$
;echo.c:24: if (Qstatus()) {
	call	_Qstatus
	ld	a, h
	or	a, l
	jr	Z,00105$
;echo.c:25: ch = getchar();
	call	_Ygetchar
	ld	c, l
;echo.c:26: i = START;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
	ld	-2 (ix), #0x08
	xor	a, a
	ld	-1 (ix), a
;echo.c:27: if (ch == ESC) return 0;	/* signal no error */
	ld	a, c
	sub	a, #0x1b
	jr	NZ,00102$
	ld	hl, #0x0000
	jr	00108$
00102$:
;echo.c:28: putchar(ch);
	ld	a, c
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
	jr	00105$
00107$:
;echo.c:31: return 1;	/* signal error */
	ld	hl, #0x0001
00108$:
;echo.c:32: }
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "Keyboard echo test:"
	.db 0x0a
	.ascii "  Characters echoed as typed; end test with <ESC>"
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
