#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "rhyophyre.h"

#include "gdc7220.h"

#define NUM_PLANES 4
#define UPD7220A   1

/* the GDC 7220 status bits:   */
typedef enum GDC_Status {
//  GDC_DATA_READY		= 0x01,
    GDC_FIFO_FULL		= 0x02,
    GDC_FIFO_EMPTY		= 0x04,
    GDC_DRAWING		    = 0x08,
//  GDC_DMA_EXEC		= 0x10,
//  GDC_VERT_SYNC		= 0x20,
//  GDC_HORIZ_SYNC		= 0x40,
//  GDC_LIGHT_PEN		= 0x80,
} GDC_Status;

/* GDC 7220 mode bits:   0 0 C F I D G S */
#define Graphics 0x12

/* Latch bits */
#define LATCH_RAMDAC_256      0x80     /* 256 color mode */
#define LATCH_OVERLAY_MASK    0x0F     /* 4 overlay bits */

typedef enum GDC_Command {
    GDC_CMD_RESET                 = 0x0,
    GDC_CMD_SYNC_AND_ENABLE       = 0xF,
    GDC_CMD_SYNC_AND_DISABLE      = 0xE,
    GDC_CMD_DISPLAY_ENABLE        = 0xD,
    GDC_CMD_DISPLAY_BLANK         = 0xC,
    GDC_CMD_ZOOM                  = 0x46,
    GDC_CMD_PITCH                 = 0x47,
    GDC_CMD_CCHAR                 = 0x4B, /* Cursor & CHARacter info */
    GDC_CMD_CURS                  = 0x49, /* CURsor Specify */
    GDC_CMD_FIGS                  = 0x4C, /* FIGure Specify */
    GDC_CMD_FIGD                  = 0x6C, /* FIGure Draw */
    GDC_CMD_VSYNC_MODE_SECONDARY  = 0x6E,
    GDC_CMD_VSYNC_MODE_PRIMARY    = 0x6F,
    GDC_CMD_WDAT_WORD_REPLACE     = 0x20,
/*
    GDC_CMD_WDAT_LBYTE_REPLACE    = 0x30,
    GDC_CMD_WDAT_HBYTE_REPLACE    = 0x38,
    GDC_CMD_WDAT_WORD_COMPLEMENT  = 0x21,
    GDC_CMD_WDAT_LBYTE_COMPLEMENT = 0x31,
    GDC_CMD_WDAT_HBYTE_COMPLEMENT = 0x39,
    GDC_CMD_WDAT_WORD_RESET       = 0x22,
    GDC_CMD_WDAT_LBYTE_RESET      = 0x32,
    GDC_CMD_WDAT_HBYTE_RESET      = 0x3A,
    GDC_CMD_WDAT_WORD_SET         = 0x23,
    GDC_CMD_WDAT_LBYTE_SET        = 0x33,
    GDC_CMD_WDAT_HBYTE_SET        = 0x3B,
*/
} GDC_Command;



unsigned char dbglvl;
uint16_t Xmax, Ymax, Ypitch;	/* all in pixels */
uint16_t Ypitch_wds;
long start_address;
uint8_t HFP, HS, HBP;	/* front porch, h-sync, back porch */
uint8_t Mode;		/* drawing mode */
uint8_t Zoom_Display, Zoom_Draw;
uint16_t currX, currY;

uint8_t color_Color, color_Modus;
/* for the prototype board with reversed address lines:    */
long plane_address[4] = { 0L, 2L<<16, 1L<<16, 3L<<16 };
/* for the production board with coherent address lines:   */
// long plane_address[4] = { 0L, 2L<<16, 1L<<16, 3L<<16 };

typedef
uint16_t Colors[3];

typedef
Colors Palette[16];

enum {Red=0, Green, Blue};

