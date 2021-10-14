 Notes about this

*still not operational*

**14/10/2021**

"Finally I understood that Charles Moore invents both BL and BLR instruction in late 1970's"

I found a bottleneck with >R and R> words, as those uses the return stack and also any compound word, that uses docolon and semmis. But the solution is unique and easy, just do no use any compound word between >R and R> .

The most undervalued feature of Forth is the IP register. It performs exactly as modern instructions BL and BLR, keeping in a register the next address at queue, for routines that do not use any call inside.

Then all primitives words uses just IP as cursor for queue while all compound words uses return stack for queue.

Minor changes done to internal interpreter also a new pair of registers reserved for  preserve  IP.

refactoring the inner interpret to satisfy both call/return and branch/link styles.

refactoring macros and memory reserved variables


**25/05/2021**

"Another way to look at the problem is to state that the language of the standard does not match any Forth implementations except cmForth and Gforth. "  http://www.mpeforth.com/arena/SpecialWords3.pdf

My solution for the flash-sram dilema is implement a buffer where all compiled goes and does flash, to init, and flush, to update, from sram to flash memory, disgards many implementations, lenght is from heap of memory and all variables are allocated from bottom.

about postpone, compile, execute, :
  postone implemented as a new status at STATE variable, valid only for next word, were any word is compiled.
  then interpret works as:
  
           state of interpret: COMPILE   EXECUTE   POSTONE
    at common word does        compile   execute   compile
    at immediate word  does    execute   execute   compile
    
    
24/05/2021
    
    Done comma, flash, flush for solve sram//flash

    implemented postpone as a flag to always compile next word only, solves compile and [compile]
    
    matriz of interpret now is:

                            state 1        state 0        postone 1
         common word        compile        execute        compile
      immediate word        execute        execute        compile
    
    why not same for  ', [']

19/05/2021

    Rewrite for plain use of sram as buffer for flash, 

02/05/2021

    Rewrite again using sectorforth as minimal design

18/04/2021

    Rewrite all from u2f*, using a new minimal forth engine as LAST word 


    
**12/05/2021**

For simplicity all programming of flash memory is made with common tools and the boot monitor is MiniCore, with optiboot of 512 bytes. 

Optiboot version 8.0 does program flash memory, as do_spm, modified from <avr/boot.h>, it uses r0:r1, r30:r31, r20, r22, r24

For use do_spm, need a routine to read a page from flash into sram, update bytes at sram, then write a page from sram into flash, using do_spm. Maybe keep ever the "next" page (64 bytes) in sram, and write when full.

**pre 10/05/2021**

AVR Atmegas have a harvard architeture them flash program memory (flash) and static ram (sram) memory have different spaces. To access anything at flash must use lpm instruction, which only do words address, because all instructions are 16bits words. A atmega8 with 8k flash have really 4k words and access must do shifts to transform indirect references;

How to keep chars (1 byte) in dictionary at flash for use of c! and c@ and c, ? Don't do, keep all in words, low byte is char and clear high byte. How to keep chars (1 byte) in static memory ? as bytes :)

Times for POP/PUSH with SP as same of LD/ST with Z, Y, X registers, so I decide use Y as return stack and X as parameter stack, leaving Z for access flash and sram.

Also no use CALL and RET, leaving SP for interrupts and tasks stuff.

No need to have a complete ANS Forth in such small MCU, then trimmed almost stuff to essentials and funny :)

No need for speed, but to try a concept of a immutable dictionary, no assembler instructions into dictionary.

I made a bag of notes from many implementations of eforth, amforth, flashforth, jonasforth, sectorforth, cmforth and etc, to learn about how it resolve issues of CPU, MCU, memory models, protocols, devices, speed, and do not reinvent the wheel.

for dictionary struture, and vocabularies: a) unique LINK+NAME+CODE+PARAMETERS; b) link is the reference for previous word and is NULL at end of linked list; c) names are counted strings, with length of 1 to 15 7bit ASCII and 4 bit flags in counter byte (first one); d) CODE and PARAMETERS are implementation dependent at next section

All forth constants are in flash and all forth variables are at top of sram

A memory model for forth f2u in Atmega8 SRAM is sram_init = 0x060, variables, parameter stack 20 cells, return stack 20 cells, tib buffer 72 bytes, pad 72 buffer bytes, free, stack pointer 20 cells, sram_end = 0x45F.

Why 72 ? because " Column 72 means Continue ", old IBM punch cards uses 80 columns wich last 8 are for sequence numbers. 

Classic forths complements dictionary with words defined in blocks or files, that can be read and write with external access;

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

** ENGINES **

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
    
    
in https://github.com/cesarblum/sectorforth a revival of https://groups.google.com/g/comp.lang.forth/c/NS2icrCj1jQ

in https://guides.github.com/features/mastering-markdown/
