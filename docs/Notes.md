# Notes about this

*still not operational*

*still lots of english errors, please correct me*

# 16/11/2022

- Atmega8 flash almost full ~ 3604 words ~ and still not a complete usefull set of word, then time to change all setup to atmega328

- most of core words done as pre-compiled assembler references.

- review of memory model (again!), to easy compile in sram using address of flash, two pointers DP in flash and HP in sram, keep offset constant.
  
          SRAM   |0x0 registers |0x20 ioports |0x100=HP0 --- free sram --- | <-- UP0=| <-- VARS -- |=TIB0 -->  | <-- PS0=| <-- RS0=| <-- SP0=|
          FLASH  |0x0 bios | Forth dictionary |=DP --> RWM --> | NRWM optiboot |
          EEPROM |0x0 keep variables | --> |

- concept of indirect data reference, as Harvard architeture, variables and values are stored in sram, the dictionary keeps a reference for where the value is, not the value as is.

# 12/11/2022

- made for new flags, 0x80 is F_RESERVED, to identify the byte size+flags,
    0x40 is IMMEDIATE, 0X20 is COMPILE_ONLY, 0x10 is HIDDEN. 

- start of eeprom stuff, forth variables load/save and constants,
    yet not complete

- changed, again, the internal names and order of forth variables

- eeprom and io/ports, C@E, C!E, C@P, C!P, @E, !E, @P, !P, 
    using prefix C for byte, D for double, 
    and sufix E for eeprom, P for IO ports
    ( sram is default and no still no flash stuff)

# 10/11/2022

- all pre-compiled compound words use direct BRANCH and ZBRANCH for jumps

- review of all code, reduce to only 4 calls in do_spm routine

# 07/11/2022

- future: review of byte for size and flags. Size still 1 to 15, usually good for almost 
    all words, Flags changed, 0x80 marks the byte it self as size-flag, 
    0x40 is IMMEDIATE, 0X20 is COMPILE_ONLY, 0x10 is HIDDEN. 
    why ? FOr easy translate BODY> and <BODY, NAME> 

- review of all words, tricks about specifics ISA for atmega8 or atmega328

# 05/11/2022

- future: review, shrink, replace " pull tos_low, tos_high; POON; " with rjmp DROP

- do all work in sram, when compile done use flash do write.

# 02/11/2022

- bring back UM+ ( w1 w2 -- w3 c) 

- review of BRANCH and 0BRANCH. No more relative offsets, as in GForth all address to be absolute. BRANCH is R> @ >R  

- review of DOCON and DOVAR, LIT as standart, and : LIT >R DUP CELL+ >R ; and : DOVAR LIT ; and : DOCON LIT @ ; and : DOTO LIT ! ;

- fix for simply (accept) (parse) (word) (eval)

# 30/10/2022

- include non standart words HOOK and BACK, as " ~~~ WORD ~~~ IF ~~~ WORD; THEN ~~~ ", cited by Moore in http://www.ultratechnology.com/1xforth.htm, these words uses return stack to preserve where to go.

- review of all stacks, now order is SP0, RS0, PS0, all with 18 words and growing backwards from SRAM_END, as AVR default

- review of flash write strategy, no reserved buffer, just compile to sram and write when got a flash command FLASH, PAD will be at 18 bytes from end of TIB for link+size+name 

- bad. terrible day for my country, the convicted nine was elected.

# 28/10/2022

- review of inner interpreter code, optimize code, link and jump as background

- review for try compliance to DPANS-94, ANSI  

- rewrite core functions to use return stack only

# 16/10/2022

- return to f2u for review of flush flash memory, the optiboot crew leaves the solution at plainsight

- using a direct call for boot_rww_enable_short() in version 8.3 does spm instruction free and easy

- review of flush.S

- review for use of variables and sram and headshake to renameds

# 18/07/2022

- pause on immu (riscv eitc forth code)

- doing a review for atmega328, still changing/remapping the address of flash and sram

- doing tests with MiniCore spm.

- no more reserving any register for extras, using spare registers to hold values to avoid stack push/pop 

# 11/11/2021

- review of POSTPONE, before many tests and simulations, sure classic behavior is better. Droped all changes for STATE stuff with POSTPONE as flag.

- review of all variables as a continous array at bottom of ram, starting above tib and stacks, and growing downwards  memory

- a lot of precompiled forth internal words, primitives for cmove, bmove, cfill, cscan, cfind, and coumpounds for outer interpreter

- doing IMMU stuff also.

# 04/11/2021

- Finaly agree to created C@ and C!, but only in SRAM, for buffer I/O

- Using internal names of DOVAR and DOCON, for COMP and DOLIT

- Review of code in branch 'neck', using Tos in r24:r25, return stack in X, data stack in Y, memory access with Z. 

    Overall improved with less pulls and pushes, about 1200 bytes less code and proportional more speed, and could be improved ;)

    Not using Tos in register r24:r25
    
        Size after:
        main.elf  :
        section     size      addr
        .text       4920         0
        .data          0   8388704
        data         120         0
        .avr.prop   3068         0
        Total       8108
    
    Using a Tos in register r24:r25
    
        Size after:
        main.elf  :
        section     size      addr
        .text       3696         0
        .data          0   8388704
        data         120         0
        .avr.prop   2575         0
        Total       6391