static
Palette default_palette = { 
   {  0,   0,   0},
   {  0,   0, 128},
   {  0, 128,   0},
   {  0, 128, 128},
   {128,   0,   0},
   {128,   0, 128},
   {128,  64,   0},
   {128, 128, 128},
   { 64,  64,  64},
   {  0,   0, 255},
   {  0, 255,   0},
   {  0, 255, 255},
   {255,   0,   0},
   {255,   0, 255},
   {255, 255,   0},
   {255, 255, 255} };


void ramdac_overlay(uint8_t overlay)
{
   outp(ramdac_latch, (overlay & LATCH_OVERLAY_MASK) | LATCH_RAMDAC_256 );
}

void ramdac_set_overlay_color(uint8_t overlay, Colors color)
{
   outp(ramdac_overlay_wr, overlay);
   outp(ramdac_overlay_ram, color[Red]);
   outp(ramdac_overlay_ram, color[Green]);
   outp(ramdac_overlay_ram, color[Blue]);
}

void ramdac_set_palette_color(uint8_t index, Colors color)
{
   outp(ramdac_address_wr, index);
   outp(ramdac_palette_ram, color[Red]);
   outp(ramdac_palette_ram, color[Green]);
   outp(ramdac_palette_ram, color[Blue]);
}

void ramdac_set_read_mask(uint8_t mask)
{
/* set the pixel read mask */
   outp(ramdac_pixel_read_mask, mask);
}

void ramdac_init(void)
{
   int i;

   ramdac_overlay(0);
   for (i=1; i<=15; ++i)
      ramdac_set_overlay_color(i, default_palette[i]);
   ramdac_overlay(8);
   ramdac_set_read_mask(0x0F);
   for (i=0; i<=15; ++i)
      ramdac_set_palette_color(i, default_palette[i]);
}

void gdc_putc(uint8_t command)
{
    while (inp(gdc_status) & GDC_FIFO_FULL) ;	/* spin here */
    outp(gdc_command, command);
}

void gdc_putp(uint8_t parameter)
{
    while (inp(gdc_status) & GDC_FIFO_FULL) ;	/* spin here */
    outp(gdc_param, parameter);
}

// Dan is using these parameters in t7220.asm:
// SYNCP:  .DB             012H,026H,044H,004H,002H,00AH,0E0H,085H
//
// Summary:
// AW:40, AL: 480
// HFP: 2, HS: 5, HBP: 3 
// VFP: 10, VS: 2, VBP: 33
//
// Mode = P1 = 0x12
// AW-2 = P2 = 0x26 = 38 => AW = 40 uint16_ts per line => 640 pixels per line
// HS-1 = P3 (0x44) & 0x1F = 4 => HS = 5 uint16_ts
// VSL  = (P3(0x44) & 0xE0) >> 5 = 2
// VSH  = P4(0x04) & 0x3 = 0
// so VS = 2 lines
// HFP-1 = (P4(0x04) & 0xFC) >> 2 = 1 => HFP = 2 uint16_ts
// HBP-1 = P5(0x02) & 0x3F = 2 => HBP = 3 uint16_ts
// VFP   = P6(0x0A) & 0x3F = 10 lines
// ALL   = P7(0xE0) = 0xE0 = 224
// ALH   = (P8(0x85) & 0x3) = 1
// so AL = 1 * 256 + 224 = 480
// VBP   = (P8(0x85) & 0xFC) >> 2 = 0x21 = 33 lines


