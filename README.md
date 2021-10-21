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


# Memory Models

*"Do not Speculate"*

Forth born in CPUs with Von Neumann memory paradigm, were instructions and data share same address space and external magnetic devices stores data for permanent read and write cycles. 

Main system routines are stored in Read Only Memory, with reserved address for I/O Mapped Memory, but all Random Access Memory, where Forth lives, can be changed with same CPU instructions.

Modern MCUs uses Harvard memory paradigm, instructions and data do not share continous address, and the program memory is in flash, with about 10.000 cycles of read and write, and static random access memory. 

Those spaces have separated MCUs instructions and processes to be accessed and changed, and this makes a fundamental diference at implementations of Forth.

In AVR MCUs flash memory is erased and writed in pages, with sizes varyng from 32 to 128 words, there is no way to change only one specific word.

Many Forths go around this limitation with schemes of mapping where dictionary is writtren and ping-pong buffers to perform as a transparent, or not, system, some uses explicit sram, eeprom, and flash spaces and leaves for user where and what use.

## how do 

Looking into Forth standarts (79, 83, ANS, 2012, FIG, etc) and implementations, (using mnemonics) there are small lists of 

> words that changes memory contents as STORE (!), MOVE, FILL; 

> words that changes the dictionary as COMMA (,), CREATE, VARIABLE, CONSTANT, VALUE, DOTSTR (."); 

> words that changes flag bits as IMMEDIATE, COMPILE_ONLY, SMUDGE, TOGGLE; Only while compiling. 

# my alternative: 

- _Still not working_

When defining a new word, copy the actual flash page correspondent of DP pointer to sram buffer, start pointers offsets, make the changes into sram buffer and when is full, or at end, flush contents and restart pointers, repeat until done;

When defining words with VARIABLE, CONSTANT, DEFER, IS, TO, ASSIGN, CREATE, \<BUILDS and DOES\> use same aprouch.

# Implementation References

*Do it yourself*

Some comparations of implementations of Forth
all use concepts as next, nest aka docolon, unnest aka semmis, exit

## 1. In eforth for Cortex M4,  <http://forth.org/OffeteStore/1013_eForthAndZen.pdf>, to use in a ESP32, Dr. C.H.Ting uses a optimal approach for forth engine, with cpu family specific instructions (ISA) *inline into dictionary*

_in my opinion, is the best and ideal solution per cpu_ (at cost of size and portability)

### ; the inner interpreter, in macro code:
```
_next:    BX LR                 ; branch to ptr in LR, (exchange PC and LR, inc LR, inc LR, jmp PC)
_nest:    STMFD R2!, {LR}       ; push LR into return stack
_unnest:  LDMFD R2!, {PC}       ; pull PC from return stack
_exec:    BL ptr                ; branch and link, ( mov ptr to LR, inc LR, inc LR, jmp ptr)
```
### ; the dictionary, PFA:

```
leaf ==> instr, instr, instr, instr, _next
    
twig ==> _nest, *BL* ptr, *BL* ptr, *BL* ptr, _unest         
```
### ; considerations

> high (most) efficient code;

> all dicionary is CPU dependent;

> all compond words have a payload per reference;

> the memory model is unified, flash and sram are continuous address;

### ; notes

>    BL accepts +/- 32 Mb offset, then dictionary must be less than 32 MB, 

>    with 4 bytes per word then it is about 8M, with 2 words per reference then almost 4M for free space.  
    
> Uses many memory than a Atmega8 have, also no unified memory model, but lots of SRAM.

## 2. In amforth for AVR family, <http://amforth.sourceforge.net/>  

; the interpreter, XH:XL is Instruction pointer, ZH:ZL is program memory pointer, WH:WL is working register, Tmp1:Tmp0 is a scratch temporary
```asm
DO_COLON: ; 8
      push XL
      push XH
      movw XL, WL
      adiw XL, 1
      
DO_NEXT:  ; 12
      movw ZL, XL
      lsl ZL
      rol ZH
      lpm WL, Z+
      lpm WH, Z+
      adiw XL, 1
      
DO_EXECUTE:   ; 14
      movw ZL, WL
      lsl ZL
      rol ZH
      lpm Tmp0, Z+
      lpm Tmp1, Z+
      movw ZL, Tmp0
      ijmp Z
      
DO_EXIT:  ; 6, X_EXIT
      pop XH
      pop XL
      rjmp DO_NEXT
```
; the dicionary, inside PFA
```
    leaf ==>  (rjmp code0), code0, code ... , (rjmp DO_NEXT)
    
    twig ==>  (code of DO_COLON), ptr ... ptr, (ptr of DO_EXIT)
```

### ; considerations

>    traditional and efficient code;

>    *twig dictionary is CPU independent;*

>    all twig words have a payload as first and last references;

>    all leaf words have a payload as self reference and last jump;

### ; notes

> the memory model is not unified, separate address for flash, sdram.

> why two "adiw WL, 1" ? Adjust Z to a even address

## 3. In flashforth, <https://flashforth.com/index.html>, for avr uCs with at least 32k flash

      uses SP for return stack, uses Y for data stack, uses Z as address pointer

     *interleaves rcall and rjmp inside dictionary;*
     
     all dicionary is CPU dependent;
     all twig words have a payload as first and last references;
     all leaf words have a payload as self reference and last jump;
    
     Can not run into a Atmega8 with 8k flash.

## 4. In this F2U implementation for ATMEGA8, 
  
there is no use of call, return, pop and push

there are 2 versions of inner interpreter, using AVR pseudo 16 bit registers. In all instructions, first argument are destiny register.

WARNING: those inner interpreters only works for program memory (flash), due specific address flash memory squema for AVRs using lpm 

### _1) The inner interpreter (1) with only pull and push at return stack._
```
````;
; inner interpreter pull/push only
;

_ends:
  ; does nothing and mark as primitive
  nop

_exit:
  ; pull isp from rsp
  ld r31, Y+
  ld r30, Y+

_next:
  ; load wrk with contents of cell at isp and auto increments isp
  lsl z30
  rol z31
  lpm r24, Z+
  lpm r25, Z+
  ror z31
  ror z30

  ; if not zero then is a reference to compound word, goto _enter 
  cpi r24, 0
  brne _enter
  cpi r25, 0
  brne _enter

_exec: 
  ; else is a primitive then branch to it
  
  ; if using a table to primitives as a classic gcc trampolim
  .ifdef TRAMPOLIM
    lsl z30
    rol z31
    lpm r24, Z+
    lpm r25, Z+
    ror r31
    ror r30
    movw r30, r24
  .endif

  ijmp

_enter: 
  ; push isp into rsp
  st -Y, r30
  st -Y, r31
  
; go next it
  movw r30, r24
  rjmp _next

; inner ends
```
    

### _the inner interpreter (2) with pull and push at return stack and emulated branch and link for primitives_
```
```;
; inner interpreter pull/push and branch/link
;

_ends:
  ; does nothing and mark as primitive
  nop
  
_exit:
  ; pull isp from rsp
  ld r31, Y+
  ld r30, Y+

_next:
  ; load wrk with contents of cell at isp and auto increments isp
  ; mind specific address Flash memory squema for AVRs lpm 
  lsl z30
  rol z31
  lpm r24, Z+
  lpm r25, Z+
  ror z31
  ror z30

  ; if not zero then is a reference to compound word, goto _enter 
  cpi r24, 0
  brne _enter
  cpi r25, 0
  brne _enter

_branch: 
  ; else is a primitive then branch to it
  
  ; if using a table to primitives as a classic gcc trampolim
  .ifdef TRAMPOLIM
    lsl z30
    rol z31
    lpm r24, Z+
    lpm r25, Z+
    ror r31
    ror r30
    movw r30, r24
  .endif

  movw r24, r30   ; copy this reference
  addw r24, +2    ; point to next reference
  movw r18, r24   ; keep next reference to link
  ijmp            ; jump to this

_link:
  movw r30, r18 ; points to next reference
  rjmp _next

_enter: 
; push isp into rsp
st -Y, r30
st -Y, r31
  
; go next it
movw r30, r24
rjmp _next

; inner ends
```
## Why two versions ? 

the first form is easy and simple, use return stack for any word. Do more overhead in words and return stack grows for any word.

the second form is more complex, use a exclusive instruction register for primitive words and return stack only for compounds. This really saves stack depth and reduce overall instruction code size by simplifly some primitives,.

there is no significant overhead between those variants, but second form is a way easy for develoment and require less instructions in primitives.

### into the dicionary, PFAs are (LINK+SZ+NAME+PAD?+REFERENCES)
  
    ;------------- independent 
    
    twig ==>  ref, ..., leaf, ... , ref, (_ends)
    
    leaf ==>  0x00, (ptr)
    
    ;-------------- dependent
    
    ; table trampolim
    (rjmp ref), (rjmp ref) ....
    
    ; inner interpreter
    (_void) (0x00), _exit, _next, _branch, _link, _enter  
    
    ; code for primitives
    (ptr) code ... code (rjmp _link)

### ; considerations

    efficient code;
    twig and leaf are dicionary is CPU independent;
    leaf (could) do references of trampolim table;
    all twig words have only a payload at last references;
    all leaf words have a payload as, starts with NOP and ends with a jump;

### ; notes

    all internal words defined between parentheses, so user never could use ; 
    the memory model is not unified, separate address for flash and for sdram;
    uses minus one reference execution per each compound word  at cost of a test if NULL

    ??? why all mature forths does inline or code at start of parameters, just for speed ???

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

 - register r0:r1 as generic scratch for internal routines (mul, div, etc)
        
 - reserved for interrupts (borrow from flashforth):
 - registers r2:r3 used by counter of timer interrupt, 
 - register r4, constant offset for timer0 
        register r5, to preserve sreg in interrupts
 - registers r6::r17 free

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

