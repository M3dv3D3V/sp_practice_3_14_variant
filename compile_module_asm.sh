

nasm -f elf64 $2.asm -o $2.o 

g++ $1.cpp $2.o -no-pie  -o output