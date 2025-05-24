# HexDump Tool

## Descripción

HexDump Tool es un programa escrito en **Assembly x86-64** que permite visualizar el contenido de un archivo en formato hexadecimal y ASCII, mostrando las direcciones de memoria correspondientes. Se ejecuta redirigiendo la entrada estándar mediante `< archivo.txt`.

## Características

- Muestra las direcciones de memoria en formato hexadecimal (`00, 08, 10, 18, etc.`).
- Traduce los bytes del archivo a su representación hexadecimal.
- Presenta la versión ASCII de los bytes leídos.
- Implementación eficiente utilizando **syscalls** de Linux.

## Captura de pantalla (Ejemplo de salida)



## Algoritmo
1. Lee de stdin hacia un buffer
2. procesa el buffer:
    1. Lee un byte
    2. Traduce el nibble inferior en un valor hex
    3. Traduce el nibble superior en un valor hex
    4. Junta ambos nibbles en dos valores hex
    5. El resultado hex lo envia para una table hex
    6. Repite hasta que el buffer este procesado
3. Envia para stdout
4. Repite hasta que stdin este procesado 
5. Termina 