void gdc_sync_params(void)
{
    uint16_t VS = 2, VFP = 10, VBP = 33;
#if 0
    uint8_t i, *p;
    struct Sync {
        uint8_t mode;
        uint8_t AW;	/* active uint16_ts per line - 2 */
        uint8_t HS  : 5;	/* Hor Sync wds - 1 */
        uint8_t VSL : 3;	/* vert sync low */
        uint8_t VSH : 2;	/* vert sync hi */
        uint8_t HFP : 6;	/* HFP - 1 */
        uint8_t HBP;	/* HBP - 1 */
        uint8_t VFP;	/* Vert front porch */
        uint8_t ALL;	/* Active Lines low */
        uint8_t ALH : 2;	/* Active Lines high */
        uint8_t VBP : 6;	/* Vert back porch */        
    } sync;
    sync.mode = Graphics;	/* mode = 0x12 */
    sync.AW = Xmax/16 - 2;
    sync.HS = HS - 1;
    VFP = 10;         // was 7
    VS = 2;
//    VBP = 524 - Ymax - VFP - VS;
    VBP = 33;
    //VBP = 32 - VFP - VS;     // was 44
    sync.VSL = VS & 7;
    sync.VSH = VS >> 3;
    sync.HFP = HFP - 1;
    sync.HBP = HBP - 1;
    sync.VFP = VFP;
    sync.ALL = Ymax & 255;
    sync.ALH = Ymax >> 8;
    sync.VBP = VBP;
        
    p = &sync.mode;
    for (i=0; i<sizeof(sync); i++) gdc_putp(*p++);
#endif
    /* P1 => Mode of operation: Set to Graphics (0x12) */
    gdc_putp(Graphics);
  
    /* P2 => Active Display Words -2: */
    gdc_putp(Xmax / 16 - 2);

    /* P3 => low 3 bits of VS in 7:5, HS-1 in 4:0 */
    gdc_putp( ( (VS & 7) << 5 ) | ( ( HS-1 ) & 31) );

    /* P4 => HFP-1 in 7:2, high 2 bits of VS in 1:0 */
    gdc_putp( ( ( (HFP-1) & 63 ) << 2 ) | ( ( VS >> 3) & 3 ) );

    /* P5 => HBP-1 in 5:0 */
    gdc_putp( (HBP-1) & 63 );

    /* P6 => VFP in 5:0 */
    gdc_putp( VFP & 63 );

    /* P7 => Active Display Lines, lowest 7 bits */
    gdc_putp( Ymax & 0xFF );

    /* P8 => VBP in upper six bits, ADL high in lower two. */
    gdc_putp( ((VBP & 63) << 2)  | ( ( Ymax >> 8) & 3 ) );
}

/* enable/blank display:  1/0 */
void gdc_display(uint8_t enable)
{
    gdc_putc(enable ? GDC_CMD_DISPLAY_ENABLE : GDC_CMD_DISPLAY_BLANK);
}

/* enable/blank display:  1/0 */
void gdc_sync(uint8_t enable)
{
    gdc_putc(enable ? GDC_CMD_SYNC_AND_ENABLE : GDC_CMD_SYNC_AND_DISABLE);
    gdc_sync_params();
}

void gdc_reset(void)
{
#if UPD7220A
    outp(gdc_command, GDC_CMD_RESET + 3);	/* Just jam it out. But don't blank or rsync */
#else
    outp(gdc_command, GDC_CMD_RESET);	/* just jam it out */
#endif
}

void gdc_vsync(uint8_t primary)
{
    gdc_putc(primary ? GDC_CMD_VSYNC_MODE_PRIMARY : GDC_CMD_VSYNC_MODE_SECONDARY);
}

void gdc_cchar(void)
{
    /* We use graphics mode exclusively, so set everything to zero. */
    gdc_putc(GDC_CMD_CCHAR);
    gdc_putp(0);
    gdc_putp(0);
    gdc_putp(0);
}

void gdc_pitch(uint8_t pitch)
{
    gdc_putc(GDC_CMD_PITCH);
    gdc_putp(pitch);
}

void gdc_pram(uint8_t start, uint8_t *param, uint8_t count)
{
    gdc_putc(0x70 + (start & 15));
    while (count--) gdc_putp(*param++);
}

void gdc_pattern(uint16_t pattern)
{
    gdc_pram(8, (uint8_t*)&pattern, 2);
}

void gdc_zoom_display(uint8_t factor)
{
    gdc_putc(GDC_CMD_ZOOM);
    gdc_putp((Zoom_Draw-1) | ((factor-1)<<4));
    Zoom_Display = factor;
}

