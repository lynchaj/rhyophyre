
To build using CMake:

First tune setup.sh to your Z88DK setup. Then

   $ source setup.sh
   $ mkdir build && cd build
   $ cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/z88dk.cmake ..
   $ make
