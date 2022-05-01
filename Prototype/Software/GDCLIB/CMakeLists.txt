
cmake_minimum_required(VERSION 3.10)

set(CMAKE_USER_MAKE_RULES_OVERRIDE "./cmake/overrides.cmake")

project(gdclib LANGUAGES C ASM VERSION 0.1)

enable_language(ASM)

include(./cmake/macros.cmake)

add_executable(koch koch.c gdc7220.c)
add_executable(d7220 d7220.c gdc7220.c)
add_executable(showpcx showpcx.c pcx.c gdc7220.c dma.c hbios.c hbios.h hbios.asm dma.h)

add_compile_flags(C
    +cpm
#    -compiler=sdcc
    -O2
    -Wall
    -I$ENV{Z88DK_HOME}/include
    -lmath48
    -DDEBUG=1
    --list
    # -debug
    # https://github.com/z88dk/z88dk/wiki/Classic-allocation#automatic-heap-configuration
)

add_compile_flags(ASM
    +cpm
        --list
)

add_compile_flags(LD
    -create-app
#    -subtype=rom
)

