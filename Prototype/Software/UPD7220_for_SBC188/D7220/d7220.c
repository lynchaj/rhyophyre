/* ut7220.c 
 */
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "rhyophyre.h"

#define abs(v) ((v)<0?-(v):(v))

/* the GDC 7220 status bits:   */
#define GDC_DATA_READY		0x01
#define GDC_FIFO_FULL		0x02
#define GDC_FIFO_EMPTY		0x04
#define GDC_DRAWING		0x08
#define GDC_DMA_EXEC		0x10
#define GDC_VERT_SYNC		0x20
#define GDC_HORIZ_SYNC		0x40
#define GDC_LIGHT_PEN		0x80

/* GDC 7220 mode bits:   0 0 C F I D G S */
#define Graphics 0x12

/* Drawing modes:  */
#define GDC_REPLACE	0
#define GDC_XOR		1
#define GDC_OR		3
#define GDC_CLEAR	2

/* Latch bits */
#define LATCH_RAMDAC_256      0x80     /* 256 color mode */
#define LATCH_OVERLAY_MASK    0x0F     /* 4 overlay bits */

/* 4-plane Colors */
#define CLR_BLACK    0
#define CLR_BLUE     1
#define CLR_GREEN    2
#define CLR_CYAN     3
#define CLR_RED      4
#define CLR_MAGENTA  5
#define CLR_AMBER    6
#define CLR_WHITE    7
#define CLR_DARK_WHITE 8
#define CLR_BR_BLUE  9
#define CLR_BR_GREEN 10
#define CLR_BR_CYAN  11
#define CLR_BR_RED   12
#define CLR_BR_MAGENTA  13
#define CLR_BR_YELLOW   14
#define CLR_BR_WHITE 15


unsigned char dbglvl;
word Xmax, Ymax, Ypitch;	/* all in pixels */
word Ypitch_wds;
long start_address;
byte HFP, HS, HBP;	/* front porch, h-sync, back porch */
byte Mode;		/* drawing mode */
byte Zoom_Display, Zoom_Draw;
word currX, currY;

byte color_Color, color_Modus;
/* for the prototype board with reversed address lines:    */
long plane_address[4] = { 0L, 2L<<16, 1L<<16, 3L<<16 };
/* for the production board with coherent address lines:   */
// long plane_address[4] = { 0L, 2L<<16, 1L<<16, 3L<<16 };


struct Area {
    word address_lo;
    byte address_hi : 4;
    byte length_lo  : 4;
    byte length_hi  : 6;
    byte IM         : 1;	/* MBZ in graphic mode */
    byte WD	    : 1;	/* MBZ */
} area;

typedef
word Colors[3];

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


void ramdac_overlay(byte overlay)
{
   outp(ramdac_latch, (overlay & LATCH_OVERLAY_MASK) | LATCH_RAMDAC_256 );
}

void ramdac_set_overlay_color(byte overlay, Colors color)
{
   outp(ramdac_overlay_wr, overlay);
   outp(ramdac_overlay_ram, color[Red]);
   outp(ramdac_overlay_ram, color[Green]);
   outp(ramdac_overlay_ram, color[Blue]);
}

void ramdac_set_palette_color(byte index, Colors color)
{
   outp(ramdac_address_wr, index);
   outp(ramdac_palette_ram, color[Red]);
   outp(ramdac_palette_ram, color[Green]);
   outp(ramdac_palette_ram, color[Blue]);
}

void ramdac_set_read_mask(byte mask)
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

void gdc_putc(byte command)
{
    while (inp(gdc_status) & GDC_FIFO_FULL) ;	/* spin here */
    outp(gdc_command, command);
}

void gdc_putp(byte parameter)
{
    while (inp(gdc_status) & GDC_FIFO_FULL) ;	/* spin here */
    outp(gdc_param, parameter);
}


void gdc_sync_params(void)
{
    word VS, VFP, VBP;
    byte i, *p;
    struct Sync {
        byte mode;
        byte AW;	/* active words per line - 2 */
        byte HS  : 5;	/* Hor Sync wds - 1 */
        byte VSL : 3;	/* vert sync low */
        byte VSH : 2;	/* vert sync hi */
        byte HFP : 6;	/* HFP - 1 */
        byte HBP;	/* HBP - 1 */
        byte VFP;	/* Vert front porch */
        byte ALL;	/* Active Lines low */
        byte ALH : 2;	/* Active Lines high */
        byte VBP : 6;	/* Vert back porch */        
    } sync;
    sync.mode = Graphics;	/* mode = 0x12 */
    sync.AW = Xmax/16 - 2;
    sync.HS = HS - 1;
    VFP = 7;         // was 10
    VS = 2;
//    VBP = 524 - Ymax - VFP - VS;
    VBP = 32 - VFP - VS;     // was 44
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
}

