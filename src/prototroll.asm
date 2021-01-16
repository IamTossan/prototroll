%include        'utils/functions.asm'

SECTION .rodata
    SYS_FORK            equ 2
    SYS_READ            equ 3
    SYS_WRITE           equ 4
    SYS_CLOSE           equ 6
    SYS_SOCKETCALL      equ 102

    SKT_SOCKET          equ 1
    SKT_BIND            equ 2
    SKT_LISTEN          equ 4
    SKT_ACCEPT          equ 5

    PF_INET             equ 2
    SOCK_STREAM         equ 1
    IPPROTO_TCP         equ 6
    AF_INET             equ 2

SECTION .data
    invite      db      'Say something: ', 0h

SECTION .bss
    buffer      resb    255

SECTION .text
global _start

_start:
    xor     eax, eax
    xor     ebx, ebx
    xor     edi, edi
    xor     esi, esi

_socket:
    push    byte IPPROTO_TCP
    push    byte SOCK_STREAM
    push    byte PF_INET
    mov     ecx, esp
    mov     ebx, SKT_SOCKET
    mov     eax, SYS_SOCKETCALL
    int     80h

_bind:
    mov     edi, eax
    push    dword 0x00000000    ; ip address: 0.0.0.0
    push    word 0x2923         ; port: 9001
    push    word AF_INET
    mov     ecx, esp
    push    byte 16             ; arg len
    push    ecx
    push    edi
    mov     ecx, esp
    mov     ebx, SKT_BIND
    mov     eax, SYS_SOCKETCALL
    int     80h

_listen:
    push    byte 1              ; max queue len argument
    push    edi
    mov     ecx, esp
    mov     ebx, SKT_LISTEN
    mov     eax, SYS_SOCKETCALL
    int     80h

_accept:
    push    byte 0              ; address len argument
    push    byte 0              ; address argument
    push    edi
    mov     ecx, esp
    mov     ebx, SKT_ACCEPT
    mov     eax, SYS_SOCKETCALL
    int     80h

_fork:
    mov     esi, eax
    mov     eax, SYS_FORK
    int     80h

    cmp     eax, 0
    jz      _writeInvite

    jmp     _accept

_writeInvite:
    mov     edx, 16
    mov     ecx, invite
    mov     ebx, esi
    mov     eax, SYS_WRITE
    int     80h

_cleanBuffer:
    mov     ebx, 255
    mov     ecx, 0

.loopStart:
    mov     byte[buffer+ecx], 0h

    cmp     ecx, ebx
    je      _read

    inc     ecx
    jmp     .loopStart

_read:
    mov     edx, 255
    mov     ecx, buffer
    mov     ebx, esi
    mov     eax, SYS_READ
    int     80h

    mov     eax, buffer
    call    sprint

_write:
    mov     edx, 78
    mov     ecx, buffer
    mov     ebx, esi
    mov     eax, SYS_WRITE
    int     80h

    jmp     _writeInvite

_close:
    mov     ebx, esi
    mov     eax, SYS_CLOSE
    int     80h

_exit:
    call    quit
