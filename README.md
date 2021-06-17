# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have do ride bicycles"*

This is a evolution from what I learning with u2forth, ATMEGA8 gcc assembler and forth implementations as eforth, amforth, avr-forth, gforth, flashforth, etc

**"this is a work in progress, not completed"**

For now:

  10/06/2021, Still no operational

    The basic functional words are done, as minimal set for parse, find, evaluate, number, create, does;
    
    Controls
    a)  testing top of stack:
      
      *standart implementation for*
      (if ... else ... then ...), forward jumps, (1)
      (begin ... again), inconditional backward jump, (2)
      (begin ... until), conditional backward jump, (2)
      
      *non-standart implementation for*
      (while ... repeat), conditional forward jump and inconditional backward jump, (3)
      (while ... again), maybe ?
      att: *repeat jumps to while*, both independent of begin.
    
    b) testing values on return stack 
      *not for now*
     (do ... leave ... loop), counter backward jump, test at loop
     (for ... next), counter backward jump, test at for
        
  12/05/2021,  Still no operational
  
    Start basic assembler for parse, find, evaluate, number, create, does;
    Defined specific functions for flash memory. All changes at dictionary are done in a buffer sram. 
    Created routines, a **flash** for init the buffer, from flash page of HERE, and a **flush** for copy to flash update
  
  08/04/2021, resumes from 2020
  
    The inner interpreter is done and is very effcient;
  
    The primitive words are done, as minimal set from forth plus some extras;
  
    But I'm at easter egg of forth:
      I have sources of words as ": word ~~~ ;" and I need a forth done to compile or
      I have sources of words compiled with some forth and need use same forth engine;
  
    Then sectorforth (https://github.com/cesarblum/sectorforth) comes to simplifly all, and I restart again.
  
    The optiboot v8.0 could do program flash memory, as do_spm, so will use it as boot loader.
  
take a look at Notes.md

# Introduction

*In the chat session Chuck was asked, "How did you come to the conclusion that Forth was too complex, and that sourceless programming was your next move?" His reply was, "Maybe by reading the Forth Standard." [Moore, 2002] http://www.ultratechnology.com/levels.htm *

Forth have two types of words, those called natives, ad primitive ad leaves, which are coded in specific CPU or MCU instructions, and those called forths, ad compounds ad twigs, which are sequences of references to words.

I want a forth with: 
1) a minimal inner interpreter and primitives words (system, uart, interrupts, stacks, math, moves) dependent of a MCU family; 
2) all compound words independent of any specific MCU family, like a imutable list with rellocable references without any code inline.

# Size or Speed ?

Most of Forth implementations goes "runnig for speed" for timming applications or simply to be "the most faster than", but when memory space is the critical limit most of design decisions must take another path.

My choice for design is a Atmega8, a MCU with harvard memory architeture, 4k words (16-bits) program flash memory, 1k bytes (8-bits) static ram memory, 512 bytes of EEPROM,  memory-mapped I/O, one UART, one SPI, one I2C, 32 (R0 to R31) 8bits registers, with some (R16 to R31) that could be used as 8 x 16 bits.

There are many low cost MCU with far more resources and pleny of SRAM and flash. Why use an old MCU for hosting Forth ? Most to refine paradigms and understood how forth works inside, looking from behind the stacks. 

Many challenges to resolve, how make a minimal bios, what basic word set,  how update flash memory, how access internal resources, etc. Learn from previous implementations and adapt to survice.

For comparation, in 1979, the PDP-11, was eight 16-bit registers, ( including one stack pointer and one program counter), unifed memory addressing and devices. http://bitsavers.trailing-edge.com/pdf/dec/pdp11/handbooks/PDP11_Handbook1979.pdf. 

# Memory Models

Forth born in  CPUs with Von Neumann memory paradigm, were instructions and data share same address space and external magnetic devices stores data for permanent read and write cycles. Main system routines are stored in Read Only Memory, with reserved address for I/O Mapped Memory, but all Random Access Memory, where Forth lives, can be changed with same CPU instructions. 

Modern MCUs uses Harvard memory paradigm, instructions and data do not share address, and the program memory is flash with about 10.000 cycles of read and write, and static random access memory, those spaces have separated MCUs instructions and processes to be changed, and this makes a fundamental diference at implementations of Forth.

