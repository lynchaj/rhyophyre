;__T7220_______________________________________________________________________________________________________________________
;
;		TEST 7220 0PROGRAM
;		AUTHOR: DAN WERNER -- 7/24/2010
;________________________________________________________________________________________________________________________________
;

; DATA CONSTANTS
;________________________________________________________________________________________________________________________________
;REGISTER		IO PORT			; FUNCTION
gdc_status: 	       	.EQU	090H
gdc_command: 		.EQU	091H
gdc_param: 		.EQU	090H
gdc_read: 		.EQU	091H
ramdac_latch: 		.EQU	094H
ramdac_base: 		.EQU	098H


ramdac_address_wr:	.EQU (ramdac_base+0)
ramdac_address_rd:	.EQU (ramdac_base+3)
ramdac_palette_ram:	.EQU (ramdac_base+1)
ramdac_pixel_read_mask:	.EQU (ramdac_base+2)

ramdac_overlay_wr:	.EQU (ramdac_base+4)
ramdac_overlay_rd:	.EQU (ramdac_base+7)
ramdac_overlay_ram:	.EQU (ramdac_base+5)
ramdac_do_not_use:	.EQU  (ramdac_base+6)


BS:			.EQU    008H		; ASCII backspace character
CR:			.EQU    00DH		; CARRIAGE RETURN CHARACTER
LF:			.EQU	00AH		; LINE FEED CHARACTER
END:			.EQU	'$' 		; LINE TERMINATOR FOR CP/M STRINGS

; Latch bits
LATCH_RAMDAC_256:	.EQU	80H		; 256 color mode
LATCH_OVERLAY_MASK:	.EQU    0FH     	; 4 overlay bits

;
; commands:
;
RESET			.EQU	000H
SYNC	 		.EQU	00EH
VSYNC  			.EQU	06FH
CCHAR  			.EQU	04BH
START			.EQU	06BH
ZOOM   			.EQU	046H
CURS	 		.EQU	049H
PRAM   			.EQU	070H
PITCH	 		.EQU	047H

WDAT	 		.EQU	020H


; Drawing modes:
GDC_REPLACE	.EQU		0
GDC_XOR		.EQU		1
GDC_OR		.EQU		3
GDC_CLEAR	.EQU		2



;________________________________________________________________________________________________________________________________
; MAIN PROGRAM BEGINS HERE
;________________________________________________________________________________________________________________________________
	.ORG	$0100

	LD	DE,MSG_START	;
	LD	C,09H		;
	CALL	0005H 		;

	CALL	ramdac_init	;
	LD 	A,0FH		;
	CALL 	ramdac_set_read_mask	;    ramdac_set_read_mask(0x0F)
	LD	A,0
	CALL 	ramdac_overlay	;   ramdac_overlay(0)


	LD	A,1
	CALL	gdc_init	;

	LD	DE,MSG_INIT	;
	LD	C,09H		; CP/M WRITE END STRING TO CONSOLE CALL
	CALL	0005H 		;

	CALL 	CLEAR_SCREEN


	LD	DE,MSG_GCHAR	;
	LD	C,09H		; CP/M WRITE END STRING TO CONSOLE CALL
	CALL	0005H 		;

    	CALL 	gchar_test	;

	; ********* ZOOM  	gdc_zoom_draw(0);
      	LD	A,ZOOM		; DO ZOOM
	CALL	OUTA		; SEND COMMAND
	LD	A,0
	CALL	OUTP

	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,FONT+1656-8
	LD 	HL,0000
	LD 	A,GDC_REPLACE
	LD 	C,0
	CALL 	gchar_print

	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,FONT+1656-16
	LD 	HL,0001
	LD 	A,GDC_REPLACE
	LD 	C,1
	CALL 	gchar_print

	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,FONT+1656-24
	LD 	HL,002
	LD 	A,GDC_REPLACE
	LD 	C,2
	CALL 	gchar_print

	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,FONT+1656-32
	LD 	HL,003
	LD 	A,GDC_REPLACE
	LD 	C,3
	CALL 	gchar_print



	LD	DE,MSG_END	;
	LD	C,09H		; CP/M WRITE END STRING TO CONSOLE CALL
	CALL	0005H 		;

	LD	C,00H		; CP/M SYSTEM RESET CALL
	CALL	0005H 		; RETURN TO PROMPT

SYNCP: 	.DB	012H,026H,044H,004H,002H,00AH,0E0H,085H  ;;VERIFY THESE NUMBERS
CCHARP:	.DB	000H,000H,000H
PITCHP:	.DB	028H   ;;VERIFY THESE NUMBERS
PRAMP:	.DB	000H,000H,000H,01EH		;000H,000H,000H,0E0H,001H,000H,000H
ZOOMP:	.DB	000H   VERIFY THESE NUMBERS
CURSP:	.DB	000H,000H,000H
PATTERN:	.DW	0FFFFH

CHPATTERN: .DB	0ffH, 09fH, 087H, 08bH,093H, 0a3H, 083H, 0ffH
CLPATTERN: .DB	0ffH, 0ffH, 0ffH, 0ffH,0ffH, 0ffH, 0ffH, 0ffH
ZRPATTERN: .DB	0H, 0H, 0H, 0H,0H, 0H, 0H, 0H


