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
        xor rcx, rcx             ;Utilizamos rcx para almacenar los caracteres que vamos a enviar a stdout
        mov r9, rax             ;Guardamos la cantidad de bytes leidos por sys_read
        cmp r9, 0               ;Verificamos si ya alcanzamos el eof
        je exit                 ;Si es asi, terminamos

    ;Alterar nibble alto en show_table
    mov r8, 1               ;Inicializamos un contador para contar bytes, en este caso r8
    mov r10, 2              ;Inicializamos un index para high nibble
    mov r15, 2              ;Inicializamos un index para low nibble

    getHexValue:
        xor r11, r11                        ;Inicializamos r11
        mov r11b, [BufferIn + r8]           ;Movemos un caracter leido a r11b
        mov r12b, r11b                      ;Movemos el caracter a r12 para guardar el low nibble
        mov r13b, r11b                      ;Movemos el caracter a r13 para guardar el high nibble
        ;and r12b, 00001111                  ;Nos quedamos con el low nibble
        shr r13b, 4                         ;Nos quedamos con el high nibble

    alterLowNibble:
        xor rcx, rcx                        ;Limpiamos rcx
        mov cl, [hex_table + r12]           ;r12 tiene el valor del low nibble del caracter
        mov byte [show_table + r10], 97     ;Movemos el valor traducido a la show_table para mostrar en stdout
        add r10, 3                          ;Avanzamos el index

    alterHighNibble:
        xor rcx, rcx                        ;Limpiamos rcx
        mov cl, [hex_table + r13]           ;r13 tiene el valor del high nibble del caracter
        mov byte [show_table + r15 - 1], cl ;Tiene que aumentar de 3 en 3 y restar uno porque sumando 3 y restando 1 se llega a la posicion, si sumaramos 2 caemos en los espacios
        add r15, 3                          ;Avanzamos el index
    
    ;Verificacion del loop
    inc r8                              ;Aumentamos el contador de bytes procesados
    cmp r8, r9                          ;Comparamos el contador de bytes (r8) con el numero de bytes por procesar (r9)
    jl getHexValue                      ;Si r8 < r9 aun falta para procesar el buffer

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




;FALTA POR ARREGLAR EL LOW NIBBLE

;INVESTIGAR
;Por que no pude usar los registres r9 y r8 para la memoria efectiva
;Por que estas instrucciones dan problema 
;mov bl, [hex_table + al]        ;Movemos el nibble bajo traducido a bl
;mov bh, [hex_table + ah] 


