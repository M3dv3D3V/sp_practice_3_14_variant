#!/bin/bash

nasm -g -F dwarf -f elf64 -l $1.lst $1.asm

# ld -o output $1.o
# gcc -o output $1.o
gcc -m64 -o output $1.o -no-pie
# gcc -m64 -o output $1.o