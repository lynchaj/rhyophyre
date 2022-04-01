/* -------------------------------------------------------------------------
   z180.h - definitions on the built in I/O ports for the Z180/HD64180
            for use with SDCC

   Updated for the Z8S180 19-Apr-2011 John R. Coffman <johninsd AT gmail.com>

   Copyright (C) 2003, Peter Townson <Peter.Townson AT tattsgroup.com>

   This library is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2.1, or (at your option) any
   later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License 
   along with this library; see the file COPYING. If not, write to the
   Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.

   As a special exception, if you link this library with other files,
   some of which are compiled with SDCC, to produce an executable,
   this library does not by itself cause the resulting executable to
   be covered by the GNU General Public License. This exception does
   not however invalidate any other reasons why the executable file
   might be covered by the GNU General Public License.
------------------------------------------------------------------------- */

#if !defined( __Z180_H__ )
    #define   __Z180_H__ 

#if !defined( Z180_IO_BASE )
    #define   Z180_IO_BASE  0x0040  /* zero is the Reset default */
#endif
#if !defined( Z8S180 )
   #define    Z8S180        1  /* extra registers */
#endif

/* will want this to be the case by default (I think) */
#pragma portmode z180

static void _ENABLE_Z180_ASSEMBLER_(void) __naked { __asm .hd64 __endasm; }

#ifdef __SDCC__

/*
 *---------------------------------------------------------------------------
 *      Z180/HD64180 internal port addresses                   P. 48
 */
__sfr __at (Z180_IO_BASE+0x00) CNTLA0;  /* ASCI control register A channel 0 */
__sfr __at (Z180_IO_BASE+0x01) CNTLA1;  /* ASCI control register A channel 1 */
__sfr __at (Z180_IO_BASE+0x02) CNTLB0;  /* ASCI control register B channel 0 */
__sfr __at (Z180_IO_BASE+0x03) CNTLB1;  /* ASCI control register B channel 0 */
__sfr __at (Z180_IO_BASE+0x04) STAT0 ;  /* ASCI status register    channel 0 */
__sfr __at (Z180_IO_BASE+0x05) STAT1 ;  /* ASCI status register    channel 1 */
__sfr __at (Z180_IO_BASE+0x06) TDR0  ;  /* ASCI transmit data reg, channel 0 */
__sfr __at (Z180_IO_BASE+0x07) TDR1  ;  /* ASCI transmit data reg, channel 1 */
__sfr __at (Z180_IO_BASE+0x08) RDR0  ;  /* ASCI receive data reg,  channel 0 */
__sfr __at (Z180_IO_BASE+0x09) RDR1  ;  /* ASCI receive data reg,  channel 0 */
#if Z8S180
__sfr __at (Z180_IO_BASE+0x12) ASEXT0;  /* ASCI extension control register    p.135 */
__sfr __at (Z180_IO_BASE+0x13) ASEXT1;  /* ASCI extension control register    */
__sfr __at (Z180_IO_BASE+0x1A) ASTC0L;  /* ASCI0 time constant low register    p.137 */
__sfr __at (Z180_IO_BASE+0x1B) ASTC0H;  /* ASCI0 time constant high register    */
__sfr __at (Z180_IO_BASE+0x1C) ASTC1L;  /* ASCI0 time constant low register    p.138 */
__sfr __at (Z180_IO_BASE+0x1D) ASTC1H;  /* ASCI0 time constant high register    */
#endif
__sfr __at (Z180_IO_BASE+0x0A) CNTR  ;  /* CSI/0 control register */
__sfr __at (Z180_IO_BASE+0x0B) TRDR  ;  /* CSI/0 transmit/receive data reg */

__sfr __at (Z180_IO_BASE+0x0C) TMDR0L;  /* Timer data register,    channel 0L */
__sfr __at (Z180_IO_BASE+0x0D) TMDR0H;  /* Timer data register,    channel 0H */
__sfr __at (Z180_IO_BASE+0x0E) RLDR0L;  /* Timer reload register,  channel 0L */
__sfr __at (Z180_IO_BASE+0x0F) RLDR0H;  /* Timer reload register,  channel 0H */
__sfr __at (Z180_IO_BASE+0x10) TCR   ;  /* Timer control register */
__sfr __at (Z180_IO_BASE+0x14) TMDR1L;  /* Timer data register,    channel 1L */
__sfr __at (Z180_IO_BASE+0x15) TMDR1H;  /* Timer data register,    channel 1H */
__sfr __at (Z180_IO_BASE+0x16) RLDR1L;  /* Timer reload register,  channel 1L */
__sfr __at (Z180_IO_BASE+0x17) RLDR1H;  /* Timer reload register,  channel 1H */

__sfr __at (Z180_IO_BASE+0x18) FRC   ;  /* Timer Free running counter */
#if Z8S180
__sfr __at (Z180_IO_BASE+0x1E) CMR   ;  /* Clock multiplier register  */
__sfr __at (Z180_IO_BASE+0x1F) CCR   ;  /* CPU control register       */
#endif

