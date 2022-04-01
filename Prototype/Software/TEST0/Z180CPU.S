;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; z180cpu.s -- define I/O registers on the Z180 cpu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  SDCC 3.0.0
;
; Copyright (C) 2013 John R. Coffman.  All rights reserved.
; Provided for hobbyist use on the N8VEM SBC Mark IV board.
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
; z180cpu.s
;
; define I/O registers on the Z180 cpu
;
Z8S180	= 1
;	hd64
; The following Z8S180= option must be set:
;       0       Z80180
;       1       Z8S180 or Z8L180

Z180_IO_BASE      =       0x0040          ; relocation of 64 (0x40) registers

;       ASCI registers
ASCI    =       Z180_IO_BASE

cntla0  =    ASCI + 0x00    ; control register A, channel 0     p. 293
cntla1  =    ASCI + 0x01    ;       channel 1
cntlb0  =    ASCI + 0x02    ; control register B, channel 0
cntlb1  =    ASCI + 0x03    ;       channel 1
stat0   =    ASCI + 0x04    ; status channel 0
stat1   =    ASCI + 0x05    ;       channel 1
tdr0    =    ASCI + 0x06    ; transmit data register channel 0
tdr1    =    ASCI + 0x07    ;       channel 1                   
rdr0    =    ASCI + 0x08    ; receive data register channel 0
rdr1    =    ASCI + 0x09    ;       channel 1
.if   Z8S180
asext0  =    ASCI + 0x12    ; ASCI extension control register 0
asext1  =    ASCI + 0x13    ; ASCI extension control register 1
astc0l  =    ASCI + 0x1A    ; time constant low register ch. 0
astc0h  =    ASCI + 0x1B    ; time constant high register ch. 0
astc1l  =    ASCI + 0x1C    ; time constant low register ch. 1
astc1h  =    ASCI + 0x1D    ; time constant high register ch. 1
.endif

;       CSI/O registers
CSIO    =       Z180_IO_BASE

cntr    =    CSIO + 0x0A    ; CSI/O control register            p. 296
trdr    =    CSIO + 0x0B    ; transmit/receive data register

;       Timer registers
TIMR    =       Z180_IO_BASE

tmdr0l  =    TIMR + 0x0C    ; timer data channel 0 low
tmdr0h  =    TIMR + 0x0D    ;       channel 0 high
rldr0l  =    TIMR + 0x0E    ; timer reload channel 0 low
rldr0h  =    TIMR + 0x0F    ;       channel 0 high
tcr     =    TIMR + 0x10    ; timer control register channel 0 low
tmdr1l  =    TIMR + 0x14    ; timer data channel 1 low
tmdr1h  =    TIMR + 0x15    ;       channel 1 high
rldr1l  =    TIMR + 0x16    ; timer reload channel 1 low
rldr1h  =    TIMR + 0x17    ;       channel 1 high

frc     =    TIMR + 0x18    ; free running counter (read only)
.if  Z8S180
cmr     =    TIMR + 0x1E    ; Clock multiplier register
ccr     =    TIMR + 0x1F    ; CPU control register
.endif

;       DMA registers
DMA     =       Z180_IO_BASE

sar0l   =     DMA + 0x20    ; source address channel 0 low
sar0h   =     DMA + 0x21    ;       channel 0 high
sar0b   =     DMA + 0x22    ; source address channel 0 B
dar0l   =     DMA + 0x23    ; destination address channel 0 low
dar0h   =     DMA + 0x24    ;       channel 0 high
dar0b   =     DMA + 0x25    ;       channel 0 B
bcr0l   =     DMA + 0x26    ; byte count channel 0 low
bcr0h   =     DMA + 0x27    ;       channel 0 high
mar1l   =     DMA + 0x28    ; memory address channel 1 low
mar1h   =     DMA + 0x29    ;       channel 1 high
mar1b   =     DMA + 0x2A    ;       channel 1 B
iar1l   =     DMA + 0x2B    ; I/O address register channel 1 low
iar1h   =     DMA + 0x2C    ;       channel 1 high
.if  Z8S180
iar1b   =     DMA + 0x2D    ;       channel 1 B
.endif
bcr1l   =     DMA + 0x2E    ; byte count channel 1 low
bcr1h   =     DMA + 0x2F    ;       channel 1 high
dstat   =     DMA + 0x30    ; DMA status register
dmode   =     DMA + 0x31    ; DMA mode register             p. 299
dcntl   =     DMA + 0x32    ; DMA/WAIT control register

;       MMU registers
MMU     =       Z180_IO_BASE

cbr     =     MMU + 0x38    ; common base register
bbr     =     MMU + 0x39    ; bank base register
cbar    =     MMU + 0x3A    ; common/bank register

;       MISCELLANEOUS registers
MISC    =       Z180_IO_BASE

il      =    MISC + 0x33    ; interrupt vector low reg.
itc     =    MISC + 0x34    ; INT/TRAP control
rcr     =    MISC + 0x36    ; refresh control register      p. 302
omcr    =    MISC + 0x3E    ; operation mode control       p. 300
icr     =           0x3F    ; I/O base control register


; END z180cpu.s