/* enable/blank display:  1/0 */
void gdc_display(byte enable)
{
    gdc_putc(0x0C | enable);
}

/* enable/blank display:  1/0 */
void gdc_sync(byte enable)
{
    gdc_putc(0x0E | enable);
    gdc_sync_params();
}

void gdc_reset(void)
{
    outp(gdc_command, 0x00);	/* just jam it out */
    gdc_sync_params();
}

void gdc_vsync(byte master)
{
    gdc_putc(0x6E | master);
}

void gdc_cchar(void)
{
    gdc_putc(0x4B);
    gdc_putp(0);
    gdc_putp(0);
    gdc_putp(0);
}

void gdc_pitch(byte pitch)
{
    gdc_putc(0x47);
    gdc_putp(pitch);
}

void gdc_pram(byte start, byte *param, byte count)
{
    gdc_putc(0x70 + (start & 15));
    while (count--) gdc_putp(*param++);
}

void gdc_pattern(word pattern)
{
    gdc_pram(8, (byte*)&pattern, 2);
}

void gdc_zoom_display(byte factor)
{
    gdc_putc(0x46);
    gdc_putp((Zoom_Draw-1) | ((factor-1)<<4));
    Zoom_Display = factor;
}

void gdc_zoom_draw(byte factor)
{
    gdc_putc(0x46);
    gdc_putp((factor-1) | ((Zoom_Display-1)<<4));
    Zoom_Draw = factor;
}

/* void gdc_curs(void); */
void gdc_setcursor(word X, word Y)	/* set the graphic cursor position */
{
    word offset;
    long address;
    
    offset = Y * Ypitch_wds + (X >> 4);
    address = start_address + offset;

    gdc_putc(0x49);	/* CURS command */
    gdc_putp((byte)address);
    gdc_putp((byte)(address>>8));
    gdc_putp((byte)((address>>16)&3 | (X<<4)));
    currX = X;
    currY = Y;
}

void gdc_start(void)
{
    gdc_putc(0x6B);
}

void gdc_mask(word pattern)
{
    gdc_putc(0x4A);
    gdc_putp((byte)pattern);
    gdc_putp((byte)(pattern>>8));
}

void gdc_mode(int mode)
{
    if (Mode == mode) return;
    gdc_putc(0x20 | (mode&3));	/* WDAT, no params */
    Mode = mode;
}

