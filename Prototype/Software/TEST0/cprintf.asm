;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module cprintf
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _cprintf
	.globl _Yputchar
	.globl _strlen
	.globl _nstring
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
;cprintf.c:35: int cprintf(const char * fmt, ...)
;	---------------------------------
; Function cprintf
; ---------------------------------
_cprintf::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-32
	add	hl, sp
	ld	sp, hl
;cprintf.c:38: int count = 0;
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
;cprintf.c:47: va_start(ap, fmt);
	ld	hl,#36+1+1
	add	hl,sp
	ld	-18 (ix), l
	ld	-17 (ix), h
;cprintf.c:49: while(c=*fmt++)
	ld	hl, #2
	add	hl, sp
	ld	-16 (ix), l
	ld	-15 (ix), h
00171$:
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	c, (hl)
	inc	hl
	ld	4 (ix), l
	ld	5 (ix), h
	ld	b, #0x00
	ld	e, c
	ld	a,b
	ld	d,a
	or	a, c
	jp	Z, 00173$
;cprintf.c:51: count++;
	inc	-6 (ix)
	jr	NZ,00378$
	inc	-5 (ix)
00378$:
;cprintf.c:52: if(c!='%')
	ld	a, e
	sub	a, #0x25
	or	a, d
	jr	Z,00169$
;cprintf.c:54: if (c=='\n') putch('\r');
	ld	a, e
	sub	a, #0x0a
	or	a, d
	jr	NZ,00102$
	push	de
	ld	a, #0x0d
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
	pop	de
00102$:
;cprintf.c:55: putch(c);
	ld	a, e
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
	jr	00171$
00169$:
;cprintf.c:59: type=1;
	ld	-14 (ix), #0x01
	xor	a, a
	ld	-13 (ix), a
;cprintf.c:60: padch = *fmt;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	a, (bc)
	ld	-12 (ix), a
;cprintf.c:61: maxsize=minsize=0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
	xor	a, a
	ld	-11 (ix), a
	ld	-10 (ix), a
;cprintf.c:62: if(padch == '-') fmt++;
	ld	a, -12 (ix)
	sub	a, #0x2d
	ld	a, #0x01
	jr	Z,00383$
	xor	a, a
00383$:
	ld	-9 (ix), a
	or	a, a
	jr	Z,00187$
	inc	bc
	ld	4 (ix), c
	ld	5 (ix), b
00187$:
	ld	a, 4 (ix)
	ld	-2 (ix), a
	ld	a, 5 (ix)
	ld	-1 (ix), a
00174$:
;cprintf.c:66: c=*fmt++;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	c, (hl)
	inc	-2 (ix)
	jr	NZ,00384$
	inc	-1 (ix)
00384$:
	ld	a, -2 (ix)
	ld	4 (ix), a
	ld	a, -1 (ix)
	ld	5 (ix), a
	ld	-8 (ix), c
	xor	a, a
	ld	-7 (ix), a
;cprintf.c:67: if( c<'0' || c>'9' ) break;
	ld	a, -8 (ix)
	sub	a, #0x30
	ld	a, -7 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00218$
	ld	a, #0x39
	cp	a, -8 (ix)
	ld	a, #0x00
	sbc	a, -7 (ix)
	jp	PO, 00385$
	xor	a, #0x80
00385$:
	jp	M, 00218$
;cprintf.c:68: minsize*=10; minsize+=c-'0';
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	a, -8 (ix)
	add	a, #0xd0
	ld	c, a
	ld	a, -7 (ix)
	adc	a, #0xff
	ld	b, a
	add	hl, bc
	ld	-4 (ix), l
	ld	-3 (ix), h
	jr	00174$
00218$:
	ld	a, -2 (ix)
	ld	4 (ix), a
	ld	a, -1 (ix)
	ld	5 (ix), a
;cprintf.c:71: if( c == '.' )
	ld	a, -8 (ix)
	sub	a, #0x2e
	or	a, -7 (ix)
	jr	NZ,00114$
00176$:
;cprintf.c:74: c=*fmt++;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	c, (hl)
	inc	-2 (ix)
	jr	NZ,00388$
	inc	-1 (ix)
00388$:
	ld	a, -2 (ix)
	ld	4 (ix), a
	ld	a, -1 (ix)
	ld	5 (ix), a
	ld	-8 (ix), c
	xor	a, a
	ld	-7 (ix), a
