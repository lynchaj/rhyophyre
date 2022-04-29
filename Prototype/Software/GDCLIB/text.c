#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gdc7220.h"

const char * usage =
    "Usage: TEXT <options>\n"
    "    -i            - interactively echo keys typed to display\n"
    "    -f <filename> - type file to display\n"
    "    -t            - show character test pattern and exit\n"
    "    -d            - add delay between char writes\n"
    "    -h            - display help\n"
    "\n"
    "TEXT sends text output to the uPD7220 display.\n"
    "It will display a test pattern (-t), echo typed\n"
    "keyboard input (-i), or display file contents (-f).\n"
    "The following special keys are accepted:\n"
    "    ctrl-A         - reverse linefeed\n"
    "    ctrl-B         - switch to next color\n";
    
    
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
    uint8_t cur_color;
    char filename[80] = "";
    int interactive = 0;
    int testpat = 0;
    int usedelay = 0;
    int showusage = 1;
    uint32_t start;
    uint16_t charcount = 0;
    uint16_t scrollcount = 0;

    const char *optstring = "F:TDHI";

    while ((ch = getopt(argc, argv, optstring)) != -1)
    {
        switch (ch)
        {
            case 'F':
                strcpy(filename, optarg);
                interactive = 0;
                showusage = 0;
                break;
            
            case 'I':
                interactive = 1;
                showusage = 0;
                break;

            case 'T':
                testpat = 1;
                showusage = 0;
                break;
            
            case 'D':
                usedelay = 1;
                break;
                
            case 'H':
                showusage = 1;
                break;
        }
    }
    
    
    printf("uPD7220 Text Display Tool (use -H for help)\n\n");

    if (showusage)
    {
        printf(usage);
        exit(0);
    }

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
    
    if (testpat)
    {
        printf("Displaying character test pattern...\n");
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
        
        exit(0);
    }
    
    FILE *fp;
    if (interactive)
    {
        fp = stdin;
        freopen(NULL, "rb", stdin);
        printf("Type stuff on CP/M console (ctrl-Z to end)...\n");
    }
    else
    {
        if (!(fp = fopen(filename, "rb")))
        {
            printf("ERROR: File %s could not be opened!\n", filename);
            exit(1);
        }
        printf("Typing file %s to display...\n", filename);
    }

    x = y = 0;
    text_set_cursor(y, x);
    text_clear_screen();
    text_show_cursor();
    cur_color = CLR_WHITE;
    color_setup(cur_color);

    start = get_ticks();
    
    // text_hide_cursor();

    while ((ch = getc(fp)) != EOF)
    {
        if (ch == 26)   // ctrl Z - EOF
            break;
        
        if (usedelay)
            delay(2500);
        
        text_hide_cursor();

        switch(ch)
        {
            case 1:     // ctrl A - reverse linefeed
                y--;
                break;
            
            case 2:     // ctrl B - next color
                cur_color = ++cur_color % 16;
                color_setup(cur_color);
                break;
                
            case 8:     // backspace
                x--;
                break;
                
            case 10:    // linefeed
                y++;
                break;
            
            case 13:    // return
                x = 0;
                break;
            
            default:
                text_write_char(ch);
                charcount++;
                x++;
                break;
        }
        
        if (x < 0)
            x = 0;
        if (x >= 80)
        {
            x = 0;
            y++;
        }
        if (y < 0)
        {
            text_clear_lines(-1, 1);
            text_scroll(1);
            scrollcount++;
            y = 0;
        }
        if (y >= 60)
        {
            text_clear_lines(60, 1);
            text_scroll(-1);
            scrollcount++;
            y = 59;
        }
        
        text_set_cursor(y, x);
        
        text_show_cursor();
    }
    
    printf("\nTicks = %ld, Character Count = %d, Scroll Count = %d\n",
            get_ticks() - start, charcount, scrollcount);

    fclose(fp);

    return 0;
}