# 30/10/2021

- A simple algorithm to flush flash pages, based in the address to write and flash buffer page, a write into a new page forces to save old page and to load new page. Done with assembler functions for !!, flush_flash, load_flash, save_flash, do_spm_stuff.

- revised code for branchs

# 26/10/2021

- Change branch to use offsets instead of absolute addresses, as in original fig-forth

- Change C! and C@, as really one byte in low register and high register goes zero.

- Emulated [branch and link], [call and return], indirect thread code working.

- meta compiler and cross compiler, can run inside a emulator ?

- to simplifly implementations for other MCU or CPU, maybe use a trampoline with primitives references. the Forth dictionary starts down of a table of jumps to primitive routines, incurrs one step more. primitives will be 0x0, 0xidx, and idx is a index for table. All dictionary will be clean of code ! Also implementations will do "interrupt vector", "bios routines", "primitives routines", then a trampline table, and somewhere (fixed?) all forth dictionaries. Eg. a DUP will be always a 0x0 followed by 0x05, index to jump to 5th address of trampoline table. All references could be rellocable of position independent.

- testing with a precompiler in C, define a table of primitives, and parse Forth files to generate binary dump of references and names.

# 21/10/2021

- created a docs directory for all md files and examples.

- rewrite some md files

- remap registers use and restrict r0::r7

- start compound words file, from avalible sources of forth 

- simplifly use of terminal input buffer, by assume that all line edit is done at remote. Just a static line. Works as a screen or block, just receives a line till a CR or LF or CR LF. Still accept BS, ESC, for minimal edit and could use XON, XOFF, handshake control.

- refactoring all flush flash stuff to use optiboot, <https://github.com/Optiboot/optiboot> version 8.2, routine do_spm, bulletproof for do not reinvent wheel.

- the use do_spm is hack inside standart call to a C function from gcc compiler, then a rcall is used. Nice have a SP and stack availabe. 
# 15/10/2021

- rewrite of MemoryModel, with buffers, constants, variables, stacks, etc

- start to review of EPROM, SRAM and FLASH uses, memory maps, and easy variables allocation;

- start to review of how to do dual buffer, sram to flash, flash to sram, flush sizes, etc.

- note to self: Need better understand those .md format codes.

- note to self: I disagree any word that ends with a comma (,) or dot (.) else comma (,) and (.).

- todo: CREATE, <BUILDS, DOES>, DEFER, IS, ASSIGN, TO, VALUE,  

# 14/10/2021

\"Finally I understood that Charles Moore invents both BL and BX instructions in late 1970's\", or not really maybe.

- I found a possible bottleneck with >R and R> words, as those uses the return stack and also any compound word, that uses docolon and semmis. But the solution is unique and easy, just use balanced >R and R> inside the word. Any word. (thanks to poralexc for point it, reddit, r/forth, 2021/10)

- The most undervalued feature of Forth is the IP register. It performs exactly as modern instructions BL and BX, keeping in a register the next address at queue, for routines that do not use any call inside.

- Then all primitives words uses just IP as cursor for queue while all compound words uses return stack for queue. It saves stack depth.

- Minor changes done to internal interpreter also a new pair of registers reserved for preserve IP.

- using eprom as a safe, for keep variables between boots.

- refactoring the inner interpret to satisfy both call/return and branch/link styles.

- refactoring macros and memory reserved constants and variables.

- refactoring eprom use for load and save addresses for turnkey, seed, last, here, eram and erom 

- words can be 1 to 15 chars lenght, almost over for normal english words http://norvig.com/mayzner.html

- todo: someday, must unify call "data or parameter or argument" stack in all texts.

# 10/06/2021 

- The basic functional words are done, as minimal set for parse, find, evaluate, number, create, does;
    
- *standart implementation*
(if ... else ... then ...), forward jumps, (1)
(begin ... again), inconditional backward jump, (2)
(begin ... until), conditional backward jump, (2)

- *non-standart implementation* trying!
(while ... repeat), conditional forward jump and inconditional  backward jump, (3)
(while ... again), maybe ?
att: *repeat jumps to while*, both independent of begin.

- Testing values on return stack *not for now* 
why not variables I, J, K ? I dont like using return stack for loops.
(do ... leave ... loop), counter backward jump, test at loop
(for ... next), counter backward jump, test at for

# 25/05/2021

\"Another way to look at the problem is to state that the language of the standard does not match any Forth implementations except cmForth and Gforth.\"  http://www.mpeforth.com/arena/SpecialWords3.pdf

- My solution for the flash-sram dilema is implement a buffer where all compiled goes and does flash, to init, and flush, to update, from sram to flash memory, disgards many implementations, lenght is from heap of memory and all variables are allocated from bottom.