default_palette:
	.DB	0,   0,   0
	.DB	0,   0, 128
	.DB	0, 128,   0
	.DB	0, 128, 128
	.DB	128,   0,   0
	.DB	128,   0, 128
	.DB	128,  64,   0
	.DB	128, 128, 128
	.DB	64,  64,  64
	.DB	 0,   0, 255
	.DB	 0, 255,   0
	.DB	 0, 255, 255
	.DB	255,   0,   0
	.DB	255,   0, 255
	.DB	255, 255,   0
	.DB	255, 255, 255


ramdac_init:
	LD	A,0		;   ramdac_overlay(0)
	CALL 	ramdac_overlay

	LD 	A,1
	LD 	IX,default_palette+3
ramdac_init_a:
	; parameter (overlay, Red,Green,Blue) in C,H,L,B
	LD 	C,A
	LD 	H,(IX)
	INC 	IX
	LD 	L,(IX)
	INC 	IX
	LD 	B,(IX)
	INC 	IX
	CALL 	ramdac_set_overlay_color
	INC 	A
	CP 	16
	JP 	NZ,ramdac_init_a

	LD	A,8		;   ramdac_overlay(8)
	CALL 	ramdac_overlay
   	LD	A,0FH		;   ramdac_set_read_mask(0x0F);
	CALL	ramdac_set_read_mask

	LD 	A,0
	LD 	IX,default_palette
ramdac_init_b:
	; parameter (index, Red,Green,Blue) in C,H,L,B
	LD 	C,A
	LD 	H,(IX)
	INC 	IX
	LD 	L,(IX)
	INC 	IX
	LD 	B,(IX)
	INC 	IX
	CALL 	ramdac_set_palette_color
	INC 	A
	CP 	16
	JP 	NZ,ramdac_init_b

	RET

; parameter(mask) in A
ramdac_set_read_mask:
	OUT	(ramdac_pixel_read_mask),A
	RET

; parameter(overlay) in A
ramdac_overlay:
	AND 	LATCH_OVERLAY_MASK
	OR 	LATCH_RAMDAC_256
	OUT	(ramdac_latch),A	; Set Ramdac latch
	RET

; parameter (overlay, Red,Green,Blue) in C,H,L,B
ramdac_set_overlay_color:
	PUSH	AF		; STORE REGISTERS
	LD 	A,C
	OUT	(ramdac_overlay_wr),A
;	PUSH 	HL
;	call 	HXOUT
;	call 	PRINTC
;	POP 	HL
;	call 	delay
	LD 	A,H
	OUT	(ramdac_overlay_ram),A
;	PUSH 	HL
;	call 	HXOUT
;	call 	PRINTP
;	POP 	HL
;	call 	delay
	LD 	A,L
	OUT	(ramdac_overlay_ram),A
;	PUSH 	HL
;	call 	HXOUT
;	call 	PRINTP
;	POP 	HL
;	call 	delay
	LD 	A,B
	OUT	(ramdac_overlay_ram),A
;	PUSH 	HL
	;call 	HXOUT
;	call 	PRINTP
;	POP 	HL
;	call 	delay
;	PUSH 	HL
;	call 	PRINTCRLF
;	POP 	HL
	POP	AF		; RESTORE
	RET

; parameter (index, Red,Green,Blue) in C,H,L,B
ramdac_set_palette_color:
 	PUSH	AF		; STORE REGISTERS
	LD 	A,C
	OUT	(ramdac_address_wr),A
;	PUSH 	HL
;	call 	HXOUT
;	call 	PRINTC
;	POP 	HL
;	call 	delay
	LD 	A,H
	OUT	(ramdac_palette_ram),A
;	PUSH 	HL
	;call 	HXOUT
;	call 	PRINTP
;	POP 	HL
;	call 	delay
	LD 	A,L
	OUT	(ramdac_palette_ram),A
;	PUSH 	HL
;	call 	HXOUT
;	call 	PRINTP
;	POP 	HL
;	call 	delay
	LD 	A,B
	OUT	(ramdac_palette_ram),A
;	PUSH 	HL
;	call 	HXOUT
;	call 	PRINTP
;	POP 	HL
;	call 	delay
;	PUSH 	HL
;	call 	PRINTCRLF
;	POP 	HL
	POP	AF		; RESTORE
	RET

; parameter enable/blank the screen 1/0  in A
gdc_init:
	PUSH 	AF
	; ********* RESET
	LD	A,RESET		; DO RESET
	CALL	OUTA		; SEND COMMAND
	; ********* SYNC
	POP 	AF
	OR	SYNC		; DO SYNC (0x0E if blanked 0x0F if enabled)
	CALL	OUTA		; SEND COMMAND
	LD	C,8		; NUMBER PARMS
	LD	HL,SYNCP	; PARM TABLE
	CALL	OUTC		; SEND PARMS
	; ********* VSYNC
	LD	A,VSYNC		; DO VSYNC
	CALL	OUTA		; SEND COMMAND
	; ********* CCHAR
      	LD	A,CCHAR		; DO CCHAR
	CALL	OUTA		; SEND COMMAND
	LD	HL,CCHARP	; PARM TABLE
	LD	C,03H		; NUMBER PARAMS
	CALL	OUTC
	; ********* PITCH
      	LD	A,PITCH		; DO PITCH
	CALL	OUTA		; SEND COMMAND
	LD	HL,PITCHP	; PARM TABLE
	LD	C,01H		; NUMBER PARAMS
	CALL	OUTC
	; ********* PRAM 1
	LD	HL,PRAMP	; PARM TABLE
	LD	C,4		; NUMBER PARAMS
	LD 	A,0		; START ADDRESS
    	CALL	gdc_pram	; graphic area 1
	; ********* PRAM 2
    	LD	HL,PRAMP	; PARM TABLE
	LD	C,4		; NUMBER PARAMS
	LD 	A,4		; START ADDRESS
    	CALL	gdc_pram	; graphic area 2
	; ********* PATTERN
    	LD	HL,PATTERN	; PARM TABLE
	LD	C,2		; NUMBER PARAMS
	LD 	A,8		; START ADDRESS
    	CALL	gdc_pram	; graphic area 2
	; ********* ZOOM DISPLAY (FACTOR 1)
	LD 	A,0
	CALL 	gdc_zoom_display
	; ********* SET CURSOR
	LD 	HL,0000H
	LD 	A,0H
	CALL 	gdc_setcursor
	; ********* SET MODE
	LD 	A,GDC_REPLACE
	CALL 	gdc_mode
	; ********* START
      	LD	A,START		; DO START
	CALL	OUTA		; SEND COMMAND
	RET

