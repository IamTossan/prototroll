#!/bin/sh

# validation
set -e
if [ $# -lt 1 ]
then
  echo "usage: ./start SOURCE_FILE [ARGS...]"
  exit 1
fi

mkdir -p dist

name=$(echo "$1" | cut -d'.' -f1| cut -d'/' -f2)
shift

# compile
nasm -f elf "src/$name.asm" -o "dist/$name.o"
ld -m elf_i386 "dist/$name.o" -o "dist/$name"

# execute
"dist/$name" $@

# cleanup
rm dist/*
