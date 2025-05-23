;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Build with: 
; nasm -f elf64 main.asm -o hexDump.o
; ld hexDump.o utils_lib.o -o hexDump
;
; This program is still in progress
;

SECTION .bss 

BufferIn resb 32                                ;Espacio en bytes usado para almacenar stdin
                           

SECTION .data 

address_table db "00000000"
hex_table db "0123456789ABCDEF"
show_table db " 00 00 00 00 00 00 00 00",10
ascii_table db " ..........",10


SECTION .text 
extern printnl
extern printab

global _start
_start:
    push 0                      ;Para contar los bytes en el archivo y mostrarlo como direcciones

    ;Leer de stdin
    loadBuffer: 
        mov rax, 0              ;sys_call for sys_read 
        mov rdi, 0              ;fd = stdin
        mov rsi, BufferIn       ;*Buffer
        mov rdx, 8              ;Size of bytes for reading                          Nota: son 10 bytes porque show_table tiene 10 posiciones "00" donde se colocara cada byte
        syscall

        ;Obtener bytes leidos
        xor rcx, rcx            ;Utilizamos rcx para almacenar los caracteres que vamos a enviar a stdout
        mov r9, rax             ;Guardamos la cantidad de bytes leidos por sys_read
        cmp r9, 0               ;Verificamos si ya alcanzamos el eof
        je exit                 ;Si es asi, terminamos y vamos a exit

    
    ;Mostrar direcciones de bytes
    pop rax                 ; Buscamos el contador de bytes para las direcciones
    mov r10, rax            ; Guardamos el contador en r10 para evitar perderlo al tratar rax
    mov rsi, 7              ; Posición donde colocar el dígito más bajo
    mov rcx, 16

    .hex_loop:
        xor rdx, rdx
        div rcx             ; Divide rax / 16 => rax=quotient, rdx=remainder
        mov bl, [hex_table + rdx] ; convierte dígito a carácter
        mov [address_table + rsi], bl
        dec rsi             ; mover a la izquierda en el buffer
        cmp rax, 0
        jne .hex_loop



        showAddressTable:
            mov rax, 1                  ;sys_call for sys_write
            mov rdi, 1                  ;fd = stdin
            mov rsi, address_table      ;*Buffer
            mov rdx, 8                  ;Size of bytes for writing
            syscall
            call printab

        add r10, 8            ;Adicionamos 8 para indicar que ya avanzamos 8 bytes en las direcciones de bytes
        push r10              ;Y guardamos esa contagem en el stack

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
        mov rax, r9             ;Movemos el numero de bytes, leidos por sys_read de stdin, a rax  
        mov rcx, 3              ;Movemos 3 a rcx (cada byte leido y colocado en show_table equivale a 3 bytes de show_table)
        mul rcx                 ;Multiplicamos rcx por rax, o sea, r9*3
        mov r14, rax            ;Colocamos en r14 el resultado
        inc r14                 ;Incrementamos en uno para contar el salto de linea de show_table (cuando llegue a la ultima linea, si esta es menor que 10 bytes, entonces este incremento no contara el salto de linea, pero contara un espacio, el espacio que pertenece a los siguientes 3 bytes que representan un byte hexadecimal, lo cual es util tambien mostrar ese espacio)
        
        mov rax, 1              ;sys_call for sys_write
        mov rdi, 1              ;fd = stdout
        mov rsi, show_table     ;*show_table 
        mov rdx, r14            ;Size of bytes for stdout           NOTA:Si alteramos SIZE, alteramos la cantidad de bytes que son enviados a stdout desde rsi, eso significa que si disminuimos SIZE, entonces el salto de linea no es incluido y por eso aparece todo en la misma linea
        syscall

        call printnl            ;Imprimimos una linea nueva para bajar lo que venga a seguir

        cmp r9, 0
        jne loadBuffer

    ;Exit
    exit:
        mov rax, 60             ;sys_call for sys_exit
        mov rdi, 0              ;return 0
        syscall                 


