# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have do ride bicycles"*

This is a evolution from what I learning with u2forth, ATMEGA8 assembler and forth interpreters from eforth, avr-forth, gforth, etc

# Introduction

  pretend to a inner interpreter and primitives words (system, uart, interrupts, stacks, math, moves) dependent of a CPU family.
  pretend to a outer interpreter and compond words independent of any specific CPU family.

# References

http://forth.org/OffeteStore/1013_eForthAndZen.pdf
https://code.google.com/archive/p/subtle-stack/downloads

1. In eforth for Cortex M4, a esp32, Dr. C.H.Ting uses a optimal aprouach for forth engine, but need cpu family specific instructions (ISA) *inline into dictionary*.

  _in my opinion best and ideal solution per cpu_

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
    
2. In amforth for AVR family,

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
  
    leaf ==>  (Self), code ... code, rjmp DO_NEXT
    
    twig ==>  DO_COLON, ptr ... ptr, DO_EXIT

; considerations
    
    traditional efficient code;
    twig dicionary is CPU independent;
    all twig words have a payload as first and last references;
    all leaf words have a payload as self reference and last jump;
    the memory model is not unified, separate address for flash, sdram.
    why two "adiw WL, 1" ????
    
3. this F2U implementation for ATMEGA8, 

no use of CPU SP intructions (pop, push, call, ret), leaving those for external extensions and libraries;
      
      address pointer is Z (r31:r30) for lpm instruction;
      first stack pointer is Y (r29:r28) for forth return stack;
      second stack pointer is X (r27:r26) for forth data stack;
      working pair register is W (r25:r24) for forth working register;
      
      temporary register T (r23:r22)
      temporary register N (r21:r20)
      register r0 as generic work 
      register r1 as always zero
      registers r2 to r4 used in interrupts
      registers r5 to r15 free
      registers r17:r16 and r19:r18 used in math operations
    
    
; the interpreter
    
    LAST:
      nop
      nop
      
    ; pull ip from rsp
    _EXIT:
      rsp_pull ip_low, ip_high

    ; load w with contents of cell at ip, only works in program memory (flash)
    _NEXT:
     lpm wrk_low, Z+
     lpm wrk_high, Z+

    ; push ip into rsp
    _ENTER:
     rsp_push ip_low, ip_high
     
    ; if zero then is a exec
     mov r0, r25
     or  r0, r24
     brbs 1, _EXEC

    ; else is a reference
     movw ip_low, wrk_low
     rjmp _NEXT

    _EXEC:
     ijmp
        
; the dicionary, inside PFA 
  
    leaf ==>  (0x0000), code ... code, (rjmp _EXIT)

    twig ==>  ptr ... ptr, (LAST)
    
; considerations
    
    efficient code;
    twig dicionary is CPU independent;
    all twig words have a payload  last references;
    all leaf words have a payload as NULL and last jump;
    the memory model is not unified, separate address for flash, sdram;
    ??? minus one reference execution per each word in exchange of a NULL test
  
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
