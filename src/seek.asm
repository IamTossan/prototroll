%include        'utils/functions.asm'

SECTION .data
filename    db      'readme.txt', 0h
contents    db      '-updated-', 0h

SECTION .text
global _start

_start:
    mov     ecx, 1
    mov     ebx, filename
    mov     eax, 5
    int     80h

    mov     edx, 2
    mov     ecx, 0
    mov     ebx, eax
    mov     eax, 19
    int     80h

    mov     edx, 9
    mov     ecx, contents
    mov     ebx, ebx
    mov     eax, 4
    int     80h

    call    quit