In AVR MCUs flash memory is erased and writed in pages, with sizes varyng from 32 to 128 words, there is no way to change only one specific word.

Many Forths go around this limitation with schemes of mapping where dictionary is writtren and ping-pong buffers to perform as a transparent, or not, system, some uses explicit sram, eeprom, and flash spaces and leaves for user where and what use.

Looking into Forth standarts (79, 83, ANS, 2012, FIG, etc) and implementations, (using mnemonics for those words) there are small lists of 1) words that changes the dictionary as COMMA (,), CREATE, DOTSTR (."); 2) words that changes flag bits as IMMEDIATE, SMUDGE, HIDE, REVEAL; 3) words that changes memory as STORE (!), MOVE, FILL; 

When defining a new word between COLON (:) and SEMI (;), copy the actual flash page correspondent of DP pointer to sram buffer, start pointers offsets, make the changes into sram buffer and when is full, or at end, flush contents and restart pointers; 

When defining words with CREATE and DOES>, 

# Implementation References

1. In eforth for Cortex M4,  http://forth.org/OffeteStore/1013_eForthAndZen.pdf, to use in a ESP32, Dr. C.H.Ting uses a optimal approach for forth engine, with cpu family specific instructions (ISA) *inline into dictionary*.

_in my opinion, is the best and ideal solution per cpu_ (at cost of size and portability)

; the inner interpreter, in macro code:

    _next:    BX LR                 ; branch to ptr in LR, link register
    _nest:    STMFD R2!, {LR}       ; push LR into return stack
    _unnest:  LDMFD R2!, {PC}       ; pull PC from return stack
    BL ptr                          ; branch and link, ( mov LR ptr, inc LR, inc LR, jmp ptr)

; the dictionary, PFA:

    leaf ==> instr, instr, instr, instr, _next
    
    twig ==> _nest, *BL* ptr, *BL* ptr, *BL* ptr, _unest         

; considerations
    
    high (most) efficient code;
    all dicionary is CPU dependent;
    all compond words have a payload per reference;
    the memory model is unified, flash and sdrom are continuous address;
    BL accepts +/- 32 Mb offset, then dictionary must be less than 32 MB, 
       (4 bytes per word then 8M, 2 words per reference then 4M)  
    
    Uses many memory than a Atmega8 have, also no unified memory model, but lots of SRAM.
    
2. In amforth for AVR family, http://amforth.sourceforge.net/,  

; the interpreter, XH:XL is Instruction pointer, ZH:ZL is program memory pointer, WH:WL is working register, Tmp1:Tmp0 is a scratch temporary

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

; the dicionary, inside PFA 
  
    leaf ==>  (rjmp code), code ... , (rjmp DO_NEXT)
    
    twig ==>  (code of DO_COLON), ptr ... ptr, (DO_EXIT)

; considerations
    
    traditional efficient code;
    *twig dictionary is CPU independent;*
    all twig words have a payload as first and last references;
    all leaf words have a payload as self reference and last jump;
    the memory model is not unified, separate address for flash, sdram.
    why two "adiw WL, 1" ? Adjust Z to a even address

3. In flashforth, https://flashforth.com/index.html, for avr uCs with at least 32k flash
    
      uses SP for return stack, uses Y for data stack, uses Z as address pointer

     *interleaves rcall and rjmp inside dictionary;*
     all dicionary is CPU dependent;
     all twig words have a payload as first and last references;
     all leaf words have a payload as self reference and last jump;
    
     Can not run into a Atmega8 with 8k flash.
    
4. In this F2U implementation for ATMEGA8, there is no use of call, return, pop and push.
      
; the inner interpreter

    ;
    ; WARNING: this inner still only works for program memory (flash) 
    ;
    
    _ends:
     ; does nothing and mark as primitive
     nop
      
    _exit:
     ; pull isp from rsp
     ld r24, Y+
     ld r25, Y+
   
    _next:
     ; load wrk with contents of cell at isp and auto increments isp
     lsl z30
     rol z31
     lpm r24, Z+
     lpm r25, Z+
     ror z31
     ror z30
    
     ; if zero then is a primitive, go exec it
     cp r25, r24
     brbs 1, _exec
     
    _enter:
     ; push isp into rsp
     st -Y, r30
     st -Y, r31
     
     ; go next it
     movw r30, r24
     rjmp _next
    
    _exec: 
     ; execute it
     
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
    
; the dicionary, PFAs are (LINK+NAME+REFERENCES)
  
    ;------------- independent 
    
    twig ==>  ref, ..., leaf, ... , ref, (_ends)
    
    leaf ==>  0x00, (ptr)
    
    ;--------------dependent
    
    ; table trampolim
    (rjmp ref), (rjmp ref) ....
    
    ; inner interpreter
    (_void) (0x00), _exit, _next, _enter, _exec  
    
    ; code for primitives
    (ptr) code ... code (rjmp _ends)
     
; considerations
    
    efficient code;
    twig and leaf are dicionary is CPU independent;
    leaf does references of trampolim table
    all twig words have only a payload at last references;
    all leaf words have a payload as, starts with NOP and ends with a jump;
    all internal words defined between parentheses; 
    the memory model is not unified, separate address for flash and for sdram;
    ??? minus one reference execution per each compound word  at cost of a test if NULL
    ??? if all dependent bellow a limit address, no need 0x00 mark too, just compare to exec (if bellow) or enter (if above) .
    ??? all mature forths does inline or code at start of parameters 
    
; details

      No use of SP intructions (pop, push, call, ret), leaving those for external extensions and libraries;
      Only use IJMP to primitives else use indirect push and pull references;
      All references are done using of indirect LD and ST with Z, Y, X;  
      All primitive words finish with a rjmp _EXIT, so the (inner + primitives) must be less than +2k words;
      
      address pointer is Z (r31:r30) for lpm/spm (flash), lds (sram), sts (sram) instructions;
      
      first stack pointer is Y (r29:r28) for forth return stack;
      second stack pointer is X (r27:r26) for forth data stack;
      
      working register is W (r25:r24) for forth working register;
      
      temporary register T (r23:r22)
      temporary register N (r21:r20)
      
      for convenience
        register r0:r1 as generic scratch 
        used in interrupts:
        registers r2:r3 used by counter of timer interrup, (borrow from flashforth)
        register r4, constant offset for timer0 
        register r5, preserve sreg
      
      registers r6::r19 free
     
      flash memory from $000 to $FFF ($0000 to $1FFF bytes), words NRWW ($C00 to $FFF) and RWW( $000 to $BFF)
      sram memory from  $0C0 to $45F (1024 bytes)
      
# Specifics
 
 For ATmega8 MCU specifics plan, using 
 
    a MiniCore and optboot;
    a internal clock of 8MHz and 
    a uart at 9600, 8N1, asynchronous;
    a timer at 1ms with 16 bits counter  ~ 65 s;
    a watch dog at ~ 2.0 s;
    a pseudo 16bit random generator; 
    a adapted djb hash generator for 16bits;
    all 8bits and 16bits math from AVR200 manual;
    
    update flash memory using a sram buffer ***

    
# Specifics

  all dictionary in flash;
  all constants in flash;
  all values and variables in sram;
  eeprom preserves constants;
  a cell is 16 bits;
  little endian, low byte at low address;
  a char is ASCII 7 bits, one byte at SRAM, one cell at stacks.
  maximum word lenght is 15; 
  four bits flags (IMMEDIATE, COMPILE, HIDEN, TOGGLE) per word;
  word names are padded with space (0x20)
  numbers are signed two-complement;
  parameter stack is 18 words, return stack is 18 words;
  terminal input buffer is 72 bytes, scratch-pad is 24 bytes, hold is 16 bytes;
  all buffers ends in \0
  
# Notes

  1. primitives (Leaf) routine does not do any call or jump. Compound (Twig) routines do.
  2. index routines counts downwards until 0, ever, exact as C: for (; n != 0 ; n--) { ~~~ }
  3. no bounds check, none.
  4. compare bytes: COMPARE return FALSE or TRUE, only;
  5. move bytes: only MOVE done, ( still no CMOVE upwards, no CMOVE> downwards);
  6. word names lenght can be 1 to 15, padded with space (0x20);

