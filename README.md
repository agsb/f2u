# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have do ride bicycles"*

This is a evolution from what I learning with u2forth, ATMEGA8 assembler and forth interpreters from eforth, avr-forth, gforth, etc

# Introduction

  pretend to a inner interpreter and primitives words (system, uart, interrupts, stacks, math, moves) dependent of a CPU family.
  pretend to a outer interpreter and compond words independent of any specific CPU family.

# References

1. In eforth for Cortex M4,  http://forth.org/OffeteStore/1013_eForthAndZen.pdf
https://code.google.com/archive/p/subtle-stack/downloads, to use in a ESP32, Dr. C.H.Ting uses a optimal approach for forth engine, with cpu family specific instructions (ISA) *inline into dictionary*.

_in my opinion best and ideal solution per cpu_ (at cost of size and portability)

; the interpreter, in macro code:

    _next:    BX LR                 ; branch to ptr in LR, link register
    _nest:    STMFD R2!, {LR}       ; push LR into return stack
    _unnest:  LDMFD R2!, {PC}       ; pull PC from return stack
    BL ptr                          ; branch and link, ( mov LR ptr, inc LR, inc LR, jmp ptr)

; the dictionary, inside PFA:

    leaf ==> instr, instr, instr, instr, _next
    
    twig ==> _nest, *BL* ptr, *BL* ptr, *BL* ptr, _unest        

; considerations
    
    high (most) efficient code;
    all dicionary is CPU dependent;
    all compond words have a payload per reference;
    the memory model is unified, flash and sdrom are continuous address;
    BL accepts +/- 32 Mb offset, then dictionary must be less than 32 MB.
    
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
    twig dicionary is CPU independent;
    all twig words have a payload as first and last references;
    all leaf words have a payload as self reference and last jump;
    the memory model is not unified, separate address for flash, sdram.
    why two "adiw WL, 1" ? Adjust Z to a even address
    
4. this F2U implementation for ATMEGA8, do not use any of real SP intructions (pop, push, call, ret), leaving those for external extensions and libraries;
      
; the interpreter

    ;
    ; WARNING: this inner still only works for program memory (flash) 
    ; 
    ; does nothing and mark as primitive
    _LAST:
      nop
      nop
      
    _EXIT:
    ; pull ip from rsp
     rsp_pull ip_low, ip_high

    _NEXT:
    ; load w with contents of cell at ip and auto increments ip
     lpm wrk_low, Z+
     lpm wrk_high, Z+

    _EXEC:
    ; if zero then is a exec
     mov r0, r25
     or  r0, r24
     brbc 1, _ENTER
    ; jump to
     ijmp
    
    _ENTER:
    ; else is a reference
    ; push ip into rsp
     rsp_push ip_low, ip_high
     movw ip_low, wrk_low
     rjmp _NEXT

; the dicionary, inside PFA 
  
    leaf ==>  (0x0000), code ... code, (rjmp _EXIT)

    twig ==>  ptr ... ptr, (_LAST)
    
; considerations
    
    efficient code;
    twig dicionary is CPU independent;
    all twig words have only a payload at last references;
    all leaf words have a payload as NULL and at last jump;
    the memory model is not unified, separate address for flash and for sdram;
    ??? minus one reference execution per each compound word  at cost of a test if NULL

# Specifics

      address pointer is Z (r31:r30) for lpm (flash), lds (sram), sts (sram) instructions;
      first stack pointer is Y (r29:r28) for forth return stack;
      second stack pointer is X (r27:r26) for forth data stack;
      working pair register is W (r25:r24) for forth working register;
      
      temporary register T (r23:r22)
      temporary register N (r21:r20)
      register r0 as generic work 
      register r1 as always zero

      registers r2 to r4 used in interrupts
      registers r15:14 used by counter of timer interrup, (borrow from flashforth)
      registers r17:r16 and r19:r18 free
      
      flash memory from $000 to $FFF ($0000 to $1FFF bytes)
      sram memory from  $0C0 to $45F (1024 bytes)
      if (flash dictionary at $460, and all primitives 
 
 harvard memory architeture;
 
 using internal clock of 8MHz;
 
 uart at 9600, 8N1, asynchronous;
 
 include timer at 1ms with 16 bits counter  ~ 65 s;
 
 include watch dog at ~ 2.0 s;
 
 include pseudo 16bit random generator; 
 
 include adapted djb hash generator for 16bits;
 
 all 8bits and 16bits math from AVR200 manual;
 
 uses MiniCore and optboot;
 
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
  
  
# Notes

1. Primitives (Leaf) routine does not do any call. Compound (Twig) routines do.

2. To translate forth names to assembler names, 
   
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
