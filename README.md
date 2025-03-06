# hexdumpTool
Algoritmo:
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