__sfr __at (Z180_IO_BASE+0x20) SAR0L ;  /* DMA source address reg, channel 0L */
__sfr __at (Z180_IO_BASE+0x21) SAR0H ;  /* DMA source address reg, channel 0H */
__sfr __at (Z180_IO_BASE+0x22) SAR0B ;  /* DMA source address reg, channel 0B */
__sfr __at (Z180_IO_BASE+0x23) DAR0L ;  /* DMA dest address reg,   channel 0L */
__sfr __at (Z180_IO_BASE+0x24) DAR0H ;  /* DMA dest address reg,   channel 0H */
__sfr __at (Z180_IO_BASE+0x25) DAR0B ;  /* DMA dest address reg,   channel 0B */
__sfr __at (Z180_IO_BASE+0x26) BCR0L ;  /* DMA byte count reg,     channel 0L */
__sfr __at (Z180_IO_BASE+0x27) BCR0H ;  /* DMA byte count reg,     channel 0H */
__sfr __at (Z180_IO_BASE+0x28) MAR1L ;  /* DMA memory address reg, channel 1L */
__sfr __at (Z180_IO_BASE+0x29) MAR1H ;  /* DMA memory address reg, channel 1H */
__sfr __at (Z180_IO_BASE+0x2A) MAR1B ;  /* DMA memory address reg, channel 1B */
__sfr __at (Z180_IO_BASE+0x2B) IAR1L ;  /* DMA I/O address reg,    channel 1L */
__sfr __at (Z180_IO_BASE+0x2C) IAR1H ;  /* DMA I/O address reg,    channel 1H */
__sfr __at (Z180_IO_BASE+0x2E) BCR1L ;  /* DMA byte count reg,     channel 1L */
__sfr __at (Z180_IO_BASE+0x2F) BCR1H ;  /* DMA byte count reg,     channel 1H */
__sfr __at (Z180_IO_BASE+0x30) DSTAT ;  /* DMA status register */
__sfr __at (Z180_IO_BASE+0x31) DMODE ;  /* DMA mode register */
__sfr __at (Z180_IO_BASE+0x32) DCNTL ;  /* DMA/WAIT control register */

__sfr __at (Z180_IO_BASE+0x33) IL    ;  /* Interrupt vector low register */
__sfr __at (Z180_IO_BASE+0x34) ITC   ;  /* INT/TRAP control register */

__sfr __at (Z180_IO_BASE+0x36) RCR   ;  /* Refresh control register */

__sfr __at (Z180_IO_BASE+0x38) CBR   ;  /* MMU common base register */
__sfr __at (Z180_IO_BASE+0x39) BBR   ;  /* MMU bank base register */
__sfr __at (Z180_IO_BASE+0x3A) CBAR  ;  /* MMU common/bank area register */

__sfr __at (Z180_IO_BASE+0x3E) OMCR  ;  /* Operation mode control register */

__sfr __at               0x3F  ICR   ;  /* I/O base control register - does not move */

#else


/*
 *---------------------------------------------------------------------------
 *      Z180/HD64180 internal port addresses                   P. 48
 */
#define CNTLA0 (Z180_IO_BASE+0x00)		/* ASCI control register A channel 0 */
#define CNTLA1 (Z180_IO_BASE+0x01)		/* ASCI control register A channel 1 */
#define CNTLB0 (Z180_IO_BASE+0x02)		/* ASCI control register B channel 0 */
#define CNTLB1 (Z180_IO_BASE+0x03)		/* ASCI control register B channel 0 */
#define STAT0  (Z180_IO_BASE+0x04)		/* ASCI status register    channel 0 */
#define STAT1  (Z180_IO_BASE+0x05)		/* ASCI status register    channel 1 */
#define TDR0   (Z180_IO_BASE+0x06)		/* ASCI transmit data reg, channel 0 */
#define TDR1   (Z180_IO_BASE+0x07)		/* ASCI transmit data reg, channel 1 */
#define RDR0   (Z180_IO_BASE+0x08)		/* ASCI receive data reg,  channel 0 */
#define RDR1   (Z180_IO_BASE+0x09)		/* ASCI receive data reg,  channel 0 */
#if Z8S180
#define ASEXT0 (Z180_IO_BASE+0x12)		/* ASCI extension control register    p.135 */
#define ASEXT1 (Z180_IO_BASE+0x13)		/* ASCI extension control register    */
#define ASTC0L (Z180_IO_BASE+0x1A)		/* ASCI0 time constant low register    p.137 */
#define ASTC0H (Z180_IO_BASE+0x1B)		/* ASCI0 time constant high register    */
#define ASTC1L (Z180_IO_BASE+0x1C)		/* ASCI0 time constant low register    p.138 */
#define ASTC1H (Z180_IO_BASE+0x1D)		/* ASCI0 time constant high register    */
#endif
#define CNTR   (Z180_IO_BASE+0x0A)		/* CSI/0 control register */
#define TRDR   (Z180_IO_BASE+0x0B)		/* CSI/0 transmit/receive data reg */