;cprintf.c:75: if( c<'0' || c>'9' ) break;
	ld	a, -8 (ix)
	sub	a, #0x30
	ld	a, -7 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00219$
	ld	a, #0x39
	cp	a, -8 (ix)
	ld	a, #0x00
	sbc	a, -7 (ix)
	jp	PO, 00389$
	xor	a, #0x80
00389$:
	jp	M, 00219$
;cprintf.c:76: maxsize*=10; maxsize+=c-'0';
	ld	c, -11 (ix)
	ld	b, -10 (ix)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	a, -8 (ix)
	add	a, #0xd0
	ld	c, a
	ld	a, -7 (ix)
	adc	a, #0xff
	ld	b, a
	add	hl, bc
	ld	-11 (ix), l
	ld	-10 (ix), h
	jr	00176$
00219$:
	ld	a, -2 (ix)
	ld	4 (ix), a
	ld	a, -1 (ix)
	ld	5 (ix), a
00114$:
;cprintf.c:79: if( padch == '-' ) minsize = -minsize;
	ld	a, -9 (ix)
	or	a, a
	jr	Z,00118$
	xor	a, a
	sub	a, -4 (ix)
	ld	-4 (ix), a
	ld	a, #0x00
	sbc	a, -3 (ix)
	ld	-3 (ix), a
	jr	00119$
00118$:
;cprintf.c:81: if( padch != '0' ) padch=' ';
	ld	a, -12 (ix)
	sub	a, #0x30
	jr	Z,00119$
	ld	-12 (ix), #0x20
00119$:
;cprintf.c:83: if( c == 0 ) break;
	ld	a, -7 (ix)
	or	a, -8 (ix)
	jp	Z, 00173$
;cprintf.c:49: while(c=*fmt++)
	ld	c, 4 (ix)
	ld	b, 5 (ix)
;cprintf.c:86: c=*fmt++;
	ld	hl, #0x0001
	add	hl, bc
	ld	-2 (ix), l
	ld	-1 (ix), h
;cprintf.c:84: if(c=='h')
	ld	a, -8 (ix)
	sub	a, #0x68
	or	a, -7 (ix)
	jr	NZ,00125$
;cprintf.c:86: c=*fmt++;
	ld	a, (bc)
	ld	c, a
	ld	a, -2 (ix)
	ld	4 (ix), a
	ld	a, -1 (ix)
	ld	5 (ix), a
	ld	-8 (ix), c
	xor	a, a
	ld	-7 (ix), a
;cprintf.c:87: type = 0;
	xor	a, a
	ld	-14 (ix), a
	ld	-13 (ix), a
	jr	00126$
00125$:
;cprintf.c:89: else if(c=='l')
	ld	a, -8 (ix)
	sub	a, #0x6c
	or	a, -7 (ix)
	jr	NZ,00126$
;cprintf.c:91: c=*fmt++;
	ld	a, (bc)
	ld	c, a
	ld	a, -2 (ix)
	ld	4 (ix), a
	ld	a, -1 (ix)
	ld	5 (ix), a
	ld	-8 (ix), c
	xor	a, a
	ld	-7 (ix), a
;cprintf.c:92: type = 2;
	ld	-14 (ix), #0x02
	xor	a, a
	ld	-13 (ix), a
