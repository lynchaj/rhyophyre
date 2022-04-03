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
	LD 	IX,FONT+392
	LD 	HL,0000
	LD 	A,GDC_REPLACE
	LD 	C,0
	CALL 	gchar_print

	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,FONT+392+8
	LD 	HL,0001
	LD 	A,GDC_REPLACE
	LD 	C,1
	CALL 	gchar_print

	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,FONT+392+16
	LD 	HL,002
	LD 	A,GDC_REPLACE
	LD 	C,2
	CALL 	gchar_print

	; parameter (character,location,mode,color) in IX,HL,A,C
	LD 	IX,FONT+392+24
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
	LD 	A,H
	OUT	(ramdac_overlay_ram),A
	LD 	A,L
	OUT	(ramdac_overlay_ram),A
	LD 	A,B
	OUT	(ramdac_overlay_ram),A
	POP	AF		; RESTORE
	RET

; parameter (index, Red,Green,Blue) in C,H,L,B
ramdac_set_palette_color:
 	PUSH	AF		; STORE REGISTERS
	LD 	A,C
	OUT	(ramdac_address_wr),A
	LD 	A,H
	OUT	(ramdac_palette_ram),A
	LD 	A,L
	OUT	(ramdac_palette_ram),A
	LD 	A,B
	OUT	(ramdac_palette_ram),A
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