#define TMDR0L (Z180_IO_BASE+0x0C)		/* Timer data register,    channel 0L */
#define TMDR0H (Z180_IO_BASE+0x0D)		/* Timer data register,    channel 0H */
#define RLDR0L (Z180_IO_BASE+0x0E)		/* Timer reload register,  channel 0L */
#define RLDR0H (Z180_IO_BASE+0x0F)		/* Timer reload register,  channel 0H */
#define TCR    (Z180_IO_BASE+0x10)		/* Timer control register */
#define TMDR1L (Z180_IO_BASE+0x14)		/* Timer data register,    channel 1L */
#define TMDR1H (Z180_IO_BASE+0x15)		/* Timer data register,    channel 1H */
#define RLDR1L (Z180_IO_BASE+0x16)		/* Timer reload register,  channel 1L */
#define RLDR1H (Z180_IO_BASE+0x17)		/* Timer reload register,  channel 1H */

#define FRC    (Z180_IO_BASE+0x18)		/* Timer Free running counter */
#if Z8S180
#define CMR    (Z180_IO_BASE+0x1E)		/* Clock multiplier register  */
#define CCR    (Z180_IO_BASE+0x1F)		/* CPU control register       */
#endif

#define SAR0L  (Z180_IO_BASE+0x20)		/* DMA source address reg, channel 0L */
#define SAR0H  (Z180_IO_BASE+0x21)		/* DMA source address reg, channel 0H */
#define SAR0B  (Z180_IO_BASE+0x22)		/* DMA source address reg, channel 0B */
#define DAR0L  (Z180_IO_BASE+0x23)		/* DMA dest address reg,   channel 0L */
#define DAR0H  (Z180_IO_BASE+0x24)		/* DMA dest address reg,   channel 0H */
#define DAR0B  (Z180_IO_BASE+0x25)		/* DMA dest address reg,   channel 0B */
#define BCR0L  (Z180_IO_BASE+0x26)		/* DMA byte count reg,     channel 0L */
#define BCR0H  (Z180_IO_BASE+0x27)		/* DMA byte count reg,     channel 0H */
#define MAR1L  (Z180_IO_BASE+0x28)		/* DMA memory address reg, channel 1L */
#define MAR1H  (Z180_IO_BASE+0x29)		/* DMA memory address reg, channel 1H */
#define MAR1B  (Z180_IO_BASE+0x2A)		/* DMA memory address reg, channel 1B */
#define IAR1L  (Z180_IO_BASE+0x2B)		/* DMA I/O address reg,    channel 1L */
#define IAR1H  (Z180_IO_BASE+0x2C)		/* DMA I/O address reg,    channel 1H */
#define BCR1L  (Z180_IO_BASE+0x2E)		/* DMA byte count reg,     channel 1L */
#define BCR1H  (Z180_IO_BASE+0x2F)		/* DMA byte count reg,     channel 1H */
#define DSTAT  (Z180_IO_BASE+0x30)		/* DMA status register */
#define DMODE  (Z180_IO_BASE+0x31)		/* DMA mode register */
#define DCNTL  (Z180_IO_BASE+0x32)		/* DMA/WAIT control register */

#define IL     (Z180_IO_BASE+0x33)		/* Interrupt vector low register */
#define ITC    (Z180_IO_BASE+0x34)		/* INT/TRAP control register */

#define RCR    (Z180_IO_BASE+0x36)		/* Refresh control register */

#define CBR    (Z180_IO_BASE+0x38)		/* MMU common base register */
#define BBR    (Z180_IO_BASE+0x39)		/* MMU bank base register */
#define CBAR   (Z180_IO_BASE+0x3A)		/* MMU common/bank area register */

#define OMCR   (Z180_IO_BASE+0x3E)		/* Operation mode control register */

#define ICR    0x3F							/* I/O base control register - does not move */

#endif   // __SDCC__

#define cntla0 (Z180_IO_BASE+0x00)  /* ASCI control register A channel 0 */
#define cntla1 (Z180_IO_BASE+0x01)  /* ASCI control register A channel 1 */


/*
 *---------------------------------------------------------------------------
 *      Interrupt vectors (offsets) for Z180/HD64180 internal interrupts
 */
#define INT1_VECTOR     0x00    /* external /INT1 */
#define INT2_VECTOR     0x02    /* external /INT2 */
#define PRT0_VECTOR     0x04    /* PRT channel 0 */
#define PRT1_VECTOR     0x06    /* PRT channel 1 */
#define DMA0_VECTOR     0x08    /* DMA channel 0 */ /* ???? */
#define DMA1_VECTOR     0x0A    /* DMA Channel 1 */
#define CSIO_VECTOR     0x0C    /* Clocked serial I/O */
#define ASCI0_VECTOR    0x0E    /* Async channel 0 */
#define ASCI1_VECTOR    0x10    /* Async channel 1 */
#define INCAP_VECTOR    0x12    /* input capture */
#define OUTCMP_VECTOR   0x14    /* output compare */
#define TIMOV_VECTOR    0x16    /* timer overflow */
/*
 *---------------------------------------------------------------------------
 */


#endif  /* __Z180_H__ */

