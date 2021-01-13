%include        'utils/functions.asm'

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
    push    byte 6              ; IPPROTO_TCP
    push    byte 1              ; SOCK_STREAM
    push    byte 2              ; PF_INET
    mov     ecx, esp
    mov     ebx, 1              ; subroutine SOCKET(1)
    mov     eax, 102            ; SYS_SOCKETCALL
    int     80h

_bind:
    mov     edi, eax
    push    dword 0x00000000    ; ip address: 0.0.0.0
    push    word 0x2923         ; port: 9001
    push    word 2              ; AF_INET
    mov     ecx, esp
    push    byte 16             ; arg len
    push    ecx
    push    edi
    mov     ecx, esp
    mov     ebx, 2              ; subroutine BIND(2)
    mov     eax, 102
    int     80h

_listen:
    push    byte 1              ; max queue len argument
    push    edi
    mov     ecx, esp
    mov     ebx, 4              ; subroutine LISTEN(4)
    mov     eax, 102
    int     80h

_accept:
    push    byte 0              ; address len argument
    push    byte 0              ; address argument
    push    edi
    mov     ecx, esp
    mov     ebx, 5              ; subroutine ACCEPT(5)
    mov     eax, 102
    int     80h

_fork:
    mov     esi, eax
    mov     eax, 2              ; SYS_FORK
    int     80h

    cmp     eax, 0
    jz      _writeInvite

    jmp     _accept

_writeInvite:
    mov     edx, 16
    mov     ecx, invite
    mov     ebx, esi
    mov     eax, 4
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
    mov     eax, 3              ; SYS_READ
    int     80h

    mov     eax, buffer
    call    sprintLF

_write:
    mov     edx, 78
    mov     ecx, buffer
    mov     ebx, esi
    mov     eax, 4
    int     80h

    jmp     _writeInvite

_close:
    mov     ebx, esi
    mov     eax, 6              ; SYS_CLOSE
    int     80h

_exit:
    call    quit