00126$:
;cprintf.c:98: case 'x': base=16; type |= 4;   if(0) {
	ld	a, -14 (ix)
	or	a, #0x04
	ld	-32 (ix), a
	ld	a, -13 (ix)
	ld	-31 (ix), a
;cprintf.c:104: case 0: val=va_arg(ap, short); break; 
	ld	c, -18 (ix)
	ld	b, -17 (ix)
	inc	bc
	inc	bc
	ld	e, c
	ld	d, b
	dec	de
	dec	de
;cprintf.c:105: case 1: val=va_arg(ap, int);   break;
	ld	-2 (ix), e
	ld	-1 (ix), d
;cprintf.c:95: switch(c)
	ld	a, -8 (ix)
	sub	a, #0x58
	or	a, -7 (ix)
	jr	Z,00128$
	ld	a, -8 (ix)
	sub	a, #0x63
	or	a, -7 (ix)
	jp	Z,00165$
	ld	a, -8 (ix)
	sub	a, #0x64
	or	a, -7 (ix)
	jr	Z,00135$
	ld	a, -8 (ix)
	sub	a, #0x6f
	or	a, -7 (ix)
	jr	Z,00129$
	ld	a, -8 (ix)
	sub	a, #0x73
	or	a, -7 (ix)
	jp	Z,00146$
	ld	a, -8 (ix)
	sub	a, #0x75
	or	a, -7 (ix)
	jr	Z,00132$
	ld	a, -8 (ix)
	sub	a, #0x78
	or	a, -7 (ix)
	jp	NZ,00166$
;cprintf.c:98: case 'x': base=16; type |= 4;   if(0) {
00128$:
	ld	-8 (ix), #0x10
	xor	a, a
	ld	-7 (ix), a
	ld	a, -32 (ix)
	ld	-14 (ix), a
	ld	a, -31 (ix)
	ld	-13 (ix), a
	jr	00137$
;cprintf.c:99: case 'o': base= 8; type |= 4; } if(0) {
00129$:
	ld	-8 (ix), #0x08
	xor	a, a
	ld	-7 (ix), a
	ld	a, -32 (ix)
	ld	-14 (ix), a
	ld	a, -31 (ix)
	ld	-13 (ix), a
	jr	00137$
;cprintf.c:100: case 'u': base=10; type |= 4; } if(0) {
00132$:
	ld	-8 (ix), #0x0a
	xor	a, a
	ld	-7 (ix), a
	ld	a, -32 (ix)
	ld	-14 (ix), a
	ld	a, -31 (ix)
	ld	-13 (ix), a
	jr	00137$
;cprintf.c:101: case 'd': base=-10; }
00135$:
	ld	-8 (ix), #0xf6
	ld	-7 (ix), #0xff
00137$:
;cprintf.c:102: switch(type)
	ld	a, -14 (ix)
	or	a, a
	or	a, -13 (ix)
	jr	Z,00138$
	ld	a, -14 (ix)
	dec	a
	or	a, -13 (ix)
	jr	Z,00139$
;cprintf.c:106: case 2: val=va_arg(ap, long);  break;
	ld	a, -18 (ix)
	add	a, #0x04
	ld	l, a
	ld	a, -17 (ix)
	adc	a, #0x00
	ld	h, a
	ld	a, l
	add	a, #0xfc
	ld	-2 (ix), a
	ld	a, h
	adc	a, #0xff
	ld	-1 (ix), a
;cprintf.c:102: switch(type)
	ld	a, -14 (ix)
	sub	a, #0x02
	or	a, -13 (ix)
	jr	Z,00140$
	ld	a, -14 (ix)
	sub	a, #0x04
	or	a, -13 (ix)
	jr	Z,00141$
	ld	a, -14 (ix)
	sub	a, #0x05
	or	a, -13 (ix)
	jr	Z,00142$
	ld	a, -14 (ix)
	sub	a, #0x06
	or	a, -13 (ix)
	jr	Z,00143$
	jr	00144$
;cprintf.c:104: case 0: val=va_arg(ap, short); break; 
00138$:
	ld	-18 (ix), c
	ld	-17 (ix), b
	ex	de,hl
	ld	c, (hl)
	inc	hl
	ld	a, (hl)
	ld	b, a
	rla
	sbc	a, a
	ld	e, a
	ld	d, a
	jr	00145$
;cprintf.c:105: case 1: val=va_arg(ap, int);   break;
00139$:
	ld	-18 (ix), c
	ld	-17 (ix), b
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	c, (hl)
	inc	hl
	ld	a, (hl)
	ld	b, a
	rla
	sbc	a, a
	ld	e, a
	ld	d, a
	jr	00145$
;cprintf.c:106: case 2: val=va_arg(ap, long);  break;
00140$:
	ld	-18 (ix), l
	ld	-17 (ix), h
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	jr	00145$
;cprintf.c:107: case 4: val=va_arg(ap, unsigned short); break; 
00141$:
	ld	-18 (ix), c
	ld	-17 (ix), b
	ex	de,hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	de, #0x0000
	jr	00145$
;cprintf.c:108: case 5: val=va_arg(ap, unsigned int);   break;
00142$:
	ld	-18 (ix), c
	ld	-17 (ix), b
	ex	de,hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	de, #0x0000
	jr	00145$
;cprintf.c:109: case 6: val=va_arg(ap, unsigned long);  break;
00143$:
	ld	-18 (ix), l
	ld	-17 (ix), h
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	jr	00145$
;cprintf.c:110: default:val=0; break;
00144$:
	ld	bc, #0x0000
	ld	de, #0x0000
;cprintf.c:111: }
00145$:
;cprintf.c:112: cp = __numout(val,base,out);
	ld	l, -16 (ix)
	ld	h, -15 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	push	de
	push	bc
	call	___numout
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c, l
	ld	b, h
