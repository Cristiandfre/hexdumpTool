# HexDump Tool

## Description

HexDump Tool is a program written in **Assembly x86-64** that allows you to visualize the contents of a file in hexadecimal format along with its ASCII representation.

## Features

- Displays memory addresses in hexadecimal format (`00, 08, 10, 18, etc.`).
- Converts file bytes into their hexadecimal representation.
- Shows the ASCII equivalent of the bytes read.
- Efficient implementation using **Linux syscalls**.

## Screenshot (Example Output)
![Example](/home/slave/Pictures/hexdumptool.png)


## Algorithm

1. Reads from `stdin` into a buffer.
2. Processes the buffer:
   1. Reads one byte.
   2. Converts the lower nibble into a hexadecimal value.
   3. Converts the upper nibble into a hexadecimal value.
   4. Combines both nibbles into two hex values.
   5. Stores the hex result in a hex table.
   6. Repeats until the buffer is fully processed.
3. Sends output to `stdout`.
4. Repeats until `stdin` is completely processed.
5. Terminates.