FONT:			FONT:
	.db	$00, $00, $00, $00, $00, $00, $00, $00	; (.)
	.db	$7E, $81, $A5, $81, $BD, $99, $81, $7E	; (.)
	.db	$7E, $FF, $DB, $FF, $C3, $E7, $FF, $7E	; (.)
	.db	$6C, $FE, $FE, $FE, $7C, $38, $10, $00	; (.)
	.db	$10, $38, $7C, $FE, $7C, $38, $10, $00	; (.)
	.db	$38, $38, $38, $FE, $FE, $D6, $10, $38	; (.)
	.db	$10, $10, $38, $7C, $FE, $7C, $10, $38	; (.)
	.db	$00, $00, $18, $3C, $3C, $18, $00, $00	; (.)
	.db	$FF, $FF, $E7, $C3, $C3, $E7, $FF, $FF	; (.)
	.db	$00, $3C, $66, $42, $42, $66, $3C, $00	; (.)
	.db	$FF, $C3, $99, $BD, $BD, $99, $C3, $FF	; (.)
	.db	$0F, $03, $05, $7D, $84, $84, $84, $78	; (.)
	.db	$3C, $42, $42, $42, $3C, $18, $7E, $18	; (.)
	.db	$3F, $21, $3F, $20, $20, $60, $E0, $C0	; (.)
	.db	$3F, $21, $3F, $21, $23, $67, $E6, $C0	; (.)
	.db	$18, $DB, $3C, $E7, $E7, $3C, $DB, $18	; (.)
	.db	$80, $E0, $F8, $FE, $F8, $E0, $80, $00	; (.)
	.db	$02, $0E, $3E, $FE, $3E, $0E, $02, $00	; (.)
	.db	$18, $3C, $7E, $18, $18, $7E, $3C, $18	; (.)
	.db	$24, $24, $24, $24, $24, $00, $24, $00	; (.)
	.db	$7F, $92, $92, $72, $12, $12, $12, $00	; (.)
	.db	$3E, $63, $38, $44, $44, $38, $CC, $78	; (.)
	.db	$00, $00, $00, $00, $7E, $7E, $7E, $00	; (.)
	.db	$18, $3C, $7E, $18, $7E, $3C, $18, $FF	; (.)
	.db	$10, $38, $7C, $54, $10, $10, $10, $00	; (.)
	.db	$10, $10, $10, $54, $7C, $38, $10, $00	; (.)
	.db	$00, $18, $0C, $FE, $0C, $18, $00, $00	; (.)
	.db	$00, $30, $60, $FE, $60, $30, $00, $00	; (.)
	.db	$00, $00, $40, $40, $40, $7E, $00, $00	; (.)
	.db	$00, $24, $66, $FF, $66, $24, $00, $00	; (.)
	.db	$00, $10, $38, $7C, $FE, $FE, $00, $00	; (.)
	.db	$00, $FE, $FE, $7C, $38, $10, $00, $00	; (.)
	.db	$00, $00, $00, $00, $00, $00, $00, $00	; ( )
	.db	$10, $10, $10, $10, $10, $00, $10, $00	; (!)
	.db	$24, $24, $24, $00, $00, $00, $00, $00	; (")
	.db	$24, $24, $7E, $24, $7E, $24, $24, $00	; (#)
	.db	$18, $3E, $40, $3C, $02, $7C, $18, $00	; ($)
	.db	$00, $62, $64, $08, $10, $26, $46, $00	; (%)
	.db	$30, $48, $30, $56, $88, $88, $76, $00	; (&)
	.db	$10, $10, $20, $00, $00, $00, $00, $00	; (')
	.db	$10, $20, $40, $40, $40, $20, $10, $00	; (()
	.db	$20, $10, $08, $08, $08, $10, $20, $00	; ())
	.db	$00, $44, $38, $FE, $38, $44, $00, $00	; (*)
	.db	$00, $10, $10, $7C, $10, $10, $00, $00	; (+)
	.db	$00, $00, $00, $00, $00, $10, $10, $20	; (,)
	.db	$00, $00, $00, $7E, $00, $00, $00, $00	; (-)
	.db	$00, $00, $00, $00, $00, $10, $10, $00	; (.)
	.db	$00, $02, $04, $08, $10, $20, $40, $00	; (/)
	.db	$3C, $42, $46, $4A, $52, $62, $3C, $00	; (0)
	.db	$ff, $00, $40, $40, $7F, $42, $44, $00	; (1)
	.db	$ff, $66, $49, $49, $51, $51, $62, $00	; (2)
	.db	$ff, $36, $49, $49, $49, $41, $22, $00	; (3)
	.db	$ff, $10, $50, $7F, $52, $14, $18, $10	; (4)
	.db	$7E, $40, $7C, $02, $02, $42, $3C, $ff	; (5)
	.db	$1C, $20, $40, $7C, $42, $42, $3C, $ff	; (6)
	.db	$7E, $42, $04, $08, $10, $10, $10, $ff	; (7)
	.db	$3C, $42, $42, $3C, $42, $42, $3C, $ff	; (8)
	.db	$3C, $42, $42, $3E, $02, $04, $38, $ff	; (9)
	.db	$00, $10, $10, $00, $00, $10, $10, $00	; (:)
	.db	$00, $10, $10, $00, $00, $10, $10, $20	; (;)
	.db	$08, $10, $20, $40, $20, $10, $08, $00	; (<)
	.db	$00, $00, $7E, $00, $00, $7E, $00, $00	; (=)
	.db	$10, $08, $04, $02, $04, $08, $10, $00	; (>)
	.db	$3C, $42, $02, $04, $08, $00, $08, $00	; (?)
	.db	$3C, $42, $5E, $52, $5E, $40, $3C, $00	; (@)
	.db	$18, $24, $42, $42, $7E, $42, $42, $00	; (A)
	.db	$7C, $22, $22, $3C, $22, $22, $7C, $00	; (B)
	.db	$1C, $22, $40, $40, $40, $22, $1C, $00	; (C)
	.db	$78, $24, $22, $22, $22, $24, $78, $00	; (D)
	.db	$7E, $22, $28, $38, $28, $22, $7E, $00	; (E)
	.db	$7E, $22, $28, $38, $28, $20, $70, $00	; (F)
	.db	$1C, $22, $40, $40, $4E, $22, $1E, $00	; (G)
	.db	$42, $42, $42, $7E, $42, $42, $42, $00	; (H)
	.db	$38, $10, $10, $10, $10, $10, $38, $00	; (I)
	.db	$0E, $04, $04, $04, $44, $44, $38, $00	; (J)
	.db	$62, $24, $28, $30, $28, $24, $63, $00	; (K)
	.db	$70, $20, $20, $20, $20, $22, $7E, $00	; (L)
	.db	$63, $55, $49, $41, $41, $41, $41, $00	; (M)
	.db	$62, $52, $4A, $46, $42, $42, $42, $00	; (N)
	.db	$3C, $42, $42, $42, $42, $42, $3C, $00	; (O)
	.db	$7C, $22, $22, $3C, $20, $20, $70, $00	; (P)
	.db	$3C, $42, $42, $42, $4A, $3C, $03, $00	; (Q)
	.db	$7C, $22, $22, $3C, $28, $24, $72, $00	; (R)
	.db	$3C, $42, $40, $3C, $02, $42, $3C, $00	; (S)
	.db	$7F, $49, $08, $08, $08, $08, $1C, $00	; (T)
	.db	$42, $42, $42, $42, $42, $42, $3C, $00	; (U)
	.db	$41, $41, $41, $41, $22, $14, $08, $00	; (V)
	.db	$41, $41, $41, $49, $49, $49, $36, $00	; (W)
	.db	$41, $22, $14, $08, $14, $22, $41, $00	; (X)
	.db	$41, $22, $14, $08, $08, $08, $1C, $00	; (Y)
	.db	$7F, $42, $04, $08, $10, $21, $7F, $00	; (Z)
	.db	$78, $40, $40, $40, $40, $40, $78, $00	; ([)
	.db	$80, $40, $20, $10, $08, $04, $02, $00	; (\)
	.db	$78, $08, $08, $08, $08, $08, $78, $00	; (])
	.db	$10, $28, $44, $82, $00, $00, $00, $00	; (^)
	.db	$00, $00, $00, $00, $00, $00, $00, $FF	; (_)
	.db	$10, $10, $08, $00, $00, $00, $00, $00	; (`)
	.db	$00, $00, $3C, $02, $3E, $42, $3F, $00	; (a)
	.db	$60, $20, $20, $2E, $31, $31, $2E, $00	; (b)
	.db	$00, $00, $3C, $42, $40, $42, $3C, $00	; (c)
	.db	$06, $02, $02, $3A, $46, $46, $3B, $00	; (d)
	.db	$00, $00, $3C, $42, $7E, $40, $3C, $00	; (e)
	.db	$0C, $12, $10, $38, $10, $10, $38, $00	; (f)
	.db	$00, $00, $3D, $42, $42, $3E, $02, $7C	; (g)
	.db	$60, $20, $2C, $32, $22, $22, $62, $00	; (h)
	.db	$10, $00, $30, $10, $10, $10, $38, $00	; (i)
	.db	$02, $00, $06, $02, $02, $42, $42, $3C	; (j)
	.db	$60, $20, $24, $28, $30, $28, $26, $00	; (k)
	.db	$30, $10, $10, $10, $10, $10, $38, $00	; (l)
	.db	$00, $00, $76, $49, $49, $49, $49, $00	; (m)
	.db	$00, $00, $5C, $62, $42, $42, $42, $00	; (n)
	.db	$00, $00, $3C, $42, $42, $42, $3C, $00	; (o)
	.db	$00, $00, $6C, $32, $32, $2C, $20, $70	; (p)
	.db	$00, $00, $36, $4C, $4C, $34, $04, $0E	; (q)
	.db	$00, $00, $6C, $32, $22, $20, $70, $00	; (r)
	.db	$00, $00, $3E, $40, $3C, $02, $7C, $00	; (s)
	.db	$10, $10, $7C, $10, $10, $12, $0C, $00	; (t)
	.db	$00, $00, $42, $42, $42, $46, $3A, $00	; (u)
	.db	$00, $00, $41, $41, $22, $14, $08, $00	; (v)
	.db	$00, $00, $41, $49, $49, $49, $36, $00	; (w)
	.db	$00, $00, $44, $28, $10, $28, $44, $00	; (x)
	.db	$00, $00, $42, $42, $42, $3E, $02, $7C	; (y)
	.db	$00, $00, $7C, $08, $10, $20, $7C, $00	; (z)
	.db	$0C, $10, $10, $60, $10, $10, $0C, $00	; ({)
	.db	$10, $10, $10, $00, $10, $10, $10, $00	; (|)
	.db	$30, $08, $08, $06, $08, $08, $30, $00	; (})
	.db	$32, $4C, $00, $00, $00, $00, $00, $00	; (~)
	.db	$00, $08, $14, $22, $41, $41, $7F, $00	; (.)
	.db	$3C, $42, $40, $42, $3C, $0C, $02, $3C	; (.)
	.db	$00, $44, $00, $44, $44, $44, $3E, $00	; (.)
	.db	$0C, $00, $3C, $42, $7E, $40, $3C, $00	; (.)
	.db	$3C, $42, $38, $04, $3C, $44, $3E, $00	; (.)
	.db	$42, $00, $38, $04, $3C, $44, $3E, $00	; (.)
	.db	$30, $00, $38, $04, $3C, $44, $3E, $00	; (.)
	.db	$10, $00, $38, $04, $3C, $44, $3E, $00	; (.)
	.db	$00, $00, $3C, $40, $40, $3C, $06, $1C	; (.)
	.db	$3C, $42, $3C, $42, $7E, $40, $3C, $00	; (.)
	.db	$42, $00, $3C, $42, $7E, $40, $3C, $00	; (.)
	.db	$30, $00, $3C, $42, $7E, $40, $3C, $00	; (.)
	.db	$24, $00, $18, $08, $08, $08, $1C, $00	; (.)
	.db	$7C, $82, $30, $10, $10, $10, $38, $00	; (.)
	.db	$30, $00, $18, $08, $08, $08, $1C, $00	; (.)
	.db	$42, $18, $24, $42, $7E, $42, $42, $00	; (.)
	.db	$18, $18, $00, $3C, $42, $7E, $42, $00	; (.)
	.db	$0C, $00, $7C, $20, $38, $20, $7C, $00	; (.)
	.db	$00, $00, $33, $0C, $3F, $44, $3B, $00	; (.)
	.db	$1F, $24, $44, $7F, $44, $44, $47, $00	; (.)
	.db	$18, $24, $00, $3C, $42, $42, $3C, $00	; (.)
	.db	$00, $42, $00, $3C, $42, $42, $3C, $00	; (.)
	.db	$20, $10, $00, $3C, $42, $42, $3C, $00	; (.)
	.db	$18, $24, $00, $42, $42, $42, $3C, $00	; (.)
	.db	$20, $10, $00, $42, $42, $42, $3C, $00	; (.)
	.db	$00, $42, $00, $42, $42, $3E, $02, $3C	; (.)
	.db	$42, $18, $24, $42, $42, $24, $18, $00	; (.)
	.db	$42, $00, $42, $42, $42, $42, $3C, $00	; (.)
	.db	$08, $08, $3E, $40, $40, $3E, $08, $08	; (.)
	.db	$18, $24, $20, $70, $20, $42, $7C, $00	; (.)
	.db	$44, $28, $7C, $10, $7C, $10, $10, $00	; (.)
	.db	$F8, $4C, $78, $44, $4F, $44, $45, $E6	; (.)
	.db	$1C, $12, $10, $7C, $10, $10, $90, $60	; (.)
	.db	$0C, $00, $38, $04, $3C, $44, $3E, $00	; (.)
	.db	$0C, $00, $18, $08, $08, $08, $1C, $00	; (.)
	.db	$04, $08, $00, $3C, $42, $42, $3C, $00	; (.)
	.db	$00, $04, $08, $42, $42, $42, $3C, $00	; (.)
	.db	$32, $4C, $00, $7C, $42, $42, $42, $00	; (.)
	.db	$32, $4C, $00, $62, $52, $4A, $46, $00	; (.)
	.db	$3C, $44, $44, $3E, $00, $7E, $00, $00	; (.)
	.db	$38, $44, $44, $38, $00, $7C, $00, $00	; (.)
	.db	$10, $00, $10, $20, $40, $42, $3C, $00	; (.)
	.db	$00, $00, $00, $7E, $40, $40, $00, $00	; (.)
	.db	$00, $00, $00, $7E, $02, $02, $00, $00	; (.)
	.db	$42, $C4, $48, $F6, $29, $43, $8C, $1F	; (.)
	.db	$42, $C4, $4A, $F6, $2A, $5F, $82, $02	; (.)
	.db	$00, $10, $00, $10, $10, $10, $10, $00	; (.)
	.db	$00, $12, $24, $48, $24, $12, $00, $00	; (.)
	.db	$00, $48, $24, $12, $24, $48, $00, $00	; (.)
	.db	$22, $88, $22, $88, $22, $88, $22, $88	; (.)
	.db	$55, $AA, $55, $AA, $55, $AA, $55, $AA	; (.)
	.db	$DB, $77, $DB, $EE, $DB, $77, $DB, $EE	; (.)
	.db	$10, $10, $10, $10, $10, $10, $10, $10	; (.)
	.db	$10, $10, $10, $10, $F0, $10, $10, $10	; (.)
	.db	$10, $10, $F0, $10, $F0, $10, $10, $10	; (.)
	.db	$14, $14, $14, $14, $F4, $14, $14, $14	; (.)
	.db	$00, $00, $00, $00, $FC, $14, $14, $14	; (.)
	.db	$00, $00, $F0, $10, $F0, $10, $10, $10	; (.)
	.db	$14, $14, $F4, $04, $F4, $14, $14, $14	; (.)
	.db	$14, $14, $14, $14, $14, $14, $14, $14	; (.)
	.db	$00, $00, $FC, $04, $F4, $14, $14, $14	; (.)
	.db	$14, $14, $F4, $04, $FC, $00, $00, $00	; (.)
	.db	$14, $14, $14, $14, $FC, $00, $00, $00	; (.)
	.db	$10, $10, $F0, $10, $F0, $00, $00, $00	; (.)
	.db	$00, $00, $00, $00, $F0, $10, $10, $10	; (.)
	.db	$10, $10, $10, $10, $1F, $00, $00, $00	; (.)
	.db	$10, $10, $10, $10, $FF, $00, $00, $00	; (.)
	.db	$00, $00, $00, $00, $FF, $10, $10, $10	; (.)
	.db	$10, $10, $10, $10, $1F, $10, $10, $10	; (.)
	.db	$00, $00, $00, $00, $FF, $00, $00, $00	; (.)
	.db	$10, $10, $10, $10, $FF, $10, $10, $10	; (.)
	.db	$10, $10, $1F, $10, $1F, $10, $10, $10	; (.)
	.db	$14, $14, $14, $14, $17, $14, $14, $14	; (.)
	.db	$14, $14, $17, $10, $1F, $00, $00, $00	; (.)
	.db	$00, $00, $1F, $10, $17, $14, $14, $14	; (.)
	.db	$14, $14, $F7, $00, $FF, $00, $00, $00	; (.)
	.db	$00, $00, $FF, $00, $F7, $14, $14, $14	; (.)
	.db	$14, $14, $17, $10, $17, $14, $14, $14	; (.)
	.db	$00, $00, $FF, $00, $FF, $00, $00, $00	; (.)
	.db	$14, $14, $F7, $00, $F7, $14, $14, $14	; (.)
	.db	$10, $10, $FF, $00, $FF, $00, $00, $00	; (.)
	.db	$14, $14, $14, $14, $FF, $00, $00, $00	; (.)
	.db	$00, $00, $FF, $00, $FF, $10, $10, $10	; (.)
	.db	$00, $00, $00, $00, $FF, $14, $14, $14	; (.)
	.db	$14, $14, $14, $14, $1F, $00, $00, $00	; (.)
	.db	$10, $10, $1F, $10, $1F, $00, $00, $00	; (.)
	.db	$00, $00, $1F, $10, $1F, $10, $10, $10	; (.)
	.db	$00, $00, $00, $00, $1F, $14, $14, $14	; (.)
	.db	$14, $14, $14, $14, $FF, $14, $14, $14	; (.)
	.db	$10, $10, $FF, $10, $FF, $10, $10, $10	; (.)
	.db	$10, $10, $10, $10, $F0, $00, $00, $00	; (.)
	.db	$00, $00, $00, $00, $1F, $10, $10, $10	; (.)
	.db	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	; (.)
	.db	$00, $00, $00, $00, $FF, $FF, $FF, $FF	; (.)
	.db	$F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0	; (.)
	.db	$0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F	; (.)
	.db	$FF, $FF, $FF, $FF, $00, $00, $00, $00	; (.)
	.db	$00, $00, $31, $4A, $44, $4A, $31, $00	; (.)
	.db	$00, $3C, $42, $7C, $42, $7C, $40, $40	; (.)
	.db	$00, $7E, $42, $40, $40, $40, $40, $00	; (.)
	.db	$00, $3F, $54, $14, $14, $14, $14, $00	; (.)
	.db	$7E, $42, $20, $18, $20, $42, $7E, $00	; (.)
	.db	$00, $00, $3E, $48, $48, $48, $30, $00	; (.)
	.db	$00, $44, $44, $44, $7A, $40, $40, $80	; (.)
	.db	$00, $33, $4C, $08, $08, $08, $08, $00	; (.)
	.db	$7C, $10, $38, $44, $44, $38, $10, $7C	; (.)
	.db	$18, $24, $42, $7E, $42, $24, $18, $00	; (.)
	.db	$18, $24, $42, $42, $24, $24, $66, $00	; (.)
	.db	$1C, $20, $18, $3C, $42, $42, $3C, $00	; (.)
	.db	$00, $62, $95, $89, $95, $62, $00, $00	; (.)
	.db	$02, $04, $3C, $4A, $52, $3C, $40, $80	; (.)
	.db	$0C, $10, $20, $3C, $20, $10, $0C, $00	; (.)
	.db	$3C, $42, $42, $42, $42, $42, $42, $00	; (.)
	.db	$00, $7E, $00, $7E, $00, $7E, $00, $00	; (.)
	.db	$10, $10, $7C, $10, $10, $00, $7C, $00	; (.)
	.db	$10, $08, $04, $08, $10, $00, $7E, $00	; (.)
	.db	$08, $10, $20, $10, $08, $00, $7E, $00	; (.)
	.db	$0C, $12, $12, $10, $10, $10, $10, $10	; (.)
	.db	$10, $10, $10, $10, $10, $90, $90, $60	; (.)
	.db	$18, $18, $00, $7E, $00, $18, $18, $00	; (.)
	.db	$00, $32, $4C, $00, $32, $4C, $00, $00	; (.)
	.db	$30, $48, $48, $30, $00, $00, $00, $00	; (.)
	.db	$00, $00, $00, $18, $18, $00, $00, $00	; (.)
	.db	$00, $00, $00, $00, $18, $00, $00, $00	; (.)
	.db	$0F, $08, $08, $08, $08, $C8, $28, $18	; (.)
	.db	$78, $44, $44, $44, $44, $00, $00, $00	; (.)
	.db	$30, $48, $10, $20, $78, $00, $00, $00	; (.)
	.db	$00, $00, $3C, $3C, $3C, $3C, $00, $00	; (.)
	.db	$00, $00, $00, $00, $00, $00, $00, $00	; (.)


.END
