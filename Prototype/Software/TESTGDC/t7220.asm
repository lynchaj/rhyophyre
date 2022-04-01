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
	LD 	A,0		;
	CALL 	ramdac_set_read_mask	;    ramdac_set_read_mask(0x0F)
	LD	A,0
	CALL 	ramdac_overlay	;   ramdac_overlay(0)

	LD	A,1
	CALL	gdc_init	;

	LD	DE,MSG_INIT	;
	LD	C,09H		; CP/M WRITE END STRING TO CONSOLE CALL
	CALL	0005H 		;

	LD	DE,MSG_GCHAR	;
	LD	C,09H		; CP/M WRITE END STRING TO CONSOLE CALL
	CALL	0005H 		;

    	CALL 	gchar_test	;


;	CALL	INIT7220	;

	LD	DE,MSG_END	;
	LD	C,09H		; CP/M WRITE END STRING TO CONSOLE CALL
	CALL	0005H 		;

	LD	C,00H		; CP/M SYSTEM RESET CALL
	CALL	0005H 		; RETURN TO PROMPT

;SYNCP: 	.DB		012H,026H,045H,000H,002H,00AH,0E0H,085H
SYNCP: 	.DB	012H,026H,044H,004H,002H,00AH,0E0H,085H  ;;VERIFY THESE NUMBERS
CCHARP:	.DB	000H,000H,000H
PITCHP:	.DB	028H   ;;VERIFY THESE NUMBERS
PRAMP:	.DB	000H,000H,000H,0E0H,001H,000H,000H
ZOOMP:	.DB	000H   VERIFY THESE NUMBERS
CURSP:	.DB	000H,000H,000H
PATTERN:	.DW	0FFFFH

CHPATTERN: .DB	0ffH, 09fH, 087H, 08bH,093H, 0a3H, 083H, 0ffH


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
	CALL	PRINTCRLF
	; ********* SYNC
	POP 	AF
	OR	SYNC		; DO SYNC (0x0E if blanked 0x0F if enabled)
	CALL	OUTA		; SEND COMMAND
	LD	C,8		; NUMBER PARMS
	LD	HL,SYNCP	; PARM TABLE
	CALL	OUTC		; SEND PARMS
	CALL	PRINTCRLF
	; ********* VSYNC
	LD	A,VSYNC		; DO VSYNC
	CALL	OUTA		; SEND COMMAND
	CALL	PRINTCRLF
	; ********* PITCH
      	LD	A,PITCH		; DO PITCH
	CALL	OUTA		; SEND COMMAND
	LD	HL,PITCHP	; PARM TABLE
	LD	C,01H		; NUMBER PARAMS
	CALL	OUTC
	CALL	PRINTCRLF
	; ********* PRAM 1
	LD	HL,PRAMP	; PARM TABLE
	LD	C,7		; NUMBER PARAMS
	LD 	A,0		; START ADDRESS
    	CALL	gdc_pram	; graphic area 1
	CALL	PRINTCRLF
	; ********* PRAM 2
    	LD	HL,PRAMP	; PARM TABLE
	LD	C,7		; NUMBER PARAMS
	LD 	A,7		; START ADDRESS
    	CALL	gdc_pram	; graphic area 2
	CALL	PRINTCRLF
	; ********* PATTERN
    	LD	HL,PATTERN	; PARM TABLE
	LD	C,2		; NUMBER PARAMS
	LD 	A,8		; START ADDRESS
    	CALL	gdc_pram	; graphic area 2
	CALL	PRINTCRLF
	; ********* ZOOM DISPLAY (FACTOR 1)
	LD 	A,0
	CALL 	gdc_zoom_display
	CALL	PRINTCRLF
	; ********* SET CURSOR
	LD 	HL,0000H
	LD 	A,0H
	CALL 	gdc_setcursor
	CALL	PRINTCRLF
	; ********* SET MODE
	LD 	A,GDC_REPLACE
	CALL 	gdc_mode
	CALL	PRINTCRLF
	; ********* START
      	LD	A,START		; DO START
	CALL	OUTA		; SEND COMMAND
	CALL	PRINTCRLF
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

INIT7220:
	; ********* RESET
	LD	A,RESET		; DO RESET
	CALL	OUTA		; SEND COMMAND
	; ********* SYNC
	LD	A,SYNC		; DO SYNC
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
	; ********* PRAM
      	LD	A,PRAM		; DO PRAM
	CALL	OUTA		; SEND COMMAND
	LD	HL,PRAMP	; PARM TABLE
	LD	C,10H		; NUMBER PARAMS
	CALL	OUTC
	; ********* ZOOM
      	LD	A,ZOOM		; DO ZOOM
	CALL	OUTA		; SEND COMMAND
	LD	HL,ZOOMP	; PARM TABLE
	LD	C,01H		; NUMBER PARAMS
	CALL	OUTC
	; ********* CURS
      	LD	A,CURS		; DO CURS
	CALL	OUTA		; SEND COMMAND
	LD	HL,CURSP	; PARM TABLE
	LD	C,03H		; NUMBER PARAMS
	CALL	OUTC
	; ********* START
      	LD	A,START		; DO START
	CALL	OUTA		; SEND COMMAND

	RET

gchar_test:

;  	 x x x x x x x x
;        x     x x x x x
;        x         x x x
;        x       x   x x
;        x     x     x x
;        x   x       x x
;        x           x x
;        x x x x x x x x


	; ********* ZOOM  	gdc_zoom_draw(2);
      	LD	A,ZOOM		; DO ZOOM
	CALL	OUTA		; SEND COMMAND
	LD	A,1
	CALL	OUTP
	CALL	PRINTCRLF

    	LD	HL,CHPATTERN	; PARM TABLE
	LD	C,8		; NUMBER PARAMS
	LD 	A,8		; START ADDRESS
    	CALL	gdc_pram	; graphic area 2
	CALL	PRINTCRLF

      	LD	A,CURS		; DO CURS
	CALL	OUTA		; SEND COMMAND
	LD	A,100
	CALL 	OUTP
	LD	A,1
	CALL 	OUTP
	LD	A,10
	CALL 	OUTP
	CALL	PRINTCRLF

	; ********* SET MODE
	LD 	A,GDC_REPLACE
	CALL 	gdc_mode
	CALL	PRINTCRLF


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
	CALL	PRINTCRLF

      	LD	A,068H		; DO GCHRD
	CALL	OUTA		; SEND COMMAND
	CALL	PRINTCRLF

  	; ********* ZOOM  	gdc_zoom_draw(1);
      	LD	A,ZOOM		; DO ZOOM
	CALL	OUTA		; SEND COMMAND
	LD	A,1
	CALL	OUTP
	CALL	PRINTCRLF

	; ********* START
;      	LD	A,START		; DO START
;	CALL	OUTA		; SEND COMMAND
;	CALL	PRINTCRLF
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
	call 	HXOUT
	call 	PRINTC
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
	call 	HXOUT
	call 	PRINTP
	RET


OUTC:
  	IN	A,(gdc_status)	; READ STATUS
	AND	00001010B  	; IS READY?
	JP	NZ,OUTC		; NO,LOOP
	LD	A,(HL)		; GET GDC PARM

	PUSH 	HL
	call 	HXOUT
	call 	PRINTP
	POP 	HL

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
	PUSH	AF			; STORE AF
	LD	A,10			;
	CALL	COUT			; SCREEN IT
	LD	A,13			;
	CALL	COUT			; SCREEN IT

	POP	AF			; RESTORE AF
	RET
















.END
