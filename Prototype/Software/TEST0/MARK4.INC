;/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  mark4.inc -- Z180 SBC Mark IV device definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Copyright (C) 2013,2014 John R. Coffman.  All rights reserved.
;   Provided for hobbyist use on the Z180 SBC Mark IV board.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dev_MarkIV_board =	0x80		; jumper settings (P10)

dev_ide		=	dev_MarkIV_board + 0x0
dev_ide1	=	dev_MarkIV_board + 0x8	; +6 or +7 required

dev_xmem	=	dev_MarkIV_board + 8
dev_sd		=	dev_MarkIV_board + 0x9
dev_rtc		=	dev_MarkIV_board + 0xA

; end mark4.s
.if 0	     			; */
#define  dev_MarkIV_board  0x80

#define dev_ide  dev_MarkIV_board+0
#define dev_ide1 dev_MarkIV_board+8
#define dev_xmem dev_MarkIV_board+8
#define dev_sd   dev_MarkIV_board+9
#define dev_rtc  dev_MarkIV_board+10
				/*
.endif

; end  mark4.inc    */
