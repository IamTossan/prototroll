%include        'utils/functions.asm'

SECTION .data
request     db      'GET / HTTP/1.1', 0Dh, 0Ah, 'Host: 139.162.39.66:80', 0Dh, 0Ah, 0Dh, 0Ah, 0h

SECTION .bss
buffer      resb    1

SECTION .text
global _start

_start:
    xor     eax, eax
    xor     ebx, ebx
    xor     edi, edi

_socket:
    push    byte 6              ; IPPROTO_TCP
    push    byte 1              ; SOCK_STREAM
    push    byte 2              ; PF_INET
    mov     ecx, esp
    mov     ebx, 1              ; subroutine SOCKET(1)
    mov     eax, 102            ; SYS_SOCKETCALL
    int     80h

_connect:
    mov     edi, eax
    push    dword 0x4227a28b    ; ip address: 139.162.39.66
    push    word 0x5000         ; port: 80
    push    word 2              ; AF_INET
    mov     ecx, esp
    push    byte 16             ; arg len
    push    ecx
    push    edi
    mov     ecx, esp
    mov     ebx, 3              ; subroutine CONNECT(2)
    mov     eax, 102
    int     80h

_write:
    mov     edx, 78
    mov     ecx, request
    mov     ebx, edi
    mov     eax, 4
    int     80h

_read:
    mov     edx, 1
    mov     ecx, buffer
    mov     ebx, edi
    mov     eax, 3              ; SYS_READ
    int     80h

    cmp     eax, 0
    jz      _close

    mov     eax, buffer
    call    sprint
    jmp     _read

_close:
    mov     ebx, edi
    mov     eax, 6              ; SYS_CLOSE
    int     80h

_exit:
    call    quit