- About postpone, compile, execute, :
postone implemented as a new status in the STATE variable, valid only for the next word, in which any word must be compiled, then outer interpret works as:
  
    | state of interpret: |       COMPILE |   EXECUTE |   POSTPONE |
    | at common word does |       compile |   execute|   compile |
    | at immediate word does |    execute |   execute |   compile |
    
    
# 24/05/2021
    
- Done comma, flash, flush for solve sram//flash, not tested

- implemented postpone as a flag to always compile next word only, solves compile and [compile], etc

# 19/05/2021

- Rewrite for plain use of sram as buffer for flash, trying.

# 02/05/2021

- Rewrite again using sectorforth as minimal design

# 18/04/2021

- Rewrite all from u2f*, using a new minimal forth engine as LAST word 

    
# 12/05/2021

- For simplicity all programming of flash memory is made with common tools and the boot monitor is MiniCore, with optiboot of 512 bytes. 

- Optiboot version 8.0 does program flash memory, as do_spm, modified from <avr/boot.h>, it uses r0:r1, r30:r31, r20, r22, r24

- For use do_spm, need a routine to read a page from flash into sram, update bytes at sram, then write a page from sram into flash, using do_spm. Maybe keep ever the "next" page (64 bytes) in sram, and write when full.

- Start basic assembler for parse, find, evaluate, number, create, does;
  
- Defined specific functions for flash memory. All changes at dictionary are done in a buffer sram. 

- Created routines, a *flash* for init the buffer, from flash page of HERE, and a *flush* for copy to flash update

# 08/04/2021** resumes from 2020
  
- The inner interpreter is done and is very small and effcient;

- The primitive words are done, as minimal set from forth plus some extras;

- But I'm at easter egg of forth:
I have sources of words as ": word ~~~ ;" and I need a forth done to compile or
I have sources of words compiled with some forth and need use same forth engine;

- Then sectorforth (https://github.com/cesarblum/sectorforth) comes to simplifly all, and I restart again.

- The optiboot v8.0 could do program flash memory, as do_spm, so will use it as boot loader.


# pre 10/05/2021

- AVR Atmegas have a harvard architeture them flash program memory (flash) and static ram (sram) memory have different spaces. To access anything at flash must use lpm instruction, which only do words address, because all instructions are 16bits words. A atmega8 with 8k flash have really 4k words and access must do shifts to transform indirect references;

- How to keep chars (1 byte) in dictionary at flash for use of c! and c@ and c, ? Don't do, keep all in words, low byte is char and clear high byte. How to keep chars (1 byte) in static memory ? as bytes :)

- _Times for POP/PUSH with SP as same of LD/ST with Z, Y, X registers_, so I decide use Y as return stack and X as parameter stack, leaving Z for access flash and sram.

- Also no use CALL and RET, leaving SP for external libraries, interrupts and tasks stuff.

- No need to have a complete ANS Forth in such small MCU, then trimmed almost stuff to essentials and funny :)

- No need for speed, but to try a proof concept of a immutable dictionary, no assembler instructions into dictionary.

- I made a bag of notes from many implementations of eforth, amforth, flashforth, jonasforth, sectorforth, cmforth and etc, to learn about how it resolve issues of CPU, MCU, memory models, protocols, devices, speed, and do not reinvent the wheel.

- For dictionary struture, and vocabularies: a) unique LINK+NAME+CODE+PARAMETERS; b) link is the reference for previous word and is NULL at end of linked list; c) names are counted strings, with length of 1 to 15 7bit ASCII and 4 bit flags in counter byte (first one); d) CODE and PARAMETERS are implementation dependent at next section

- All forth constants are in flash and all forth variables are at top of sram, how else ?

- A memory model for forth f2u in Atmega8 SRAM is sram_init = 0x060, variables, parameter stack 20 cells, return stack 20 cells, tib buffer 72 bytes, pad 72 buffer bytes, free, stack pointer 20 cells, sram_end = 0x45F.

- Why 72 ? because " Column 72 means Continue ", old IBM punch cards uses 80 columns wich last 8 are for sequence numbers. 

- Classic forths complements dictionary with words defined in blocks or files, that can be read and write with external access;

- \"In 328eForth, I chose to address flash memory in bytes, so that it is easier to move
data between flash memory and RAM memory. Although ATmega328P execute
code in 16 bit cells, when you read and write the flash memory, you actually have to
use byte addresses in the Z register, and it is natural to use byte addresses to move
data in or out the flash memory. Therefore, in 328eForth all flash addresses are byte
addresses. Only when executing a command, its execution address in bytes is
converted to a cell address. When you retrieve an address from flash memory or
from the return stack, you have to convert it from a cell address to a byte address
before operating on it.\" Dr. C. H. Ting, 
ForthArduino_1.pdf, http://forth.org/OffeteStore/2159_328eforth.zip

    
- in https://github.com/cesarblum/sectorforth a revival of https://groups.google.com/g/comp.lang.forth/c/NS2icrCj1jQ

- in https://guides.github.com/features/mastering-markdown/

