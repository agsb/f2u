# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have do ride bicycles"*

This is a evolution from what I learning with u2forth, ATMEGA8, gcc assembler and forth implementations as 328eforth, eforth, amforth, avr-forth, gforth, flashforth, punyforth, etc 

Some special insights from jonasforth (https://rwmj.wordpress.com/2010/08/07/jonesforth-git-repository/ https://github.com/nornagon/jonesforth), sectorforth (https://github.com/cesarblum/sectorforth), and lbforth (https://github.com/larsbrinkhoff/lbForth/)

## This --Readme.md-- still is a "brainstorm", really is a documentation of changes 

**"this is a work in progress, not completed"**

(take a look at notes and changes)

( need to learn how to use and format with .md)

https://github.com/matiassingers/awesome-readme

https://silentlad.com/how-to-write-beautiful-and-meaningful-readme.md

# Introduction

*In the chat session Chuck was asked, "How did you come to the conclusion that Forth was too complex, and that sourceless programming was your next move?" His reply was, "Maybe by reading the Forth Standard." [Moore, 2002] <http://www.ultratechnology.com/levels.htm>*

Forth is language based in thread code, with a dictionary of words as named routines and two stacks for arguments in a forever read–eval–print-loop.

The dictionary is a linked list of words, each with name and code. It have two types of words, those called primitives, ad natives ad leaves, which are coded in specific CPU or MCU instructions, and those called compounds, ad twigs, which are sequences with references to words.
 
*"A most important aspect of FORTH is its ability to define new words. New definitions and code are devised continously. Likewise, new constants or variables are created.", Rather, Moore, Hollis, https://library.nrao.edu/public/memos/comp/CDIR_17.pdf*

I want a forth with:

- a minimal inner interpreter and primitives words (clock, uart, interrupts, stacks, math, moves) dependent of a MCU family;

- all compound words independent of any specific MCU family,  without any assembler specifc code inline, like a imutable list with rellocable references.

# Size or Speed ?

*"Keep it Simple"*

Most of Forth implementations goes "runnig for speed" for timming applications or simply to be "the most faster than", but when memory space is the critical limit most of design decisions must take another path.

My choice for design is a Atmega8, a MCU with harvard memory architeture, 4k words (16-bits) program flash memory, 1k bytes (8-bits) static ram memory, 512 bytes of EEPROM,  memory-mapped I/O, one UART, one SPI, one I2C, with 32 (R0 to R31) 8 bits registers, with some that could be used as eight (R16 to R31) 16 bits registers.  A challenge.

There are many low cost MCU with far more resources and pleny of SRAM and flash. Why use an old MCU for hosting Forth ?

Most to refine language paradigms and understood manage memory, RAM and FLASH, and how forth works inside, looking from behind the stacks.

Many challenges to resolve, how make a minimal bios, what basic word must set, how update flash memory, how access internal resources, etc. Learn from previous many implementations of Forth and adapt to survive.

For comparation, in 1979, the PDP-11, Programmed Data Processor, was also eight 16-bit registers, (including one stack pointer R6, and one program counter R7), unifed memory addressing and memory mapped devices. <http://bitsavers.trailing-edge.com/pdf/dec/pdp11/handbooks/PDP11_Handbook1979.pdf>.

And PDP-11 have a successful implementation of Forth in 1974, https://library.nrao.edu/public/memos/comp/CDIR_17.pdf, and of Fig-Forth in 1980, http://www.forth.org/fig-forth/fig-forth_PDP-11.pdf and http://www.stackosaurus.com/figforth.html.

### ; details

Not using of SP intructions (pop, push, call, ret), leaving those for external extensions and libraries;

Only using IJMP to primitives else use indirect push and pull for references address;
     
All references are done using of indirect LD and ST with Z, Y, X, 16 bits registers;
     
All primitive words finish with a rjmp _link, so the (inner + primitives) must be less than +2k words;
      
Uses address pointer is Z (r31:r30) for lpm/spm (flash), lds (sram), sts (sram) instructions;
      
The return stack pointer is Y (r29:r28) for forth return stack;
      
The parameter stack pointer is X (r27:r26) for forth data stack;
      
A working register is W (r25:r24) for forth as acumulator register;
      
A temporary register T (r23:r22);
      
A temporary register N (r21:r20);
      
A instruction register IP (r19:r18);

For convenience

 - reserved r0:r1, used as generic scratch for internal routines (mul, div, etc)
        
 - reserved r2 as generic _work_ 
 
 - reserved r3 as always _zero_, by interrupt ;)
 
 - registers r4 reserver for keep _SREG_, inside interrupts
 
 - register r5 reserved for adjustable prescaler of timer0
 
 - registers r6:r7 reserved for keep 1ms clock ticks counter
 
 - registers r8::r17 are free

# Memory
flash memory from $000 to $FFF ($0000 to $1FFF bytes), splits in read-write flash RWW($000 to $BFF) and no-read-rwrite- flash NRWW ($C00 to $FFF).

sram memory from $0C0 to $45F (1024 bytes)

# Specifics

 For ATmega8 MCU specifics plan, using

   - a MiniCore and optboot;
   - a internal clock of 8MHz and 
   - a uart at 9600, 8N1, asynchronous;
   - a timer at 1ms with 16 bits counter  ~ 65 s;
   - a watch dog at ~ 2.0 s;
   - a pseudo 16bit random generator; 
   - a adapted djb hash generator for 16bits;
   - all 8bits and 16bits math from AVR200 manual;
    
> need explain update/flush flash memory using a sram buffer

# Specifics

  - all dictionary in flash;
  - all constants in flash;
  - all values and variables in sram;
  - eeprom preserves constants;
  - a cell is 16 bits;
  - little endian, low byte at low address;
  - a char is ASCII 7 bits, one byte at SRAM, one cell at stacks.
  - maximum word lenght is 15;
  - four bits flags (IMMEDIATE, COMPILE, HIDEN, TOGGLE) per word;
  - word names are padded with space (0x20)
  - numbers are signed two-complement;
  - all stacks are 18 words (cells);
  - terminal input buffer is 72 bytes, scratch-pad is 64 bytes, pic is 16 bytes;
  - all buffers ends in \0
  - still interrupts can't be nested, SREG breaks.
  
# Notes

- primitive (Leaf) routine does not do any calls. Compound (Twig) routines could do.
- index routines counts downwards until 0, ever, exact as C: for (n=NNNN; n != 0 ; n--) { ~~~ }
- no bounds check, none.
-compare bytes: COMPARE return FALSE or TRUE, only;
- move bytes: only MOVE done, (still no CMOVE upwards, no CMOVE> downwards);
- word names lenght can be 1 to 15, padded with space (0x20);

# Bootstrap fuses

from https://www.engbedded.com/conffuse/

BOOTRST, Flash boot size=256 words Boot address= $0F00
EESAVE, preserve eeprom
SPIEN, serial prrogram downloading SPI enable
SUT_CKSEL, Int Osc, 8MHz; startup time 6CK + 64ms
BODEN, Brown-out detector VCC=2,7V

high 0xD4
low  0xA4 (0xA0 for external clock, 16Mhz)

AVRDUDE:
-U hfuse:w:0xd4:m -U lfuse:w:0xa4:m

