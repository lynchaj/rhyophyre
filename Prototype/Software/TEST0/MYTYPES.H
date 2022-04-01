/*************************************************************************
*  mytypes.h -- Definitions for the N8VEM / UNA-bios project
**************************************************************************
*
*   Copyright (C) 2011,2014 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM Z80/Z180 CPU boards.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*************************************************************************/

#ifndef __MYTYPES_H
#define __MYTYPES_H 1

typedef signed char			int8;
typedef signed short int	int16;
typedef signed long int		int32;

typedef unsigned char		uint8;
typedef unsigned short int	uint16;
typedef unsigned long int	uint32;

typedef unsigned char  byte;
typedef unsigned short word;
typedef unsigned long dword;

#ifdef M68000
typedef unsigned long long	qword;
typedef unsigned long long	uint64;
typedef signed long long	int64;
#endif

#ifndef NULL
#define NULL ((void*)0)
#endif	// NULL
#ifndef exit
void exit(byte);
#endif

#ifdef __SDCC__
#define outp(port,byte)  port  =  (byte)
#define inp(port)	(port)
#else
void outp(byte port, byte data);
int inp(byte port);
#endif

#define nelem(x) (sizeof(x)/sizeof(x[0]))

#endif  /* __MYTYPES_H */

