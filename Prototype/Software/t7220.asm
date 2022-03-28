;__T7220_______________________________________________________________________________________________________________________
;
;		TEST 7220 0PROGRAM
;		AUTHOR: DAN WERNER -- 7/24/2010
;________________________________________________________________________________________________________________________________
;

; DATA CONSTANTS
;________________________________________________________________________________________________________________________________
;REGISTER			    IO PORT				  ; FUNCTION
gdc_status: 	       	.equ	090H
gdc_command: 		.equ	091H
gdc_param: 		.equ	090H
gdc_read: 		.equ	091H
ramdac_latch: 		.equ	094H
ramdac_base: 		.equ	098H

ramdac_address_wr:	.equ (ramdac_base+0)
ramdac_address_rd:	.equ (ramdac_base+3)
ramdac_palette_ram:	.equ (ramdac_base+1)
ramdac_pixel_read_mask:	.equ (ramdac_base+2)

ramdac_overlay_wr:	.equ (ramdac_base+4)
ramdac_overlay_rd:	.equ (ramdac_base+7)
ramdac_overlay_ram:	.equ (ramdac_base+5)
ramdac_do_not_use:	.equ  (ramdac_base+6)


BS:			.EQU    008H	; ASCII backspace character
CR:			.EQU    00DH	; CARRIAGE RETURN CHARACTER
LF:			.EQU	00AH	; LINE FEED CHARACTER
END:			.EQU	'$' 	; LINE TERMINATOR FOR CP/M STRINGS

;
; commands:
;
RESET			.equ	000H
SYNC	 		.equ	00FH
VSYNC  			.equ	06FH
CCHAR  			.equ	04BH
START			.equ	06BH
ZOOM   			.equ	046H
CURS	 		.equ	049H
PRAM   			.equ	070H
PITCH	 		.equ	047H


;________________________________________________________________________________________________________________________________
; MAIN PROGRAM BEGINS HERE
;________________________________________________________________________________________________________________________________
		.ORG	$0100

		LD	DE,MSG_START	;
		LD	C,09H		;
		CALL	0005H 		;

		CALL	INIT7220	;


		LD	DE,MSG_END	;
		LD	C,09H		; CP/M WRITE END STRING TO CONSOLE CALL
		CALL	0005H 		;
										;
		LD	C,00H		; CP/M SYSTEM RESET CALL
		CALL	0005H 		; RETURN TO PROMPT

;SYNCP: 	.DB		012H,026H,045H,000H,002H,00AH,0E0H,085H
SYNCP: 	.DB		012H,026H,044H,004H,002H,00AH,0E0H,085H
CCHARP:	.DB		000H,000H,000H
PITCHP:	.DB		028H
PRAMP:	.DB		000H,000H,000H,059H,000H,000H,000H,059H,0FFH,0FFH
ZOOMP:	.DB		000H
CURSP:	.DB		000H,000H,000H


;
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


OUTA:	  	PUSH	AF		; STORE REGISTERS
OUTALOOP:	IN	A,(gdc_status) 	; READ STATUS
		AND	00001010B	; IS READY?
		JP	NZ,OUTALOOP	; NO, LOOP
		POP	AF		; YES, RESTORE GDC COMMAND
		OUT	(gdc_command),A	; FIFO GDC command
		RET

OUTC:	  	IN	A,(gdc_status)	; READ STATUS
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

		.END
