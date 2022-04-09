//

#ifndef SHOWPCX_PCX_H
#define SHOWPCX_PCX_H

#include <stdint.h>

#include "gdc7220.h"

#define HAVE_STRERROR 0

#if 0
typedef struct PaletteEntry {
    uint8_t Blue, Green, Red;
} PaletteEntry;
#endif

typedef struct PcxHeader
{
    uint8_t  Identifier;        /* PCX Id Number (Always 0x0A) */
    uint8_t	 Version;           /* Version Number */
    uint8_t  Encoding;          /* Encoding Format */
    uint8_t	 BitsPerPixel;      /* Bits per Pixel */
    uint16_t XStart;            /* Left of image */
    uint16_t YStart;            /* Top of Image */
    uint16_t XEnd;              /* Right of Image */
    uint16_t YEnd;              /* Bottom of image */
    uint16_t HorzRes;           /* Horizontal Resolution */
    uint16_t VertRes;           /* Vertical Resolution */
    PaletteEntry Palette[16];
//    uint8_t	Palette[48];       /* 16-Color EGA Palette */
    uint8_t	Reserved1;         /* Reserved (Always 0) */
    uint8_t	NumBitPlanes;      /* Number of Bit Planes */
    uint16_t BytesPerLine;      /* Bytes per Scan-line */
    uint16_t PaletteType;       /* Palette Type */
    uint16_t HorzScreenSize;    /* Horizontal Screen Size */
    uint16_t VertScreenSize;    /* Vertical Screen Size */
    uint8_t	 Reserved2[54];     /* Reserved (Always 0) */
} PCXHeader;

void create_planes(int fd, uint16_t height, uint16_t width, const char *inpath);
void parse_pcx_header(int fd, PCXHeader *pcx_header, const char *path);
void print_pcx_header(const PCXHeader *pcx_header);


#endif //SHOWPCX_PCX_H
