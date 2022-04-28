#include <stdio.h>
#include <stdlib.h>
#include "gdc7220.h"

void delay(uint16_t n)
{
    for (int i = 0; i < n; i++)
        inp(0);
}

void waitkey(void)
{
    int c;
    
    printf("Press <return> to continue (<esc> to exit)...");

    while (1)
    {
        c = getchar();
        if (c == '\n')
            return;
        if (c == 27)
            exit(1);
    }
}

int main(int argc, char *argv[])
{
    int ch = 0, have_error = 0;
    int x, y;

    const char *optstring = "C";

    while ((ch = getopt(argc, argv, optstring)) != -1)
    {
        switch (ch)
        {
            case 'C':
            case 'c':
                break;
//            case '?':
//                break;
            default:
                break;
        }
    }

    printf("Start upd7220 TYPE test.\n");

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

    uint8_t c = 0;

    for (int y = 0; y < 16; y++)
    {
        color_setup((y + CLR_WHITE) % 16);
        for (int x = 0; x < 16; x++)
        {
            // delay(10000);
            text_set_cursor(y, x);
            text_write_char(c++);
        }
    }
    waitkey();
    
    printf("Type stuff on CP/M console (<esc> to end)...\n");
    
    x = y = 0;
    text_set_cursor(y, x);
    text_clear_screen();
    text_show_cursor();
    color_setup(CLR_WHITE);

    while (1)
    {
        c = getchar();
        
        if (c == 27)
            break;

        if (c == '\n')
        {
            x = 0;
            y++;
        }
        else
        {
            text_write_char(c);
            x++;
            if (x >= 80)
                x = 79;
        }
        
        if (y >= 60)
        {
            text_clear_lines(60, 1);
            text_scroll(-1);
            y = 59;
        }

        text_set_cursor(y, x);
    }

    gdc_done();

    printf("\nEnd test of uPD7220\n");

    return 0;
}