void gdc_zoom_draw(uint8_t factor)
{
    gdc_putc(GDC_CMD_ZOOM);
    gdc_putp((factor-1) | ((Zoom_Display-1)<<4));
    Zoom_Draw = factor;
}

void gdc_setcursor_by_addr(uint32_t address)
{
    gdc_putc(GDC_CMD_CURS);	/* CURS command */
    gdc_putp((uint8_t)address);
    gdc_putp((uint8_t)(address>>8));
    gdc_putp((uint8_t)( (address>>16) & 3 ) );
}

/* void gdc_curs(void); */
void gdc_setcursor(uint16_t X, uint16_t Y)	/* set the graphic cursor position */
{
    uint16_t offset;
    long address;
    
    offset = Y * Ypitch_wds + (X >> 4);
    address = start_address + offset;

    gdc_putc(0x49);	/* CURS command */
    gdc_putp((uint8_t)address);
    gdc_putp((uint8_t)( address >> 8 ) );
    gdc_putp((uint8_t)( ( ( address >> 16 ) & 3 ) | ( X << 4 )));
    currX = X;
    currY = Y;
}

#if 0
void gdc_setcursor2(uint32_t plane_address_in, uint16_t X, uint16_t Y)	/* set the graphic cursor position */
{
    uint16_t offset = Y * Ypitch_wds + (X >> 4);
    uint32_t address = plane_address_in + offset;

    gdc_setcursor_by_addr(address);
    currX = X;
    currY = Y;
}
#endif

void gdc_start(void)
{
    gdc_putc(0x6B);
}

void gdc_mask(uint16_t pattern)
{
    gdc_putc(0x4A);
    gdc_putp((uint8_t)pattern);
    gdc_putp((uint8_t)(pattern>>8));
}

void gdc_mode(int mode)
{
    if (Mode == mode) return;
    gdc_putc(0x20 | (mode&3));	/* WDAT, no params */
    Mode = mode;
}

void gdc_config_display_area(int area_num, uint32_t address, uint16_t length, uint8_t wide)
{
    assert(area_num > 0 && area_num < 2);

    gdc_putc(0x70 + area_num * 4);

    gdc_putp((uint8_t)(address & 0xFF));
    gdc_putp((uint8_t)((address >> 16) & 0xFF));
    gdc_putp( ( ( length & 0xF ) << 4 ) | (uint8_t)( ( address >> 16 ) & 3 ) );
    gdc_putp( (length & 0x3F) | (wide ? 0x80 : 0) ); /* IM forced to zero. */
}
/* init GDC, enable/blank the screen 1/0 */
void gdc_init(uint8_t enable)
{
    gdc_reset();
    gdc_sync(enable);
    gdc_vsync(1);
    gdc_cchar();
    gdc_pitch(Ypitch_wds);

    gdc_config_display_area(0, start_address, Ymax, 0);
    gdc_config_display_area(1, start_address, Ymax, 0);
    gdc_pattern(0xFFFF);
    
    gdc_zoom_display(1);
    gdc_setcursor(0, 0);
    gdc_mode(GDC_REPLACE);
    gdc_start();
}

void gdc_done(void)
{
/* First wait until the FIFO is empty */
    while (!(inp(gdc_status) & GDC_FIFO_EMPTY)) ;
/* Then wait until all drawing is done */
    while (inp(gdc_status) & GDC_DRAWING) ;
}

void gdc_Dparam(int D, uint8_t OR)
{
    gdc_putp((uint8_t)D);
    D >>= 8;
    gdc_putp((uint8_t)((uint8_t)(D & 0x3F) | OR));
}

