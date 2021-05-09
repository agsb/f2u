# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have do ride bicycles"*

This is a evolution from what I learning with u2forth, ATMEGA8 gcc assembler and forth interpreters from eforth, avr-forth, gforth, flashforth, etc

For now:

  The inner interpreter is done and is very effcient.
  The primitive words are done, as minimal set from eforth plus some extras.
  
  But I'm at easter egg of forth:
    I have sources of words as ": word ~~~ ;" and I need a forth done to compile or
    I have sources of words compiled with some forth and need use same forth engine;
  
  Then sectorforth (https://github.com/cesarblum/sectorforth) comes to simplifly all, and I restart again.
  
  01/05/2021  Still no operational
  
# Introduction

I want a forth for a Atmega8, but there is no need for speed, because I want a minimal inner interpreter and primitives words (system, uart, interrupts, stacks, math, moves) dependent of a MPU family and a outer interpreter and compound words independent of any specific CPU family, like a imutable list with rellocable references.

PS Atmega8 is a MCU with harvard architeture, 8k program flash memory, 1k static ram memory, 512 bytes of EEPROM,  memory-mapped I/O, one UART, one SPI, one I2C, 32 (R0 to R31) 8bits registers, but (R16 to R31) could be used as 16 bits.

look at Notes.md

# References

1. In eforth for Cortex M4,  http://forth.org/OffeteStore/1013_eForthAndZen.pdf
https://code.google.com/archive/p/subtle-stack/downloads, to use in a ESP32, Dr. C.H.Ting uses a optimal approach for forth engine, with cpu family specific instructions (ISA) *inline into dictionary*.

_in my opinion best and ideal solution per cpu_ (at cost of size and portability)

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
    BL accepts +/- 32 Mb offset, then dictionary must be less than 32 MB.
    
    Uses many memory than a Atmega8 have, also no unified memory model.
    
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
  
    leaf ==>  (Self), code ... code, (rjmp DO_NEXT)
    
    twig ==>  (DO_COLON), ptr ... ptr, (DO_EXIT)

; considerations
    
    traditional efficient code;
    *twig dictionary is CPU independent;*
    all twig words have a payload as first and last references;
    all leaf words have a payload as self reference and last jump;
    the memory model is not unified, separate address for flash, sdram.
    why two "adiw WL, 1" ? Adjust Z to a even address

3. In flashforth, https://flashforth.com/index.html, for avr uCs with at least 32k flash,
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
    EXIT:
      ; does nothing and mark as primitive
     nop
      
    _EXIT:
      ; pull isp from rsp
     rspull wrk_low, wrk_high

    _NEXT:
      ; load wrk with contents of cell at isp and auto increments isp
     movw isp_low, wrk_low
     pmload wrk_low, wrl_high
     
      ; if zero then is a primitive, go exec it
     cp wrk_low, wrk_high
     brbs 1, _EXEC
     
    _ENTER
      ; else 
      ; push isp into rsp
     adiw wrk_low, 2
     rspush wrk_low, wrk_high
     sbiw wrk_low, 2
      ; is a compound reference, go next it
     rjmp _NEXT 
    
    _EXEC
     movw isp_low, wrk_low
     asr isp_high
     ror isp_low
      ; jump to
     ijmp
    
; the dicionary, PFAs are 
  
    leaf ==>  (0x00), code ... code, (rjmp _EXIT)

    twig ==>  ptr, ..., ptr, (_LAST)
    
 doLit:
  rspull wl, wh
  movw zl, wl
  adiw wl, 2
  rspush wl, wh
  asr zh
  ror zl
  pmload wl, wh
  pspush wl, wh
  rjmp _EXIT
  
    
; considerations
    
    efficient code;
    twig dicionary is CPU independent;
    all twig words have only a payload at last references;
    all leaf words have a payload as, starts with NOP and ends with a jump;
    all internal words defined between parentheses; 
    the memory model is not unified, separate address for flash and for sdram;
    ??? minus one reference execution per each compound word  at cost of a test if NULL

; details

      No use of SP intructions (pop, push, call, ret), leaving those for external extensions and libraries;
      Only use IJMP to primitives else use indirect push and pull references;
      All references are done using of indirect LD and ST with Z, Y, X;  
      All primitive words finish with a rjmp _EXIT, so the (inner + primitives) must be less than +2k words;
      
      address pointer is Z (r31:r30) for lpm (flash), lds (sram), sts (sram) instructions;
      first stack pointer is Y (r29:r28) for forth return stack;
      second stack pointer is X (r27:r26) for forth data stack;
      working pair register is W (r25:r24) for forth working register;
      
      temporary register T (r23:r22)
      temporary register N (r21:r20)
      register r0 as generic scratch 
      register r1 as always zero
      
      for convenience
      registers r2 to r5 used in interrupts
      registers r2:r3 used by counter of timer interrup, (borrow from flashforth)
      register r4, constant offset for timer0 
      register r5, preserve sreg
      registers r6::r19 free
     
      flash memory from $000 to $FFF ($0000 to $1FFF bytes)
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
   
 **still do not write to flash.**
    
# Decisions

  all dictionary in flash;
  all constants and variables in sram;
  eeprom preserves constants;
  a cell is 16 bits;
  a char is ASCII 7 bits, one byte at SRAM, one cell at stacks.
  little endian, low byte at low address.
  maximum word lenght is 15; 
  four bits flags (IMMEDIATE, COMPILE, HIDEN, TOGGLE) per word;
  numbers are signed two-complement;
  parameter stack is 20 words, return stack is 20 words;
  terminal input buffer is 80 bytes, scratch-pad is 80 bytes, hold is 16 bytes;
  variables and constants uses 128bytes
  free ram is about 640 bytes;
  word names are padded with space (0x20)
  
# Notes

  1. primitives (Leaf) routine does not do any call. Compound (Twig) routines do.
  2. index routines counts downwards until 0, ever, exact as C: for (; n != 0 ; n--) { ~~~ }
  3. no bounds check, none.
  4. compare bytes: COMPARE return FALSE or TRUE, only;
  5. move bytes: CMOVE upwards, CMOVE> downwards;
  6. word names lenght can be 1 to 15, padded with space (0x20);

# Notation

1. To translate forth names to assembler names, 
   
I use as prefix or sufix
    
    use LE for <=
    use GT for >=
    use NE for <>
    use LT for <
    use GT for >
    use EQ for =

    use MUL for *
    use DIV for /
    use PLUS for +
    use MINUS for -

    use BY for /
    use QM for ?
    use AT for @
    use TO for !
    use TK for '
    use CM for ,
    use DT for .

    use NIL for 0
    use ONE for 1
    use TWO for 2
