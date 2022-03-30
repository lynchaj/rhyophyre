// foo.c

#include <stdio.h>



int main(int argc, char *argv[])
{
    printf("\nHello world!\n");
    printf("ARGC = %d\n", argc);
    if (argc==1) {
        unsigned char *i;
        i = (void*)0x80;
        argc = (int)*i;
        printf("string length = %d\n", argc);
    }
    else {
        while (argc--) printf(" %s", *argv++);
        printf("\n");
    }
    return 0;
}
