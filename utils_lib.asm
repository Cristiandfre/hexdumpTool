;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Build with: 
; nasm -f elf64 utils_lib.asm -o utils_lib.o
; 
;
section .data
newline db 10              ;char for new line
tab db '    '

section .text
global printnl
global printab

printnl:
    mov rax, 1              ;sys_call for sys_write
    mov rdi, 1              ;fd = stdout
    mov rsi, newline        ;char for new line
    mov rdx, 1              ;size of bytes
    syscall
    ret                     ;return for the caller

printab:
    mov rax, 1              ;sys_call for sys_write
    mov rdi, 1              ;fd = stdout
    mov rsi, tab            ;char for new line
    mov rdx, 1              ;size of bytes
    syscall
    ret                     ;return for the caller