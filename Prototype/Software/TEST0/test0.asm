;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module test0
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _check_cts
	.globl _numout
	.globl _putstr
	.globl _check_P10
	.globl _old_P10
	.globl _cpu_type
	.globl _lite_on
	.globl _lite_off
	.globl _wait
	.globl _Yputchar
	.globl _cprintf
	.globl _inp
	.globl _outp
	.globl _cputype
	.globl _ptype
	.globl _qbf
	.globl _str
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_cputype::
	.ds 1
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
;z180.h:45: static void _ENABLE_Z180_ASSEMBLER_(void) __naked { __asm .hd64 __endasm; }
;	---------------------------------
; Function _ENABLE_Z180_ASSEMBLER_
; ---------------------------------
__ENABLE_Z180_ASSEMBLER_:
	.hd64	
;test0.c:37: int old_P10(byte device)
;	---------------------------------
; Function old_P10
; ---------------------------------
_old_P10::
	push	ix
	ld	ix,#0
	add	ix,sp
;test0.c:41: device = (device & 0xF0) + 9;
	ld	a, 4 (ix)
	and	a, #0xf0
	add	a, #0x09
;test0.c:42: tem = inp(device);
	ld	4 (ix), a
	push	af
	inc	sp
	call	_inp
	inc	sp
	ld	c, l
;test0.c:43: if (tem & ~SD_ALL) return 0;
	ld	a, c
	and	a, #0x0b
	jr	Z,00102$
	ld	hl, #0x0000
	jr	00106$
00102$:
;test0.c:45: if (tem & SD_IPEND) {
	bit	7, c
	jr	Z,00104$
;test0.c:46: outp(device, tem);
	ld	a, c
	push	af
	inc	sp
	ld	a, 4 (ix)
	push	af
	inc	sp
	call	_outp
	pop	af
;test0.c:47: tem = !(inp(device) & SD_IPEND);
	ld	a, 4 (ix)
	push	af
	inc	sp
	call	_inp
	inc	sp
	ld	a, l
	and	a, #0x80
	or	a,#0x00
	sub	a,#0x01
	ld	a, #0x00
	rla
	jr	00105$
00104$:
;test0.c:50: outp(device, tem ^ SD_CD);
	ld	a, c
	xor	a, #0x20
	push	af
	inc	sp
	ld	a, 4 (ix)
	push	af
	inc	sp
	call	_outp
	pop	af
;test0.c:51: tem = !!(inp(device) & SD_IPEND);
	ld	a, 4 (ix)
	push	af
	inc	sp
	call	_inp
	inc	sp
	ld	a, l
	and	a, #0x80
	or	a,#0x00
	sub	a,#0x01
	ld	a, #0x00
	rla
	xor	a, #0x01
00105$:
;test0.c:53: return tem;
	ld	l, a
	ld	h, #0x00
00106$:
;test0.c:54: }
	pop	ix
	ret
;test0.c:57: int check_P10(void)
;	---------------------------------
; Function check_P10
; ---------------------------------
_check_P10::
;test0.c:60: byte err = !old_P10(0x89);
	ld	a, #0x89
	push	af
	inc	sp
	call	_old_P10
	inc	sp
	ld	c, l
	ld	a, h
	or	a, c
	sub	a,#0x01
	ld	a, #0x00
	rla
	ld	e, a
;test0.c:62: for (device=0; !err && device<0xFF; device+=0x10) {
	ld	hl, #0x0000
00108$:
	ld	a, e
	or	a, a
	jr	NZ,00105$
	ld	c, l
	ld	b, h
	ld	a, c
	sub	a, #0xff
	ld	a, b
	sbc	a, #0x00
	jr	NC,00105$
;test0.c:63: if (device>=0x40 && device<0x8F) continue;
	ld	a, c
	sub	a, #0x40
	ld	a, b
	sbc	a, #0x00
	jr	C,00102$
	ld	a, c
	sub	a, #0x8f
	ld	a, b
	sbc	a, #0x00
	jr	C,00104$
00102$:
;test0.c:64: err |= old_P10(device);
	ld	a, l
	push	bc
	push	de
	push	af
	inc	sp
	call	_old_P10
	inc	sp
	pop	de
	pop	bc
	ld	a, l
	or	a, e
	ld	e, a
00104$:
;test0.c:62: for (device=0; !err && device<0xFF; device+=0x10) {
	ld	hl, #0x0010
	add	hl, bc
	jr	00108$
00105$:
;test0.c:66: return err;
	ld	h, #0x00
	ld	l, e
;test0.c:67: }
	ret
;test0.c:70: void putstr(char *str)
;	---------------------------------
; Function putstr
; ---------------------------------
_putstr::
;test0.c:74: ch = *str++;
	pop	bc
	pop	de
	push	de
	push	bc
	ld	a, (de)
	ld	b, a
	inc	de
	ld	iy, #2
	add	iy, sp
	ld	0 (iy), e
	ld	1 (iy), d
;test0.c:75: while (ch) {
	pop	de
	pop	hl
	push	hl
	push	de
00103$:
	ld	a, b
	or	a, a
	ret	Z
;test0.c:76: if (ch == '\n') putchar('\r');
	ld	a, b
	sub	a, #0x0a
	jr	NZ,00102$
	push	hl
	push	bc
	ld	a, #0x0d
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
	pop	bc
	pop	hl
00102$:
;test0.c:77: putchar(ch);
	push	hl
	push	bc
	inc	sp
	call	_Yputchar
	inc	sp
	pop	hl
;test0.c:78: ch = *str++;
	ld	b, (hl)
	inc	hl
;test0.c:80: }
	jr	00103$
;test0.c:83: void numout(uint8 n)
;	---------------------------------
; Function numout
; ---------------------------------
_numout::
	dec	sp
;test0.c:86: lite_off();
	call	_lite_off
;test0.c:87: wait(75);
	ld	hl, #0x004b
	push	hl
	call	_wait
	pop	af
;test0.c:88: while (n--) {
	ld	iy, #3
	add	iy, sp
	ld	a, 0 (iy)
	dec	iy
	dec	iy
	dec	iy
	ld	0 (iy), a
00101$:
	ld	iy, #0
	add	iy, sp
	ld	c, 0 (iy)
	dec	0 (iy)
	ld	a, c
	or	a, a
	jr	Z,00103$
;test0.c:89: lite_on();
	call	_lite_on
;test0.c:90: wait(25);
	ld	hl, #0x0019
	push	hl
	call	_wait
	pop	af
;test0.c:91: lite_off();
	call	_lite_off
;test0.c:92: wait(35);
	ld	hl, #0x0023
	push	hl
	call	_wait
	pop	af
	jr	00101$
00103$:
;test0.c:94: wait(100);
	ld	hl, #0x0064
	push	hl
	call	_wait
	pop	af
;test0.c:95: }
	inc	sp
	ret
;test0.c:97: byte check_cts(void)
;	---------------------------------
; Function check_cts
; ---------------------------------
_check_cts::
;test0.c:101: cts = inp(CNTLB0);
	ld	a, #0x42
	push	af
	inc	sp
	call	_inp
	inc	sp
;test0.c:103: if (cts & (1<<5)) return 0;
	bit	5, l
;test0.c:104: return 1;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;test0.c:105: }
	ret
