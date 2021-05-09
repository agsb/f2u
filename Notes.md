Notes about this


"In 328eForth, I chose to address flash memory in bytes, so that it is easier to move
data between flash memory and RAM memory. Although ATmega328P execute
code in 16 bit cells, when you read and write the flash memory, you actually have to
use byte addresses in the Z register, and it is natural to use byte addresses to move
data in or out the flash memory. Therefore, in 328eForth all flash addresses are byte
addresses. Only when executing a command, its execution address in bytes is
converted to a cell address. When you retrieve an address from flash memory or
from the return stack, you have to convert it from a cell address to a byte address
before operating on it." Dr. C. H. Ting, 
ForthArduino_1.pdf, http://forth.org/OffeteStore/2159_328eforth.zip


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
13. Classic forths complements dictionary with words defined in blocks or files, that can be read and write with external access;
14. for simplicity all programming of flash memory is made with common tools and the boot monitor is MiniCore, with optiboot of 512 bytes. 

Codes and Parameters
  the code field holds "what to do" for the inner interpreter and in classic forth can be one of: 
     _nest, push instruction point into return
     _unest, pull instruction point from return
     _exec, jump to next cell 
     _exit, do _unest, do exec
     _dolit, copy next cell to data, advance two cells
  
    im most forths those are specific inline opcodes 
    
    Since f2u intents a concept of immutable dictionary without inline code, the inner engine only see cells as references with one exception, if a cell reference is 0x0 then next cell is a reference to a leaf, to be executed.
    this makes possible no need of CODE in dictionary but costs a comparation and a test at each reference, about 2 cycles in a AVR. the dictionary then is like:
    
    a leaf 0x0000, reference for a primitive.
    a twig reference, reference, ..., reference, _inner_
    yes, _inner_ is a reference to the forth inner engine that does all work,
    
    the dictionary order does not matter, but is more easy for future ports that all primitives precede all compounds;
    then to port for other MCU or CPU, just rewrote the engine and primitives, change the references of primitives at dictionary and done.
    
      boot+bios+forth+more where 
      boot, setup at boot or reset; 
      bios, routines for input and output devices, 
      forth, code for inner and primitives, 
      more, all forth dictionary immutable.
    
    
in https://github.com/cesarblum/sectorforth revival of https://groups.google.com/g/comp.lang.forth/c/NS2icrCj1jQ

in https://guides.github.com/features/mastering-markdown/