;cprintf.c:113: if(0) {
	jr	00148$
;cprintf.c:114: case 's':
00146$:
;cprintf.c:115: cp=va_arg(ap, char *);
	ld	-18 (ix), c
	ld	-17 (ix), b
	ex	de,hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
00148$:
;cprintf.c:117: count--;
	ld	a, -6 (ix)
	add	a, #0xff
	ld	-2 (ix), a
	ld	a, -5 (ix)
	adc	a, #0xff
	ld	-1 (ix), a
;cprintf.c:118: c = strlen(cp);
	push	bc
	push	bc
	call	_strlen
	pop	af
	pop	bc
	ld	-6 (ix), l
	ld	-5 (ix), h
;cprintf.c:119: if( !maxsize ) maxsize = c;
	ld	a, -10 (ix)
	or	a, -11 (ix)
	jr	NZ,00150$
	ld	a, -6 (ix)
	ld	-11 (ix), a
	ld	a, -5 (ix)
	ld	-10 (ix), a
00150$:
;cprintf.c:120: if( minsize > 0 )
	xor	a, a
	cp	a, -4 (ix)
	sbc	a, -3 (ix)
	jp	PO, 00409$
	xor	a, #0x80
00409$:
	jp	P, 00155$
;cprintf.c:122: minsize -= c;
	ld	a, -4 (ix)
	sub	a, -6 (ix)
	ld	e, a
	ld	a, -3 (ix)
	sbc	a, -5 (ix)
	ld	d, a
;cprintf.c:123: while(minsize>0) { putch(padch); count++; minsize--; }
	ld	l, -2 (ix)
	ld	h, -1 (ix)
00151$:
	xor	a, a
	cp	a, e
	sbc	a, d
	jp	PO, 00410$
	xor	a, #0x80
00410$:
	jp	P, 00220$
	push	hl
	push	bc
	push	de
	ld	a, -12 (ix)
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
	pop	de
	pop	bc
	pop	hl
	inc	hl
	dec	de
	jr	00151$
00220$:
	ld	-2 (ix), l
	ld	-1 (ix), h
;cprintf.c:124: minsize=0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
00155$:
;cprintf.c:126: if( minsize < 0 ) minsize= -minsize-c;
	bit	7, -3 (ix)
	jr	Z,00215$
	xor	a, a
	sub	a, -4 (ix)
	ld	e, a
	ld	a, #0x00
	sbc	a, -3 (ix)
	ld	d, a
	ld	a, e
	sub	a, -6 (ix)
	ld	-4 (ix), a
	ld	a, d
	sbc	a, -5 (ix)
	ld	-3 (ix), a
;cprintf.c:127: while(*cp && maxsize-->0 )
00215$:
	ld	e, -11 (ix)
	ld	d, -10 (ix)
	ld	-6 (ix), c
	ld	-5 (ix), b
	ld	c, -2 (ix)
	ld	b, -1 (ix)
00159$:
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	h, (hl)
	ld	a, h
	or	a, a
	jr	Z,00221$
	xor	a, a
	cp	a, e
	sbc	a, d
	jp	PO, 00411$
	xor	a, #0x80
00411$:
	jp	P, 00221$
	dec	de
;cprintf.c:129: putch(*cp++);
	inc	-6 (ix)
	jr	NZ,00412$
	inc	-5 (ix)
00412$:
	push	bc
	push	de
	push	hl
	inc	sp
	call	_Yputchar
	inc	sp
	pop	de
	pop	bc
;cprintf.c:130: count++;
	inc	bc
	jr	00159$
;cprintf.c:132: while(minsize>0) { putch(' '); count++; minsize--; }
00221$:
	ld	-6 (ix), c
	ld	-5 (ix), b
	ld	-2 (ix), c
	ld	-1 (ix), b
	ld	c, -4 (ix)
	ld	b, -3 (ix)
00162$:
	xor	a, a
	cp	a, c
	sbc	a, b
	jp	PO, 00413$
	xor	a, #0x80
00413$:
	jp	P, 00171$
	push	bc
	ld	a, #0x20
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
	pop	bc
	inc	-2 (ix)
	jr	NZ,00414$
	inc	-1 (ix)
00414$:
	ld	a, -2 (ix)
	ld	-6 (ix), a
	ld	a, -1 (ix)
	ld	-5 (ix), a
	dec	bc
	jr	00162$
;cprintf.c:134: case 'c':
00165$:
;cprintf.c:135: putch(va_arg(ap, int));
	ld	-18 (ix), c
	ld	-17 (ix), b
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
;cprintf.c:136: break;
	jp	00171$
;cprintf.c:137: default:
00166$:
;cprintf.c:138: putch(c);
	ld	a, -8 (ix)
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
;cprintf.c:140: }
	jp	00171$