void gdc_clear_screen()
{
    for (int plane = 0; plane < NUM_PLANES; plane++) {
        uint16_t words_left = Xmax >> 4;
        words_left = words_left * Ymax;
        uint32_t cursor_addr = plane_address[plane];
        while (words_left > 0) {
            gdc_setcursor_by_addr(cursor_addr);

            uint16_t word_count = words_left > 16384 ? 16384 : words_left;
            words_left =  words_left - word_count;
            cursor_addr += word_count;
            word_count--;

            uint8_t word_count_low = (uint8_t)(word_count & 0xFF);
            uint8_t word_count_hi = (uint8_t)((word_count >> 8) & 0x3F);

            gdc_mask(0xFFFF);

            gdc_putc(GDC_CMD_FIGS);    /* FIGS for WDAT */
            gdc_putp(2);    /* direction 2 */
            gdc_putp(word_count_low);
            gdc_putp(word_count_hi);

            gdc_putc(GDC_CMD_WDAT_WORD_REPLACE);    /* WDAT full uint16_t */
            gdc_putp(0x00);    /* LSB only */
            gdc_putp(0x00);    /* LSB only */
        }
    }
}

void gdc_hline(int x1, int x2, int y, uint8_t mode)
{
    int temp;
    uint16_t mask, maskf;
    
    if (x1 > x2) {
        temp = x1;
        x1 = x2;
        x2 = temp;
    }
    mask = maskf = 0xFFFF;
    gdc_setcursor((uint16_t)x1, (uint16_t)y);
    
    if ( (temp = x1 % 16) ) {
        mask <<= temp;
        if (x1/16 < x2/16) {
            gdc_mask(mask);
            gdc_putc(GDC_CMD_FIGS);	/* FIGS for WDAT */
            gdc_putp(2);	/* direction 2 */

            gdc_putc(0x20 | mode);	/* WDAT full uint16_t */
            gdc_putp(0xFF);	/* LSB only */
            gdc_putp(0xFF);	/* LSB only */
            mask = 0xFFFF;
        }
        x1 += 16-temp;
    }
    if ( (temp = 15 - x2 % 16) ) {
        maskf >>= temp;
        x2 -= 16-temp;
    }
    if ( (temp = (x2/16) - (x1/16)) > 0 ) {
        gdc_mask(mask);
        gdc_putc(GDC_CMD_FIGS);	/* FIGS for WDAT */
        gdc_putp(2);	/* direction 2 */
        gdc_Dparam((int)temp, 0);
        gdc_putc(0x20 | mode);	/* WDAT full uint16_t */
        gdc_putp(0xFF);	/* LSB only */
        gdc_putp(0xFF);	/* LSB only */
        mask = 0xFFFF;
    }    
    if ( (mask = mask & maskf) != 0xFFFFu) {
        gdc_mask(mask);
        gdc_putc(GDC_CMD_FIGS);	/* FIGS for WDAT */
        gdc_putp(2);	/* direction 2 */
        gdc_putc(0x20 | mode);	/* WDAT lo-uint8_t */
        gdc_putp(0xFF);	/* LSB only */
        gdc_putp(0xFF);	/* LSB only */
    }
}

void gdc_line(int x1, int y1, int x2, int y2)
{
    int dx, dy, DC, D1, D2, D;
    static const int tran[8] = {0,1,3,2,7,6,4,5};
    uint8_t dir = 0;

    gdc_setcursor((uint16_t)x1, (uint16_t)y1);    
    dx = x2 - x1;
    if (dx < 0) {
        dir |= 4;
        dx = -dx;
    }
    dy = y2 - y1;
    if (dy < 0) {
        dir |= 2;
        dy = -dy;
    }
    if (dx > dy) {
        dir |= 1;
        DC = dx;
        D1 = dy;
    }
    else {
        DC = dy;
        D1 = dx;
    }
    D1 += D1;		/* double it */
    dir = tran[dir] | (dx==dy);
    gdc_putc(GDC_CMD_FIGS);	/* FIGS command */
    gdc_putp(dir | 8);	/* LINE mode */
    D = D1 - DC;
    D2 = D - DC;
    debug(3,printf("dir=%d, DC=%d, D=%d, D2=%d, D1=%d\n",(int)dir,DC,D,D2,D1));
    gdc_Dparam(DC, 0);
    gdc_Dparam(D, 0);
    gdc_Dparam(D2, 0);
    gdc_Dparam(D1, 0);
    gdc_putc(GDC_CMD_FIGD);
    currX = x2;
    currY = y2;
}