;test0.c:119: void main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
;test0.c:125: wait(150);
	ld	hl, #0x0096
	push	hl
	call	_wait
;test0.c:127: numout(5);
	ld	h,#0x05
	ex	(sp),hl
	inc	sp
	call	_numout
	inc	sp
;test0.c:128: cputype = cpu_type();
	call	_cpu_type
	ld	a, l
	ld	(_cputype+0), a
;test0.c:129: numout(cputype ? cputype : 25);
	ld	iy, #_cputype
	ld	a, 0 (iy)
	or	a, a
	jr	Z,00115$
	ld	c, 0 (iy)
	jr	00116$
00115$:
	ld	bc, #0x0019
00116$:
	ld	a, c
	push	af
	inc	sp
	call	_numout
	inc	sp
;test0.c:130: do {
00103$:
;test0.c:131: i = check_cts();
	call	_check_cts
;test0.c:132: if (i==0) numout(4);
	ld	a, l
	or	a, a
	jr	NZ,00104$
	push	hl
	ld	a, #0x04
	push	af
	inc	sp
	call	_numout
	inc	sp
	pop	hl
00104$:
;test0.c:133: } while (!i);
	ld	a, l
	or	a, a
	jr	Z,00103$
;test0.c:134: numout(1);
	ld	a, #0x01
	push	af
	inc	sp
	call	_numout
	inc	sp
;test0.c:136: putstr(str);
	ld	hl, #_str
	push	hl
	call	_putstr
;test0.c:138: printf("%s\n","Hello World!\n");
	ld	hl, #___str_1
	ex	(sp),hl
	ld	hl, #___str_0
	push	hl
	call	_cprintf
	pop	af
	pop	af
;test0.c:139: for (i=0; i<NLINE; i++) {
	ld	c, #0x00
;test0.c:140: for (j=0; j<i; j++) putchar(' ');
00122$:
	ld	b, #0x00
00109$:
	ld	a, b
	sub	a, c
	jr	NC,00106$
	push	bc
	ld	a, #0x20
	push	af
	inc	sp
	call	_Yputchar
	inc	sp
	pop	bc
	inc	b
	jr	00109$
00106$:
;test0.c:141: putstr(qbf);
	push	bc
	ld	hl, #_qbf
	push	hl
	call	_putstr
	pop	af
	pop	bc
;test0.c:139: for (i=0; i<NLINE; i++) {
	inc	c
	ld	a, c
	sub	a, #0x12
	jr	C,00122$
;test0.c:187: return;
;test0.c:188: }
	ret
_str:
	.db 0x0a
	.db 0x0a
	.ascii "Begin Test 4:"
	.db 0x0a
	.ascii "    Hi there!!"
	.db 0x0a
	.db 0x00
_qbf:
	.ascii "The quick brown fox jumps over the lazy dog."
	.db 0x0a
	.db 0x00
_ptype:
	.dw __str_4
	.dw __str_5
	.dw __str_6
	.dw __str_7
___str_0:
	.ascii "%s"
	.db 0x0a
	.db 0x00
___str_1:
	.ascii "Hello World!"
	.db 0x0a
	.db 0x00
__str_4:
	.ascii "Z80"
	.db 0x00
__str_5:
	.ascii "Z80180 vintage"
	.db 0x00
__str_6:
	.ascii "Z180 SL1960 retard"
	.db 0x00
__str_7:
	.ascii "Z180 advanced S-class"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
