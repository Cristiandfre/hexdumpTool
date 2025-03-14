;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Build with: 
; nasm -f elf64 main.asm -o hexDump.o
; ld hexDump.o -o hexDump
;
; This program is still in progress
;


SIZE equ 32

SECTION .bss 

BufferIn resb 32

SECTION .data 

hex_table db "0123456789ABCDEF"
show_table db " 00 00 00 00 00 00 00 00 00 00",10


SECTION .text 

global _start
_start:
    ;Leer de stdin
    loadBuffer: 
        mov rax, 0              ;sys_call for sys_read 
        mov rdi, 0              ;fd = stdin
        mov rsi, BufferIn       ;*Buffer
        mov rdx, SIZE           ;Size of bytes for reading
        syscall

        ;Obtener bytes leidos
        mov r9, rax             ;Guardamos la cantidad de bytes leidos por sys_read
        cmp r9, 0               ;Verificamos si ya alcanzamos el eof
        je exit                 ;Si es asi, terminamos

    ;Alterar nibble alto en show_table
    mov r8, 1               ;Inicializamos un contador para contar bytes, en este caso r8
    mov r10, 2              ;Inicializamos un index

    alterHighNibble:
        mov byte [show_table + r10], 97
        add r10, 3                          ;Avanzamos el index
        inc r8                              ;Aumentamos el contador de bytes procesados
        cmp r8, r9                          ;Comparamos el contador de bytes (r8) con el numero de bytes por procesar (r9)
        jl alterHighNibble                  ;Si r8 < r9 aun falta para procesar el buffer

    ;Alterar nibble baja en show_table
    mov r8, 1
    mov r10, 1

    alterLowNibble:
        mov byte [show_table + r10], 98
        add r10, 3                          ;Avanzamos el index
        inc r8                              ;Aumentamos el contador de bytes procesados
        cmp r8, r9                          ;Comparamos el contador de bytes (r8) con el numero de bytes por procesar (r9)
        jl alterLowNibble                   ;Si r8 < r9 aun falta para procesar el buffer

    ;Mostrar stdin 
    showBuffer:
        mov rax, 1              ;sys_call for sys_write
        mov rdi, 1              ;fd = stdout
        mov rsi, show_table     ;*show_table 
        mov rdx, SIZE           ;Size of bytes for stdout
        syscall

    ;Exit
    exit:
        mov rax, 60             ;sys_call for sys_exit
        mov rdi, 0              ;return 0
        syscall                 





;INVESTIGAR
;Por que no pude usar los registres r9 y r8 para la memoria efectiva
;Por que estas instrucciones dan problema 
;mov bl, [hex_table + al]        ;Movemos el nibble bajo traducido a bl
;mov bh, [hex_table + ah] 


