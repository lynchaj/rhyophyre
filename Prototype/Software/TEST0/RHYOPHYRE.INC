;/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  rhyophyre.inc -- Z180 SBC RHYOPHYRE device definitions
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

ACR_STATUS = 0x20

dev_Rhyophyre_board = 0x80

dev_acr  = dev_Rhyophyre_board + 0x0
dev_rtc  = dev_Rhyophyre_board + 0x4

; items below are fake for now to keep the code compiling

dev_ide		=	dev_Rhyophyre_board + 0x0
dev_ide1	=	dev_Rhyophyre_board + 0x8	; +6 or +7 required

dev_xmem	=	dev_Rhyophyre_board + 8
dev_sd		=	dev_Rhyophyre_board + 0x9
dev_rtc		=	dev_Rhyophyre_board + 0xA

; end mark4.s
.if 0	     			; */

#define ACR_STATUS 0x20

#define  dev_Rhyophyre_board 0x80

#define  dev_acr  dev_Rhyophyre_board + 0
#define  dev_rtc  dev_Rhyophyre_board + 4
				/*
.endif

; end  mark4.inc    */
