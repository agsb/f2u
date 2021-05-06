Notes about this

1. AVR Atmegas have a harvard architeture them flash program memory (flash) and static ram (sram) memory have different spaces. To access anything at flash must use lpm instruction, which only do words address, because all instructions are 16bits words. A atmega8 with 8k flash have really 4k words and access must do shifts to transform indirect references;
2. How to keep chars (1 byte) in dictionary at flash for use of c! and c@ and c, ? Don't do, keep all in words, low byte is char and clear high byte. How to keep chars (1 byte) in static memory ? as bytes :)
4. Times for POP/PUSH with SP as same of LD/ST with Z, Y, X registers, so I decide use Y as return stack and X as parameter stack, leaving Z for access flash and sram.
5. Also no use CALL and RET, leaving SP for interrupts and tasks stuff.
6. No need to have a complete ANS Forth in such small MCU, then trimmed almost stuff to essentials and funny :)
7. No need for speed, but to try a concept of a immutable dictionary, no assembler instructions into dictionary.
8. I made a bag of notes from many implementations of eforth, amforth, flashforth, jonasforth, sectorforth, cmforth and etc, to learn about how it resolve issues of CPU, MCU, memory models, protocols, devices, speed, and do not reinvent the wheel.
9. for dictionary struture, and vocabularies: a) unique LINK+NAME+CODE+PARAMETERS; b) link is the reference for previous word and is NULL at end of linked list; c) names are counted strings, with length of 1 to 15 7bit ASCII and 4 bit flags in counter byte (first one); d) CODE and PARAMETERS are implementation dependent at next section
10. All forth constants are in flash and all forth variables are at top of sram
11. A memory model for forth f2u in Atmega8 SRAM is sram_init = 0x060, variables, parameter stack 20 cells, return stack 20 cells, tib buffer 72 bytes, pad 72 buffer bytes, free, stack pointer 20 cells, sram_end = 0x45F.
12. Why 72 ? because " Column 72 means Continue ", old IBM punch cards uses 80 columns wich last 8 are for sequence numbers. 

in https://github.com/cesarblum/sectorforth revival of https://groups.google.com/g/comp.lang.forth/c/NS2icrCj1jQ