; parameter (mode) in a
gdc_mode:
	AND 	3
	OR 	20H
	CALL	OUTA
	RET


; parameter (StartAddress) in AHL (AAHHLL)
gdc_setcursor:
	PUSH 	AF
      	LD	A,CURS		; DO CURS
	CALL	OUTA		; SEND COMMAND
	LD 	A,L
	CALL	OUTP		; SEND PARM
	LD 	A,H
	CALL	OUTP		; SEND PARM
	POP 	AF
	CALL	OUTP		; SEND PARM
	RET

; parameter (factor) in A
gdc_zoom_display:
	PUSH 	AF
    	LD 	A,46H
    	CALL	OUTA		; SEND COMMAND
	POP 	AF
	CALL	OUTP		; SEND PARM
	RET

; parameter (start,pointer to param,count) in A,HL,C
gdc_pram:
	AND 	0FH
	OR 	PRAM
	CALL	OUTA		; SEND COMMAND
	CALL	OUTC
	RET


CLEAR_SCREEN:

	LD 	A,0FH
	CALL 	gdc_zoom_display
	LD 	HL,CLEAR_SCREEN_TABLE
CLEAR_SCREEN_A:
	; parameter (character,location,mode,color) in IX,HL,A,C
	PUSH 	HL
	LD 	E,(HL)
	INC 	HL
	LD 	D,(HL)
	EX 	DE,HL
	LD 	IX,ZRPATTERN
	LD 	A,GDC_REPLACE
	LD 	C,0
	CALL 	gchar_print
	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,ZRPATTERN
	LD 	A,GDC_REPLACE
	LD 	C,1
	CALL 	gchar_print
	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,ZRPATTERN
	LD 	A,GDC_REPLACE
	LD 	C,2
	CALL 	gchar_print
	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,ZRPATTERN
	LD 	A,GDC_REPLACE
	LD 	C,3
	CALL 	gchar_print
	POP 	HL
	INC 	HL
	INC 	HL
	LD 	A,(HL)
	CP 	0FFH
	JP 	NZ,CLEAR_SCREEN_A
	LD 	A,0FH
	CALL 	gdc_zoom_display
	RET
CLEAR_SCREEN_TABLE:
	.DW 	0000H,0008H,0010H,0018H,0020H
	.DW 	1400H,1408H,1410H,1418H,1420H
	.DW 	2800H,2808H,2810H,2818H,2820H
	.DW 	3C00H,3C08H,3C10H,3C18H,3C20H,0FFFFH


gchar_test:
;  	 x x x x x x x x
;        x     x x x x x
;        x         x x x
;        x       x   x x
;        x     x     x x
;        x   x       x x
;        x           x x
;        x x x x x x x x


	; ********* ZOOM  	gdc_zoom_draw(3);
      	LD	A,ZOOM		; DO ZOOM
	CALL	OUTA		; SEND COMMAND
	LD	A,2
	CALL	OUTP

    	LD	HL,CHPATTERN	; PARM TABLE
	LD	C,8		; NUMBER PARAMS
	LD 	A,8		; START ADDRESS
    	CALL	gdc_pram	; graphic area 2

      	LD	A,CURS		; DO CURS
	CALL	OUTA		; SEND COMMAND
	LD	A,100
	CALL 	OUTP
	LD	A,1
	CALL 	OUTP
	LD	A,0
	CALL 	OUTP

	; ********* SET MODE
	LD 	A,GDC_REPLACE
	CALL 	gdc_mode


      	LD	A,04CH		; DO FIGS
	CALL	OUTA		; SEND COMMAND
	LD	A,10H
	CALL 	OUTP
	LD	A,7
	LD	C,0
        CALL	gdc_Dparam	; perp. pix - 1
	LD	A,8
	LD	C,0
        CALL 	gdc_Dparam	; initial dir pix
	LD	A,8
	LD	C,0
        CALL 	gdc_Dparam

      	LD	A,068H		; DO GCHRD
	CALL	OUTA		; SEND COMMAND
	RET