static const uint8_t Fill[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
#if 0
void gdc_fill(int x1, int y1, int x2, int y2, uint8_t color)
{
    uint8_t mode = Mode;
    int temp;
    int DC, D;
    
    gdc_pram(8, Fill, 8);
    if (!color) gdc_mode(GDC_CLEAR);
    else gdc_mode(GDC_OR);
    if (x1 > x2) {
        temp = x1;
        x1 = x2;
        x2 = temp;
    }
    if (y1 > y2) {
        temp = y1;
        y1 = y2;
        y2 = temp;
    }
    gdc_setcursor((uint16_t)x1, (uint16_t)y1);
    
    gdc_putc(GDC_CMD_FIGS);	/* FIGS command */
    gdc_putp(0x10);	/* DIR=0, GC=1 */
    DC = x2 - x1;	/* Perp. pix - 1 */
    D = y2 - y1 + 1;	/* Initial dir pix */
    gdc_Dparam(DC, 0);
    gdc_Dparam(D, 0);
    gdc_Dparam(D, 0);
    gdc_putc(0x68);	/* GCHRD command */
    
    gdc_mode(mode);
}

void gdc_fill2(int x1, int y1, int x2, int y2, uint8_t color)
{
    uint8_t mode = Mode;
    int temp;
    
    gdc_pram(8, Fill, 8);
    if (!color) gdc_mode(GDC_CLEAR);
    else gdc_mode(GDC_OR);
    if (x1 > x2) {
        temp = x1;
        x1 = x2;
        x2 = temp;
    }
    if (y1 > y2) {
        temp = y1;
        y1 = y2;
        y2 = temp;
    }
    for (; y1<=y2; y1++) gdc_line(x1, y1, x2, y1);
    
    gdc_mode(mode);
}
#endif
void gchar_test(void)
{
/*	x x x x x x x x
        x     x x x x x
        x         x x x
        x       x   x x
        x     x     x x
        x   x       x x
        x           x x
        x x x x x x x x
 */
static const uint8_t patt[8] = {0xff, 0x9f, 0x87, 0x8b,
                             0x93, 0xa3, 0x83, 0xff};
    uint16_t x, y, delta, i;
    
    y = 100;
    x = 200;
    delta = 40;
//    gdc_zoom_draw(2);
    gdc_zoom_draw(1);
    for (i=0; i<8; i++) {
        gdc_pram(8, patt, 8);
        gdc_setcursor(x+i*delta, y);
        gdc_mode(GDC_REPLACE);
        gdc_putc(GDC_CMD_FIGS);		/* FIGS command */
        gdc_putp(0x10 + i);	/* GC + dir */
        gdc_Dparam(7, 0);	/* perp. pix - 1 */
        gdc_Dparam(8, 0);	/* initial dir pix */
        gdc_Dparam(8, 0);
        gdc_putc(0x68);		/* GCHRD */
    }
    gdc_zoom_draw(1);
    gdc_pattern(0x9999);
    gdc_mode(GDC_OR);
    gdc_line(x-20, y, x+7*delta+20, y);
}


uint8_t color_setup(uint8_t color)
{
    uint8_t color0 = color_Color;

    color_Color = color & 0x0F;
    return color0;
}

uint8_t color_mode(uint8_t mode)
{
    uint8_t mode0 = color_Modus;

    color_Modus = mode & 3;
    return mode0;
}

void color_line(int x1, int y1, int x2, int y2)
{
    int count;
    uint8_t mask = 1;
    uint8_t color;

    for (count = 0; count < NUM_PLANES; ++count, mask<<=1) {
        start_address = plane_address[count];
        color = color_Color & mask;
        switch(color_Modus) {
            case GDC_REPLACE:
            default:
                if (color) gdc_mode(GDC_REPLACE);
                else gdc_mode(GDC_CLEAR);
                break;
            case GDC_OR:
                if (color) gdc_mode(GDC_REPLACE);
                else continue;
                break;
            case GDC_XOR:
                if (color) gdc_mode(GDC_XOR);
                else continue;
                break;
            case GDC_CLEAR:
                if (color) gdc_mode(GDC_CLEAR);
                else continue;
                break;
        }
        gdc_line(x1, y1, x2, y2);
    }
}

#if 0

void color_fill(int x1, int y1, int x2, int y2, uint8_t color)
{
    int temp;
    int DC, D;
    int i, mask=1;
    
    gdc_pram(8, Fill, 8);
    for (i=0; i<4; ++i, mask<<=1) {
        start_address = plane_address[i];
        if (!(color&mask)) gdc_mode(GDC_CLEAR);
        else gdc_mode(GDC_OR);
        if (x1 > x2) {
           temp = x1;
           x1 = x2;
           x2 = temp;
        }
        if (y1 > y2) {
           temp = y1;
           y1 = y2;
           y2 = temp;
        }
        gdc_setcursor((uint16_t)x1, (uint16_t)y1);
   
        gdc_putc(GDC_CMD_FIGS);	/* FIGS command */
        gdc_putp(0x10);	/* DIR=0, GC=1 */
        DC = x2 - x1;	/* Perp. pix - 1 */
        D = y2 - y1 + 1;	/* Initial dir pix */
        gdc_Dparam(DC, 0);
        gdc_Dparam(D, 0);
        gdc_Dparam(D, 0);
        gdc_putc(0x68);	/* GCHRD command */
   }    
}

void color_fill2(int x1, int y1, int x2, int y2, uint8_t color)
{
    int temp;
    
    gdc_pram(8, Fill, 8);
    color_setup(color);

    if (x1 > x2) {
        temp = x1;
        x1 = x2;
        x2 = temp;
    }
    if (y1 > y2) {
        temp = y1;
        y1 = y2;
        y2 = temp;
    }
    gdc_pattern(0xFFFF);
    for (; y1<=y2; y1++) color_line(x1, y1, x2, y1);
}

#endif

int init_gdc_system(uint8_t video_mode)
{
    start_address = 0;	/* start of graphic area in display memory */
    dbglvl = DEBUG;
    Mode = GDC_XOR;
    Zoom_Draw = 1;
    currX = 1;

    if (video_mode == MODE_640X480) { 
        Xmax = 640;  // only with 25.175 MHz pix-clock
        Ymax = 480;
        Ypitch = 640;       /* must fit in 32K x 16 */
        Ypitch_wds = Ypitch/16;

        HFP = 2;  // Horizontal front porch
        HS  = 5;  // Horizontal Sync
        HBP = 3;    /* or 4 */ /* Horizontal back porch */
    } else { 
        fprintf(stderr, "Sorry, only 640x480 is supported for now.\n");
        return 0;
    }

#if 0    
    if (Xmax==640) Ymax = 480;
    else if (Xmax==800) Ymax = 600;    /*  4:3  aspect ratio */
    else if (Xmax==832) Ymax = 624;
    else if (Xmax==960) Ymax = 540;    /* 16:9  aspect ratio */
    else {
        printf("Error:  Xmax = %d\n", Xmax);
        exit(5);
    }
#endif
#if DEBUG
    fprintf(stderr, "init_gdc_system(): Xmax=%d, Ymax=%d, HFP=%d, HS=%d, HBP=%d\n", Xmax, Ymax, (int)HFP, (int)HS, (int)HBP);
#endif

    ramdac_init();
    ramdac_set_read_mask(0x0F);
    ramdac_overlay(0);

    gdc_init(0);

    gdc_clear_screen();

    gdc_display(1);	/* unblank the display */

    gdc_pattern(0xFFFF);

    color_mode(GDC_REPLACE);

    return 1;
}
