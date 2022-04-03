#include <stdio.h>
#include "gdc7220.h"

int main(void)
{
    int x1, x2, y;
    printf("Start test of upd7220.\n");

    const int Xmax = 640, Ymax = 480;

    if (!init_gdc_system(MODE_640X480)) {
        printf("Failed to initialize UPD7220 video.\n");
        return 1;
    }

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
    
    return 0;
}