; parameter (character,location,mode,color) in IX,HL,A,C
gchar_print:
	PUSH 	HL
	PUSH 	AF
	PUSH 	BC
	push 	HL


	PUSH 	IX
    	POP 	HL		; PARM TABLE
	LD	C,8		; NUMBER PARAMS
	LD 	A,8		; START ADDRESS
    	CALL	gdc_pram	; graphic area 2

	POP 	HL
	POP 	BC
      	LD	A,CURS		; DO CURS
	CALL	OUTA		; SEND COMMAND
	LD	A,L
	CALL 	OUTP
	LD	A,H
	CALL 	OUTP
	LD	A,C
	CALL 	OUTP
	POP 	AF
	; ********* SET MODE
	CALL 	gdc_mode


      	LD	A,04CH		; DO FIGS
	CALL	OUTA		; SEND COMMAND
	LD	A,10H
	CALL 	OUTP
	LD	A,7
	LD	C,0
        CALL	gdc_Dparam	; perp. pix - 1
	LD	A,8
	LD	C,0
        CALL 	gdc_Dparam	; initial dir pix
	LD	A,8
	LD	C,0
        CALL 	gdc_Dparam

      	LD	A,068H		; DO GCHRD
	CALL	OUTA		; SEND COMMAND
	POP 	HL
	RET


; parameter (d,or) in A,C
gdc_Dparam:
	PUSH 	AF
	CALL 	OUTP
	POP 	AF

;	AND 	03FH
;	OR 	C
	LD 	A,C
	CALL 	OUTP
	RET

OUTA:
	PUSH 	HL
 	PUSH	AF		; STORE REGISTERS
OUTALOOP:
	IN	A,(gdc_status) 	; READ STATUS
	AND	00001010B	; IS READY?
	JP	NZ,OUTALOOP	; NO, LOOP
	POP	AF		; YES, RESTORE GDC COMMAND
	OUT	(gdc_command),A	; FIFO GDC command
	POP 	HL
	RET


OUTP:
 	PUSH	AF		; STORE REGISTERS
OUTPLOOP:
	IN	A,(gdc_status) 	; READ STATUS
	AND	00001010B	; IS READY?
	JP	NZ,OUTPLOOP	; NO, LOOP
	POP	AF		; YES, RESTORE GDC PARAMETER
	OUT	(gdc_param),A	; FIFO GDC PARAMETER
	RET


OUTC:
  	IN	A,(gdc_status)	; READ STATUS
	AND	00001010B  	; IS READY?
	JP	NZ,OUTC		; NO,LOOP
	LD	A,(HL)		; GET GDC PARM
	OUT	(gdc_param),A	; WRITE PARM TO GDC
	INC	HL		; NEXT PARM
	DEC	C		; DEC COUNTER
	JP	NZ,OUTC		; IF NOT DONE, LOOP
	RET			;


MSG_START:
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.TEXT	  "START 7220 TEST PROGRAM"
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.DB	    END 				      ; LINE TERMINATOR

MSG_END:
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.TEXT	  "END 7220 TEST PROGRAM"
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.DB	    END 				      ; LINE TERMINATOR

MSG_INIT:
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.TEXT	  "7220 INIT COMPLETED"
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.DB	    END 				      ; LINE TERMINATOR


MSG_GCHAR:
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.TEXT	  "7220 GCHAR TEST"
	.DB	    LF, CR				      ; LINE FEED AND CARRIAGE RETURN
	.DB	    END 				      ; LINE TERMINATOR



;________________________________________________________________________________________________________________________________
;
COUT:
	PUSH   BC			; STORE AF
	PUSH   DE
	LD 	E,A
	LD	C,02H		;
	CALL	0005H 		;
	POP 	DE
	POP	BC			; RESTORE AF
	RET				; DONE

HXOUT:
	push    af
	PUSH	BC			; SAVE BC
	LD	B,A			;
	RLC	A			; DO HIGH NIBBLE FIRST
	RLC	A			;
	RLC	A			;
	RLC	A			;
	AND	0FH			; ONLY THIS NOW
	ADD	A,30H			; TRY A NUMBER
	CP	3AH			; TEST IT
	JR	C,OUT1			; IF CY SET PRINT 'NUMBER'
	ADD	A,07H			; MAKE IT AN ALPHA
OUT1:
	CALL	COUT			; SCREEN IT
	LD	A,B			; NEXT NIBBLE
	AND	0FH			; JUST THIS
	ADD	A,30H			; TRY A NUMBER
	CP	3AH			; TEST IT
	JR	C,OUT2			; PRINT 'NUMBER'
	ADD	A,07H			; MAKE IT ALPHA
OUT2:
	CALL	COUT			; SCREEN IT
	POP	BC			; RESTORE BC
	pop   	af
	RET				;


PRINTC:
	PUSH	AF			; STORE AF
	LD	A,':'			;
	CALL	COUT			; SCREEN IT
	POP	AF			; RESTORE AF
	RET				; DONE
PRINTP:
	PUSH	AF			; STORE AF
	LD	A,' '			;
	CALL	COUT			; SCREEN IT
	POP	AF			; RESTORE AF
	RET

PRINTCRLF:
;	PUSH	AF			; STORE AF
	;LD	A,10			;
	;CALL	COUT			; SCREEN IT
	;LD	A,13			;
	;CALL	COUT			; SCREEN IT

	;POP	AF			; RESTORE AF
	RET