/* init GDC, enable/blank the screen 1/0 */
void gdc_init(byte enable)
{
    Mode = GDC_XOR;
    gdc_reset();
    gdc_sync(enable);
    gdc_vsync(1);
/*    gdc_cchar(); */
    Ypitch_wds = Ypitch/16;
    gdc_pitch(Ypitch_wds);

/*    gdc_pram(0, param_0, sizeof(param_0)); */
    area.address_lo = start_address;
    area.address_hi = start_address>>16;
    area.length_lo = Ymax;
    area.length_hi = Ymax>>4;
    area.IM = 0;
    area.WD = 0;
    gdc_pram(0, (byte*)&area, sizeof(area));		/* graphic area 1 */
    gdc_pram(sizeof(area), (byte*)&area, sizeof(area));    /* graphic area 2 */
    gdc_pattern(0xFFFF);
    
    Zoom_Draw = 1;
    gdc_zoom_display(1);
/*    gdc_curs(); */
    currX = 1;
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

void gdc_Dparam(int D, byte OR)
{
    gdc_putp((byte)D);
    D >>= 8;
    gdc_putp((byte)((byte)D & 0x3F | OR));
}

void gdc_hline(int x1, int x2, int y, byte mode)
{
    int temp;
    word mask, maskf;
    
    if (x1 > x2) {
        temp = x1;
        x1 = x2;
        x2 = temp;
    }
    mask = maskf = 0xFFFF;
    gdc_setcursor((word)x1, (word)y);
    
    if ( (temp = x1 % 16) ) {
        mask <<= temp;
        if (x1/16 < x2/16) {
            gdc_mask(mask);
            gdc_putc(0x4C);	/* FIGS for WDAT */
            gdc_putp(2);	/* direction 2 */
            gdc_putc(0x20 | mode);	/* WDAT full word */
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
        gdc_putc(0x4C);	/* FIGS for WDAT */
        gdc_putp(2);	/* direction 2 */
        gdc_Dparam((word)temp, 0);
        gdc_putc(0x20 | mode);	/* WDAT full word */
        gdc_putp(0xFF);	/* LSB only */
        gdc_putp(0xFF);	/* LSB only */
        mask = 0xFFFF;
    }    
    if ( (mask = mask & maskf) != 0xFFFFu) {
        gdc_mask(mask);
        gdc_putc(0x4C);	/* FIGS for WDAT */
        gdc_putp(2);	/* direction 2 */
        gdc_putc(0x20 | mode);	/* WDAT lo-byte */
        gdc_putp(0xFF);	/* LSB only */
        gdc_putp(0xFF);	/* LSB only */
    }
}

void gdc_line(int x1, int y1, int x2, int y2)
{
    int dx, dy, DC, D1, D2, D;
    static const int tran[8] = {0,1,3,2,7,6,4,5};
    byte dir = 0;

    gdc_setcursor((word)x1, (word)y1);    
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
    gdc_putc(0x4C);	/* FIGS command */
    gdc_putp(dir | 8);	/* LINE mode */
    D = D1 - DC;
    D2 = D - DC;
    debug(3,printf("dir=%d, DC=%d, D=%d, D2=%d, D1=%d\n",(int)dir,DC,D,D2,D1));
    gdc_Dparam(DC, 0);
    gdc_Dparam(D, 0);
    gdc_Dparam(D2, 0);
    gdc_Dparam(D1, 0);
    gdc_putc(0x6C);	/* FIGD command */
    currX = x2;
    currY = y2;
}

static const byte Fill[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
void gdc_fill(int x1, int y1, int x2, int y2, byte color)
{
    byte mode = Mode;
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
    gdc_setcursor((word)x1, (word)y1);
    
    gdc_putc(0x4C);	/* FIGS command */
    gdc_putp(0x10);	/* DIR=0, GC=1 */
    DC = x2 - x1;	/* Perp. pix - 1 */
    D = y2 - y1 + 1;	/* Initial dir pix */
    gdc_Dparam(DC, 0);
    gdc_Dparam(D, 0);
    gdc_Dparam(D, 0);
    gdc_putc(0x68);	/* GCHRD command */
    
    gdc_mode(mode);
}

void gdc_fill2(int x1, int y1, int x2, int y2, byte color)
{
    byte mode = Mode;
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
static const byte patt[8] = {0xff, 0x9f, 0x87, 0x8b,
                             0x93, 0xa3, 0x83, 0xff};
    word x, y, delta, i;
    
    y = 100;
    x = 200;
    delta = 40;
//    gdc_zoom_draw(2);
    gdc_zoom_draw(1);
    for (i=0; i<8; i++) {
        gdc_pram(8, patt, 8);
        gdc_setcursor(x+i*delta, y);
        gdc_mode(GDC_REPLACE);
        gdc_putc(0x4C);		/* FIGS command */
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


byte color_setup(byte color)
{
    byte color0 = color_Color;

    color_Color = color & 0x0F;
    return color0;
}

byte color_mode(byte mode)
{
    byte mode0 = color_Modus;

    color_Modus = mode & 3;
    return mode0;
}

void color_line(int x1, int y1, int x2, int y2)
{
    int count;
    byte mask = 1;
    byte color;

    for (count = 0; count < 4; ++count, mask<<=1) {
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

void color_fill(int x1, int y1, int x2, int y2, byte color)
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
        gdc_setcursor((word)x1, (word)y1);
   
        gdc_putc(0x4C);	/* FIGS command */
        gdc_putp(0x10);	/* DIR=0, GC=1 */
        DC = x2 - x1;	/* Perp. pix - 1 */
        D = y2 - y1 + 1;	/* Initial dir pix */
        gdc_Dparam(DC, 0);
        gdc_Dparam(D, 0);
        gdc_Dparam(D, 0);
        gdc_putc(0x68);	/* GCHRD command */
   }    
}

void color_fill2(int x1, int y1, int x2, int y2, byte color)
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


void main(int argc, char* argv[])
{
    int x1, x2, y;
    start_address = 0;	/* start of graphic area in display memory */
    dbglvl = DEBUG;
//    Xmax = 800;  // only with 40 MHz pix-clock
    Xmax = 640;  // only with 25.175 MHz pix-clock
//    Ypitch = 1024;	/* try this for size */
    Ypitch = 832;	/* must fit in 32K x 16 */

    HFP = 2;
    HS  = 6;
    HBP = 8;	/* or 4 */
    
    printf("\nStart test of uPD7220\n");
    if (argc==2 || argc==5) {
        Xmax = atoi(argv[--argc]);
    }
    if (argc==4) {
        HFP = atoi(argv[1]);
        HS =  atoi(argv[2]);
        HBP = atoi(argv[3]);
    }
    printf("HFP=%d  HS=%d  HBP=%d\n", (int)HFP, (int)HS, (int)HBP);
    
    if (Xmax==640) Ymax = 480;
    else if (Xmax==800) Ymax = 600;    /*  4:3  aspect ratio */
    else if (Xmax==832) Ymax = 624;
    else if (Xmax==960) Ymax = 540;    /* 16:9  aspect ratio */
    else {
        printf("Error:  Xmax = %d\n", Xmax);
        exit(5);
    }
    printf("Xmax = %d  Ymax = %d\n", Xmax, Ymax);

    ramdac_init();
    ramdac_set_read_mask(0x0F);
    ramdac_overlay(0);

    gdc_init(0);

//    gdc_fill(0,0, Xmax-1, Ymax-1, 0);	/* clear the screen */
//    gdc_fill(0,0, Xmax-1, Ymax-1, 0);	/* clear the screen */
//    gdc_fill2(0,0, Xmax-1, Ymax-1, 0);	/* clear the screen */


    color_fill2(0,0, Xmax-1, Ymax-1, 0);	/* clear the screen */
//    color_fill(0,0, Xmax-1, Ymax-1, 0);	/* clear the screen */

    gdc_display(1);	/* unblank the display */

    start_address = 0;

    gdc_pattern(0xFFFF);
//    gdc_line(Xmax-1, Ymax-1, Xmax-1, 0);
//    gdc_line(Xmax-1, 0, 0, 0);
//    gdc_line(0, 0, 0, Ymax-1);
//    gdc_line(0, Ymax-1, Xmax-1, Ymax-1);

    color_mode(GDC_REPLACE);
    color_setup(CLR_GREEN);
    color_line(Xmax-1, Ymax-1, Xmax-1, 0);
    color_setup(CLR_BR_RED);
    color_line(Xmax-1, 0, 0, 0);
    color_setup(CLR_BR_BLUE);
    color_line(0, 0, 0, Ymax-1);
    color_setup(CLR_MAGENTA);
    color_line(0, Ymax-1, Xmax-1, Ymax-1);
     

    color_mode(GDC_REPLACE);
    color_setup(CLR_BR_YELLOW);
    x1 = 32; x2 = 95;
    for (y=12; y<34; y++) color_line(x1, y, x2, y);
    color_mode(GDC_CLEAR);
    color_setup(15);
    for ( ; y<66; y++) color_line(x1, y, x2, y);
    color_mode(GDC_OR);
    color_setup(CLR_AMBER);
    for ( ; y<98; y++) color_line(x1, y, x2, y);
    color_mode(GDC_XOR);
    for ( ; y<130; y++) color_line(x1, y, x2, y);
    
    color_mode(GDC_REPLACE);
    color_setup(CLR_WHITE);
    color_line(100,100, 78,34);	/* example from Design book */

    color_mode(GDC_XOR);
    color_line(10, 10, 629, 469);

    color_mode(GDC_REPLACE);
    color_line(1, 10, 15, 460);
    color_line(638, 10, 624, 460);

    gchar_test();
    
    gdc_pattern(0xFFFF);
    gdc_hline(40, 599, 300, GDC_REPLACE);
    color_line(40, 300-5, 40, 285);
    color_line(599, 300-5, 599, 285);
            
    gdc_hline(32, 591, 330, GDC_REPLACE);
    color_line(32, 330-5, 32, 330-15);
    color_line(591, 330-5, 591, 330-15);
            
    gdc_hline(32, 599, 360, GDC_REPLACE);
    color_line(32, 360-5, 32, 360-15);
    color_line(599, 360-5, 599, 360-15);

    color_mode(GDC_OR);
    color_line(589, 20, 593, 120);	/* missing middle segment @591 */
    color_mode(GDC_REPLACE);
    color_line(593+16, 120, 589+16, 20);	/* lo->hi, now hi->lo */

    color_mode(GDC_REPLACE);
    color_line(40, 300+5, 599, 300+5);
    color_line(32, 330+5, 591, 330+5);
    color_line(32, 360+5, 599, 360+5);
    
    y = 360+12;
    for (x1=32; x1<599; x1+=16) {
        x2 = x1+14;
        if (x2 > 599) x2 = 599;
        color_line(x1, y, x2, y);		/* line skips pixel @AD15 */
    }
    color_mode(GDC_REPLACE);
    color_setup(CLR_BR_RED);
    color_line(0, 200, 639, 212);
    color_setup(CLR_MAGENTA);
    color_line(639, 224, 0, 212);
    color_setup(CLR_GREEN);
    color_line(639, 224, 0, 236);
    color_setup(CLR_CYAN);
    color_line(0, 248, 639, 236);

    color_setup(CLR_AMBER);
    color_line(638, 474, 638, 374);

    color_mode(GDC_OR);
    color_line(638, 379, 638, 324);
    
    gdc_done();
    printf("\nEnd test of uPD7220\n");
    
    exit(0);
}

