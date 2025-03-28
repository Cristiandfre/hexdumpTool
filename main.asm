;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Build with: 
; nasm -f elf64 main.asm -o hexDump.o
; ld hexDump.o -o hexDump
;
; This program is still in progress
;

                                                        
                                                        ;31 es la cantidad exacta de bytes de show_table (incluido salto de linea), 
                                                        ;si colocamos mas que 31, en la proxima linea sera colocada informacion extra MAS la tabla show_table, mostrando mas informacion por linea 
SIZE equ 31                                             ;si colocamos menos que 31, el salto de linea no sera incluido al enviar a stdout, entonces todo sera colocado en una sola linea
                                                        ;Todo lo anterior aplica porque SIZE es usado tambien para definir la cantidad de bytes que enviamos a stdout
                                                        ;Este Equate no puede colocarse para definir la cantidad de bytes que se van a leer, porque ya se usa para definir cuantos bytes van a ser enviados a stdout (31 bytes porque la tabla tiene 31 bytes incluyendo el salto de linea del final). En la tabla se usan dos bytes para representar en hexadecimal un solo byte, existen 10 representaciones o posiciones, asi que debemos leer 10 bytes, un byte para cada una de esas posiciones.
SECTION .bss 

BufferIn resb 32                                        ;Espacio en bytes usado para almacenar stdin

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
        mov rdx, 10             ;Size of bytes for reading
        syscall

        ;Obtener bytes leidos
        xor rcx, rcx            ;Utilizamos rcx para almacenar los caracteres que vamos a enviar a stdout
        mov r9, rax             ;Guardamos la cantidad de bytes leidos por sys_read
        cmp r9, 0               ;Verificamos si ya alcanzamos el eof
        je exit                 ;Si es asi, terminamos y vamos a exit

    ;Alterar nibble alto en show_table
    mov r8, 0               ;Inicializamos un contador para contar bytes, en este caso r8
    mov r10, 2              ;Inicializamos un index para high nibble
    mov r15, 2              ;Inicializamos un index para low nibble

    getHexValue:
        xor r11, r11                        ;Inicializamos r11
        xor r12, r12                        ;Inicializamos r12
        xor r13, r13
        mov r11b, [BufferIn + r8]           ;Movemos un caracter leido a r11b
        mov r12b, r11b                      ;Movemos el caracter a r12 para guardar el low nibble
        mov r13b, r11b                      ;Movemos el caracter a r13 para guardar el high nibble
        and r12, 00001111b                  ;Nos quedamos con el low nibble                NOTA: importante usar b al final del numero binario o sino nasm lo toma como un numero diferente del binario y da problema
        shr r13b, 4                         ;Nos quedamos con el high nibble

    alterLowNibble:
        xor rcx, rcx                        ;Limpiamos rcx
        mov cl, [hex_table + r12]           ;r12 tiene el valor del low nibble del caracter
        mov byte [show_table + r10], cl     ;Movemos el valor traducido a la show_table para mostrar en stdout
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
        mov rdx, SIZE           ;Size of bytes for stdout           NOTA:Si alteramos SIZE, alteramos la cantidad de bytes que son enviados a stdout desde rsi, eso significa que si disminuimos SIZE, entonces el salto de linea no es incluido y por eso aparece todo en la misma linea
        syscall

        cmp r9, 0
        jne loadBuffer

    ;Exit
    exit:
        mov rax, 60             ;sys_call for sys_exit
        mov rdi, 0              ;return 0
        syscall                 