00173$:
;cprintf.c:144: return count;
	ld	l, -6 (ix)
	ld	h, -5 (ix)
;cprintf.c:145: }
	ld	sp, ix
	pop	ix
	ret
;cprintf.c:153: __numout(long i, int base, unsigned char *out)
;	---------------------------------
; Function __numout
; ---------------------------------
___numout:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-12
	add	hl, sp
	ld	sp, hl
;cprintf.c:156: int flg = 0;
	ld	hl, #0x0000
	ex	(sp), hl
;cprintf.c:159: if (base<0)
	bit	7, 9 (ix)
	jr	Z,00104$
;cprintf.c:161: base = -base;
	xor	a, a
	sub	a, 8 (ix)
	ld	8 (ix), a
	ld	a, #0x00
	sbc	a, 9 (ix)
	ld	9 (ix), a
;cprintf.c:162: if (i<0)
	bit	7, 7 (ix)
	jr	Z,00104$
;cprintf.c:164: flg = 1;
	ld	hl, #0x0001
	ex	(sp), hl
;cprintf.c:165: i = -i;
	xor	a, a
	sub	a, 4 (ix)
	ld	4 (ix), a
	ld	a, #0x00
	sbc	a, 5 (ix)
	ld	5 (ix), a
	ld	a, #0x00
	sbc	a, 6 (ix)
	ld	6 (ix), a
	ld	a, #0x00
	sbc	a, 7 (ix)
	ld	7 (ix), a
00104$:
;cprintf.c:168: val = i;
	ld	hl, #2
	add	hl, sp
	ex	de, hl
	ld	hl, #16
	add	hl, sp
	ld	bc, #4
	ldir
;cprintf.c:170: out[NUMLTH] = '\0';
	ld	a, 10 (ix)
	add	a, #0x0b
	ld	c, a
	ld	a, 11 (ix)
	adc	a, #0x00
	ld	b, a
	xor	a, a
	ld	(bc), a
;cprintf.c:172: do
	ld	bc, #0x000a
00105$:
;cprintf.c:175: out[n] = nstring[val % base];
	ld	a, 10 (ix)
	add	a, c
	ld	-6 (ix), a
	ld	a, 11 (ix)
	adc	a, b
	ld	-5 (ix), a
	ld	a, 8 (ix)
	ld	-4 (ix), a
	ld	a, 9 (ix)
	ld	-3 (ix), a
	rla
	sbc	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
	push	bc
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	call	__modulong
	pop	af
	pop	af
	pop	af
	pop	af
	pop	bc
	ld	a, #<(_nstring)
	add	a, l
	ld	l, a
	ld	a, #>(_nstring)
	adc	a, h
	ld	h, a
	ld	a, (hl)
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	(hl), a
;cprintf.c:176: val /= base;
	push	bc
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	pop	bc
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	-8 (ix), e
	ld	-7 (ix), d
;cprintf.c:177: --n;
	dec	bc
;cprintf.c:183: while(val);
	ld	a, -7 (ix)
	or	a, -8 (ix)
	or	a, -9 (ix)
	or	a, -10 (ix)
	jp	NZ, 00105$
;cprintf.c:184: if(flg) out[n--] = '-';
	ld	e, c
	ld	d, b
	ld	a, -11 (ix)
	or	a, -12 (ix)
	jr	Z,00109$
	ld	e, c
	ld	d, b
	dec	de
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	add	hl, bc
	ld	(hl), #0x2d
00109$:
;cprintf.c:186: return &out[n+1];
	inc	de
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	add	hl, de
;cprintf.c:187: }
	ld	sp, ix
	pop	ix
	ret
_nstring:
	.ascii "0123456789ABCDEF"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