FONT:			 ; Font file from FontEditor
 .DB $00,$00,$78,$78,$78,$78,$00,$00 ; $FE
 .DB $00,$00,$00,$00,$70,$20,$10,$60 ; $FD
 .DB $00,$00,$00,$00,$28,$28,$28,$50 ; $FC
 .DB $00,$20,$50,$50,$10,$10,$1C,$00 ; $FB
 .DB $00,$00,$00,$00,$20,$00,$00,$00 ; $FA
 .DB $00,$00,$00,$30,$30,$00,$00,$00 ; $F9
 .DB $00,$00,$00,$00,$30,$48,$48,$30 ; $F8
 .DB $00,$00,$50,$28,$00,$50,$28,$00 ; $F7
 .DB $00,$00,$10,$00,$7C,$00,$10,$00 ; $F6
 .DB $00,$20,$50,$10,$10,$10,$10,$10 ; $F5
 .DB $10,$10,$10,$10,$10,$14,$08,$00 ; $F4
 .DB $00,$78,$00,$08,$30,$40,$30,$08 ; $F3
 .DB $00,$78,$00,$40,$30,$08,$30,$40 ; $F2
 .DB $00,$00,$38,$00,$10,$38,$10,$00 ; $F1
 .DB $00,$00,$78,$00,$78,$00,$78,$00 ; $F0
 .DB $00,$00,$48,$48,$48,$48,$30,$00 ; $EF
 .DB $00,$00,$38,$40,$78,$40,$38,$00 ; $EE
 .DB $00,$10,$38,$54,$54,$38,$10,$00 ; $ED
 .DB $00,$00,$28,$54,$54,$28,$00,$00 ; $EC
 .DB $00,$30,$48,$38,$10,$20,$40,$30 ; $EB
 .DB $00,$6C,$28,$28,$44,$44,$38,$00 ; $EA
 .DB $00,$30,$48,$48,$78,$48,$48,$30 ; $E9
 .DB $00,$38,$10,$38,$44,$38,$10,$38 ; $E8
 .DB $00,$10,$10,$10,$50,$28,$00,$00 ; $E7
 .DB $40,$40,$70,$48,$48,$48,$00,$00 ; $E6
 .DB $00,$00,$30,$48,$48,$3C,$00,$00 ; $E5
 .DB $00,$78,$48,$20,$10,$20,$48,$78 ; $E4
 .DB $00,$28,$28,$28,$28,$28,$7C,$00 ; $E3
 .DB $00,$40,$40,$40,$40,$40,$48,$78 ; $E2
 .DB $40,$70,$48,$48,$70,$48,$70,$00 ; $E1
 .DB $00,$00,$34,$48,$48,$34,$00,$00 ; $E0
 .DB $00,$00,$00,$00,$FC,$FC,$FC,$FC ; $DF
 .DB $1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; $DE
 .DB $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0 ; $DD
 .DB $FC,$FC,$FC,$FC,$00,$00,$00,$00 ; $DC
 .DB $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC ; $DB
 .DB $10,$10,$10,$10,$1C,$00,$00,$00 ; $DA
 .DB $00,$00,$00,$00,$F0,$10,$10,$10 ; $D9
 .DB $10,$10,$10,$10,$FC,$00,$FC,$10 ; $D8
 .DB $50,$50,$50,$50,$DC,$50,$50,$50 ; $D7
 .DB $50,$50,$50,$50,$7C,$00,$00,$00 ; $D6
 .DB $10,$10,$10,$10,$1C,$10,$1C,$00 ; $D5
 .DB $00,$00,$00,$00,$1C,$10,$1C,$10 ; $D4
 .DB $00,$00,$00,$00,$7C,$50,$50,$50 ; $D3
 .DB $50,$50,$50,$50,$FC,$00,$00,$00 ; $D2
 .DB $10,$10,$10,$10,$FC,$00,$FC,$00 ; $D1
 .DB $00,$00,$00,$00,$FC,$50,$50,$50 ; $D0
 .DB $00,$00,$00,$00,$FC,$00,$FC,$10 ; $CF
 .DB $50,$50,$50,$50,$DC,$00,$DC,$50 ; $CE
 .DB $00,$00,$00,$00,$FC,$00,$FC,$00 ; $CD
 .DB $50,$50,$50,$50,$5C,$40,$5C,$50 ; $CC
 .DB $50,$50,$50,$50,$DC,$00,$FC,$00 ; $CB
 .DB $00,$00,$00,$00,$FC,$00,$DC,$50 ; $CA
 .DB $50,$50,$50,$50,$5C,$40,$7C,$00 ; $C9
 .DB $00,$00,$00,$00,$7C,$40,$5C,$50 ; $C8
 .DB $50,$50,$50,$50,$5C,$50,$50,$50 ; $C7
 .DB $10,$10,$10,$10,$1C,$10,$1C,$10 ; $C6
 .DB $10,$10,$10,$10,$FC,$10,$10,$10 ; $C5
 .DB $00,$00,$00,$00,$FC,$00,$00,$00 ; $C4
 .DB $10,$10,$10,$10,$1C,$10,$10,$10 ; $C3
 .DB $10,$10,$10,$10,$FC,$00,$00,$00 ; $C2
 .DB $00,$00,$00,$00,$FC,$10,$10,$10 ; $C1
 .DB $00,$00,$00,$00,$1C,$10,$10,$10 ; $C0
 .DB $10,$10,$10,$10,$F0,$00,$00,$00 ; $BF
 .DB $00,$00,$00,$00,$F0,$10,$F0,$10 ; $BE
 .DB $00,$00,$00,$00,$F0,$50,$50,$50 ; $BD
 .DB $00,$00,$00,$00,$F0,$10,$D0,$50 ; $BC
 .DB $50,$50,$50,$50,$D0,$10,$F0,$00 ; $BB
 .DB $50,$50,$50,$50,$50,$50,$50,$50 ; $BA
 .DB $50,$50,$50,$50,$D0,$10,$D0,$50 ; $B9
 .DB $10,$10,$10,$10,$F0,$10,$F0,$00 ; $B8
 .DB $50,$50,$50,$50,$F0,$00,$00,$00 ; $B7
 .DB $50,$50,$50,$50,$D0,$50,$50,$50 ; $B6
 .DB $10,$10,$10,$10,$F0,$10,$F0,$10 ; $B5
 .DB $10,$10,$10,$10,$F0,$10,$10,$10 ; $B4
 .DB $10,$10,$10,$10,$10,$10,$10,$10 ; $B3
 .DB $FC,$54,$FC,$A8,$FC,$54,$FC,$A8 ; $B2
 .DB $A8,$54,$A8,$54,$A8,$54,$A8,$54 ; $B1
 .DB $00,$A8,$00,$54,$00,$A8,$00,$54 ; $B0
 .DB $00,$00,$00,$48,$24,$48,$00,$00 ; $AF
 .DB $00,$00,$00,$24,$48,$24,$00,$00 ; $AE
 .DB $00,$10,$38,$38,$10,$10,$00,$10 ; $AD
 .DB $00,$04,$1C,$54,$2C,$50,$48,$40 ; $AC
 .DB $00,$1C,$08,$44,$38,$50,$48,$40 ; $AB
 .DB $00,$00,$00,$04,$04,$FC,$00,$00 ; $AA
 .DB $00,$00,$40,$40,$40,$7C,$00,$00 ; $A9
 .DB $00,$38,$44,$40,$30,$10,$00,$10 ; $A8
 .DB $00,$78,$48,$48,$48,$48,$78,$00 ; $A7
 .DB $78,$FC,$FC,$FC,$FC,$FC,$FC,$78 ; $A6
 .DB $00,$30,$78,$78,$78,$78,$30,$00 ; $A5
 .DB $00,$30,$48,$48,$48,$48,$30,$00 ; $A4
 .DB $78,$84,$84,$84,$84,$84,$84,$78 ; $A3
 .DB $04,$04,$04,$04,$04,$04,$04,$04 ; $A2
 .DB $08,$08,$08,$08,$08,$08,$08,$08 ; $A1
 .DB $20,$20,$20,$20,$20,$20,$20,$20 ; $A0
 .DB $20,$50,$10,$10,$38,$10,$14,$08 ; $9F
 .DB $00,$48,$48,$5C,$68,$50,$50,$60 ; $9E
 .DB $00,$10,$7C,$10,$7C,$10,$28,$44 ; $9D
 .DB $00,$5C,$24,$20,$78,$20,$24,$18 ; $9C
 .DB $40,$40,$40,$40,$40,$40,$40,$40 ; $9B
 .DB $80,$80,$80,$80,$80,$80,$80,$80 ; $9A
 .DB $00,$00,$00,$00,$04,$0C,$1C,$3C ; $99
 .DB $00,$00,$00,$00,$80,$C0,$E0,$F0 ; $98
 .DB $F0,$E0,$C0,$80,$00,$00,$00,$00 ; $97
 .DB $3C,$1C,$0C,$04,$00,$00,$00,$00 ; $96
 .DB $00,$00,$78,$00,$78,$00,$78,$00 ; $95
 .DB $00,$00,$54,$54,$54,$54,$54,$00 ; $94
 .DB $00,$00,$00,$00,$00,$00,$00,$FC ; $93
 .DB $00,$00,$00,$00,$00,$00,$FC,$00 ; $92
 .DB $00,$00,$00,$00,$00,$FC,$00,$00 ; $91
 .DB $00,$00,$00,$FC,$00,$00,$00,$00 ; $90
 .DB $00,$00,$FC,$00,$00,$00,$00,$00 ; $8F
 .DB $00,$FC,$00,$00,$00,$00,$00,$00 ; $8E
 .DB $1C,$1C,$1C,$1C,$FC,$FC,$FC,$FC ; $8D
 .DB $E0,$E0,$E0,$E0,$FC,$FC,$FC,$FC ; $8C
 .DB $FC,$FC,$FC,$FC,$E0,$E0,$E0,$E0 ; $8B
 .DB $FC,$FC,$FC,$FC,$1C,$1C,$1C,$1C ; $8A
 .DB $00,$00,$00,$00,$1C,$1C,$1C,$1C ; $89
 .DB $E0,$E0,$E0,$E0,$00,$00,$00,$00 ; $88
 .DB $00,$00,$00,$00,$1C,$1C,$1C,$1C ; $87
 .DB $00,$00,$00,$00,$E0,$E0,$E0,$E0 ; $86
 .DB $00,$F8,$FC,$FC,$FC,$FC,$F8,$00 ; $85
 .DB $00,$FC,$FC,$FC,$FC,$FC,$FC,$00 ; $84
 .DB $00,$3C,$7C,$7C,$7C,$7C,$3C,$00 ; $83
 .DB $38,$7C,$7C,$7C,$7C,$7C,$7C,$7C ; $82
 .DB $7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C ; $81
 .DB $7C,$7C,$7C,$7C,$7C,$7C,$7C,$38 ; $80
 .DB $00,$00,$7C,$44,$44,$6C,$38,$10 ; $7F
 .DB $00,$00,$00,$00,$00,$00,$50,$28 ; $7E
 .DB $00,$30,$08,$08,$0C,$08,$08,$30 ; $7D
 .DB $00,$10,$10,$10,$00,$10,$10,$10 ; $7C
 .DB $00,$18,$20,$20,$60,$20,$20,$18 ; $7B
 .DB $00,$78,$40,$30,$08,$78,$00,$00 ; $7A
 .DB $60,$10,$38,$48,$48,$48,$00,$00 ; $79
 .DB $00,$48,$48,$30,$48,$48,$00,$00 ; $78
 .DB $00,$28,$7C,$54,$44,$44,$00,$00 ; $77
 .DB $00,$10,$28,$44,$44,$44,$00,$00 ; $76
 .DB $00,$28,$58,$48,$48,$48,$00,$00 ; $75
 .DB $00,$10,$28,$20,$20,$78,$20,$00 ; $74
 .DB $00,$38,$04,$38,$40,$38,$00,$00 ; $73
 .DB $00,$70,$20,$20,$24,$58,$00,$00 ; $72
 .DB $04,$3C,$44,$44,$44,$3C,$00,$00 ; $71
 .DB $40,$78,$44,$44,$44,$78,$00,$00 ; $70
 .DB $00,$38,$44,$44,$44,$38,$00,$00 ; $6F
 .DB $00,$48,$48,$48,$48,$70,$00,$00 ; $6E
 .DB $00,$44,$44,$54,$54,$68,$00,$00 ; $6D
 .DB $00,$18,$10,$10,$10,$10,$10,$10 ; $6C
 .DB $00,$48,$50,$60,$50,$48,$40,$40 ; $6B
 .DB $30,$48,$08,$08,$08,$18,$00,$08 ; $6A
 .DB $00,$18,$10,$10,$10,$10,$00,$10 ; $69
 .DB $00,$48,$48,$48,$48,$70,$40,$40 ; $68
 .DB $38,$04,$3C,$44,$44,$3C,$00,$00 ; $67
 .DB $00,$20,$20,$20,$78,$20,$20,$18 ; $66
 .DB $00,$38,$40,$78,$44,$38,$00,$00 ; $65
 .DB $00,$3C,$44,$44,$44,$3C,$04,$04 ; $64
 .DB $00,$38,$44,$40,$44,$38,$00,$00 ; $63
 .DB $00,$78,$44,$44,$44,$78,$40,$40 ; $62
 .DB $00,$3C,$44,$3C,$04,$38,$00,$00 ; $61
 .DB $00,$00,$00,$00,$00,$10,$30,$30 ; $60
 .DB $FC,$00,$00,$00,$00,$00,$00,$00 ; $5F
 .DB $00,$00,$00,$00,$00,$44,$28,$10 ; $5E
 .DB $00,$38,$08,$08,$08,$08,$08,$38 ; $5D
 .DB $00,$00,$04,$08,$10,$20,$40,$00 ; $5C
 .DB $00,$38,$20,$20,$20,$20,$20,$38 ; $5B
 .DB $00,$78,$40,$40,$20,$10,$08,$78 ; $5A
 .DB $00,$10,$10,$10,$28,$44,$44,$44 ; $59
 .DB $00,$44,$44,$28,$10,$28,$44,$44 ; $58
 .DB $00,$28,$54,$54,$54,$54,$44,$44 ; $57
 .DB $00,$10,$28,$44,$44,$44,$44,$44 ; $56
 .DB $00,$38,$44,$44,$44,$44,$44,$44 ; $55
 .DB $00,$10,$10,$10,$10,$10,$10,$7C ; $54
 .DB $00,$38,$44,$04,$38,$40,$44,$38 ; $53
 .DB $00,$44,$44,$48,$78,$44,$44,$78 ; $52
 .DB $00,$34,$48,$54,$44,$44,$44,$38 ; $51
 .DB $00,$40,$40,$40,$78,$44,$44,$78 ; $50
 .DB $00,$38,$44,$44,$44,$44,$44,$38 ; $4F
 .DB $00,$44,$44,$44,$4C,$54,$64,$44 ; $4E
 .DB $00,$44,$44,$44,$44,$54,$6C,$44 ; $4D
 .DB $00,$7C,$40,$40,$40,$40,$40,$40 ; $4C
 .DB $00,$44,$48,$50,$60,$50,$48,$44 ; $4B
 .DB $00,$38,$44,$44,$04,$04,$04,$04 ; $4A
 .DB $00,$38,$10,$10,$10,$10,$10,$38 ; $49
 .DB $00,$44,$44,$44,$7C,$44,$44,$44 ; $48
 .DB $00,$3C,$44,$44,$5C,$40,$44,$38 ; $47
 .DB $00,$40,$40,$40,$78,$40,$40,$7C ; $46
 .DB $00,$7C,$40,$40,$78,$40,$40,$7C ; $45
 .DB $00,$78,$44,$44,$44,$44,$44,$78 ; $44
 .DB $00,$38,$44,$40,$40,$40,$44,$38 ; $43
 .DB $00,$78,$44,$44,$78,$44,$44,$78 ; $42
 .DB $00,$44,$44,$7C,$44,$44,$44,$38 ; $41
 .DB $00,$38,$40,$5C,$54,$5C,$44,$38 ; $40
 .DB $00,$10,$00,$10,$18,$04,$44,$38 ; $3F
 .DB $00,$20,$10,$08,$04,$08,$10,$20 ; $3E
 .DB $00,$00,$7C,$00,$00,$7C,$00,$00 ; $3D
 .DB $00,$08,$10,$20,$40,$20,$10,$08 ; $3C
 .DB $20,$30,$30,$00,$30,$30,$00,$00 ; $3B
 .DB $00,$30,$30,$00,$30,$30,$00,$00 ; $3A
 .DB $00,$30,$08,$04,$3C,$44,$44,$38 ; $39
 .DB $00,$38,$44,$44,$38,$44,$44,$38 ; $38
 .DB $00,$20,$20,$20,$10,$08,$04,$7C ; $37
 .DB $00,$38,$44,$44,$78,$40,$20,$18 ; $36
 .DB $00,$38,$44,$04,$78,$40,$40,$7C ; $35
 .DB $00,$08,$08,$7C,$48,$28,$18,$08 ; $34
 .DB $00,$38,$44,$04,$38,$04,$44,$38 ; $33
 .DB $00,$7C,$40,$20,$18,$04,$44,$38 ; $32
 .DB $00,$38,$10,$10,$10,$10,$30,$10 ; $31
 .DB $00,$38,$44,$64,$54,$4C,$44,$38 ; $30
 .DB $00,$00,$40,$20,$10,$08,$04,$00 ; $2F
 .DB $00,$30,$30,$00,$00,$00,$00,$00 ; $2E
 .DB $00,$00,$00,$00,$7C,$00,$00,$00 ; $2D
 .DB $20,$30,$30,$00,$00,$00,$00,$00 ; $2C
 .DB $00,$00,$10,$10,$7C,$10,$10,$00 ; $2B
 .DB $00,$00,$28,$38,$7C,$38,$28,$00 ; $2A
 .DB $00,$20,$10,$10,$10,$10,$10,$20 ; $29
 .DB $00,$10,$20,$20,$20,$20,$20,$10 ; $28
 .DB $00,$00,$00,$00,$00,$20,$30,$30 ; $27
 .DB $00,$34,$48,$54,$20,$50,$50,$20 ; $26
 .DB $00,$4C,$4C,$20,$10,$08,$64,$64 ; $25
 .DB $00,$10,$70,$08,$30,$40,$38,$20 ; $24
 .DB $00,$28,$7C,$28,$28,$7C,$28,$00 ; $23
 .DB $00,$00,$00,$00,$00,$48,$6C,$6C ; $22
 .DB $00,$10,$00,$10,$10,$38,$38,$10 ; $21
 .DB $00,$00,$00,$00,$00,$00,$00,$00 ; $20
 .DB $00,$00,$10,$10,$38,$38,$7C,$7C ; $1F
 .DB $00,$00,$7C,$7C,$38,$38,$10,$10 ; $1E
 .DB $00,$00,$28,$28,$7C,$28,$28,$00 ; $1D
 .DB $00,$7C,$40,$40,$40,$00,$00,$00 ; $1C
 .DB $00,$00,$10,$30,$7C,$30,$10,$00 ; $1B
 .DB $00,$00,$10,$18,$7C,$18,$10,$00 ; $1A
 .DB $00,$10,$38,$7C,$10,$10,$10,$10 ; $19
 .DB $00,$10,$10,$10,$10,$7C,$38,$10 ; $18
 .DB $38,$10,$38,$7C,$10,$7C,$38,$10 ; $17
 .DB $00,$78,$78,$00,$00,$00,$00,$00 ; $16
 .DB $00,$38,$44,$18,$28,$30,$44,$38 ; $15
 .DB $00,$14,$14,$14,$34,$54,$54,$3C ; $14
 .DB $00,$28,$00,$28,$28,$28,$28,$28 ; $13
 .DB $00,$10,$38,$7C,$10,$7C,$38,$10 ; $12
 .DB $00,$08,$18,$38,$78,$38,$18,$08 ; $11
 .DB $00,$20,$30,$38,$3C,$38,$30,$20 ; $10
 .DB $00,$10,$54,$38,$10,$38,$54,$10 ; $0F
 .DB $00,$60,$6C,$2C,$34,$2C,$34,$0C ; $0E
 .DB $00,$60,$70,$30,$10,$14,$18,$10 ; $0D
 .DB $00,$10,$38,$10,$38,$44,$44,$38 ; $0C
 .DB $00,$30,$48,$48,$34,$0C,$1C,$00 ; $0B
 .DB $FC,$FC,$84,$B4,$B4,$84,$FC,$FC ; $0A
 .DB $00,$00,$78,$48,$48,$78,$00,$00 ; $09
 .DB $FC,$FC,$FC,$CC,$CC,$FC,$FC,$FC ; $08
 .DB $00,$00,$00,$30,$30,$00,$00,$00 ; $07
 .DB $00,$38,$10,$7C,$7C,$38,$10,$00 ; $06
 .DB $00,$10,$7C,$7C,$10,$38,$38,$10 ; $05
 .DB $00,$10,$38,$7C,$7C,$38,$10,$00 ; $04
 .DB $00,$10,$38,$7C,$7C,$7C,$28,$00 ; $03
 .DB $00,$38,$7C,$44,$7C,$54,$7C,$38 ; $02
 .DB $00,$38,$44,$54,$44,$6C,$44,$38 ; $01
 .DB $00,$00,$00,$00,$00,$00,$00,$00 ; $00

.END
