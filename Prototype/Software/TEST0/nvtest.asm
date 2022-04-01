;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module nvtest
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _nvtest
	.globl _put_nvram
	.globl _get_nvram
	.globl _rtc_set_loc
	.globl _rtc_get_loc
	.globl _cprintf
	.globl _nvBits
	.globl _nvValue
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
;nvtest.c:19: static byte test(byte *patt)
;	---------------------------------
; Function test
; ---------------------------------
_test:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-31
	add	hl, sp
	ld	sp, hl
;nvtest.c:24: put_nvram(patt);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_put_nvram
	pop	af
;nvtest.c:25: get_nvram(nv);
	ld	hl, #0
	add	hl, sp
	ld	c, l
	ld	b, h
	ld	e, c
	ld	d, b
	push	bc
	push	de
	call	_get_nvram
	pop	af
	pop	bc
;nvtest.c:26: for (i=0; i<NVRAM; i++) if (patt[i] != nv[i]) return 1;
	ld	e, #0x00
00104$:
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	d, #0x00
	add	hl, de
	ld	d, (hl)
	ld	l, e
	ld	h, #0x00
	add	hl, bc
	ld	a, (hl)
	sub	a, d
	jr	Z,00105$
	ld	l, #0x01
	jr	00106$
00105$:
	inc	e
	ld	a, e
	sub	a, #0x1f
	jr	C,00104$
;nvtest.c:27: return 0;
	ld	l, #0x00
00106$:
;nvtest.c:28: }
	ld	sp, ix
	pop	ix
	ret
_nvValue:
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
_nvBits:
	.db #0x80	; 128
	.db #0x10	; 16
	.db #0x02	; 2
	.db #0x40	; 64
	.db #0x08	; 8
	.db #0x01	; 1
	.db #0x20	; 32
	.db #0x04	; 4
	.db #0x80	; 128
	.db #0x10	; 16
	.db #0x02	; 2
	.db #0x40	; 64
	.db #0x08	; 8
	.db #0x01	; 1
	.db #0x20	; 32
	.db #0x04	; 4
	.db #0x80	; 128
	.db #0x10	; 16
	.db #0x02	; 2
	.db #0x40	; 64
	.db #0x08	; 8
	.db #0x01	; 1
	.db #0x20	; 32
	.db #0x04	; 4
	.db #0x80	; 128
	.db #0x10	; 16
	.db #0x02	; 2
	.db #0x40	; 64
	.db #0x08	; 8
	.db #0x01	; 1
	.db #0x20	; 32
	.db #0x04	; 4
;nvtest.c:30: int nvtest(void)
;	---------------------------------
; Function nvtest
; ---------------------------------
_nvtest::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-34
	add	hl, sp
	ld	sp, hl
;nvtest.c:35: wp = rtc_get_loc(7|CLK) & 0x80;
	ld	a, #0x07
	push	af
	inc	sp
	call	_rtc_get_loc
	inc	sp
	ld	a, l
	and	a, #0x80
;nvtest.c:36: printf("  DS1302 write protect is %s\n", wp ? "ON" : "OFF");
	ld	c, a
	or	a, a
	jr	Z,00107$
	ld	de, #___str_1+0
	jr	00108$
00107$:
	ld	de, #___str_2+0
00108$:
	push	bc
	push	de
	ld	hl, #___str_0
	push	hl
	call	_cprintf
	pop	af
	pop	af
	pop	bc
;nvtest.c:37: get_nvram(nvsave);
	ld	hl, #0
	add	hl, sp
	ld	-3 (ix), l
	ld	-2 (ix), h
	push	bc
	push	hl
	call	_get_nvram
	pop	af
	pop	bc
;nvtest.c:38: if (wp) rtc_WP(OFF);
	ld	a, c
	or	a, a
	jr	Z,00102$
	push	bc
	xor	a, a
	ld	d,a
	ld	e,#0x07
	push	de
	call	_rtc_set_loc
	pop	af
	pop	bc
00102$:
;nvtest.c:39: printf("   Using test pattern 1\n");
	push	bc
	ld	hl, #___str_3
	push	hl
	call	_cprintf
	ld	hl, #_nvValue
	ex	(sp),hl
	call	_test
	pop	af
	ld	a, l
	pop	bc
	ld	b, a
;nvtest.c:41: printf("   Using test pattern 2\n");
	push	bc
	ld	hl, #___str_4
	push	hl
	call	_cprintf
	ld	hl, #(_nvValue + 0x0001)
	ex	(sp),hl
	call	_test
	pop	af
	ld	a, l
	pop	bc
	add	a, b
	ld	b, a
;nvtest.c:43: printf("   Using test pattern 3\n");
	push	bc
	ld	hl, #___str_5
	push	hl
	call	_cprintf
	ld	hl, #_nvBits
	ex	(sp),hl
	call	_test
	pop	af
	ld	a, l
	pop	bc
	add	a, b
	ld	b, a
;nvtest.c:45: printf("   Using test pattern 4\n");
	push	bc
	ld	hl, #___str_6
	push	hl
	call	_cprintf
	ld	hl, #(_nvBits + 0x0001)
	ex	(sp),hl
	call	_test
	pop	af
	ld	a, l
	pop	bc
	add	a, b
	ld	-1 (ix), a
;nvtest.c:47: put_nvram(nvsave);
	ld	e, -3 (ix)
	ld	d, -2 (ix)
	push	bc
	push	de
	call	_put_nvram
	pop	af
	pop	bc
;nvtest.c:48: if (wp) {
	ld	a, c
	or	a, a
	jr	Z,00104$
;nvtest.c:49: rtc_WP(ON);
	ld	de, #0x8007
	push	de
	call	_rtc_set_loc
;nvtest.c:50: printf("  DS1302 write protect is re-enabled\n");
	ld	hl, #___str_7
	ex	(sp),hl
	call	_cprintf
	pop	af
00104$:
;nvtest.c:53: return err;
	ld	l, -1 (ix)
	ld	h, #0x00
;nvtest.c:54: }
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "  DS1302 write protect is %s"
	.db 0x0a
	.db 0x00
___str_1:
	.ascii "ON"
	.db 0x00
___str_2:
	.ascii "OFF"
	.db 0x00
___str_3:
	.ascii "   Using test pattern 1"
	.db 0x0a
	.db 0x00
___str_4:
	.ascii "   Using test pattern 2"
	.db 0x0a
	.db 0x00
___str_5:
	.ascii "   Using test pattern 3"
	.db 0x0a
	.db 0x00
___str_6:
	.ascii "   Using test pattern 4"
	.db 0x0a
	.db 0x00
___str_7:
	.ascii "  DS1302 write protect is re-enabled"
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
