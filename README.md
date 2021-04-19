# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have do ride bicycles"*

This is a evolution from what I learning with u2forth, ATMEGA8 assembler and forth interpreters from eforth, avr-forth, gforth, etc

# Introduction

  pretend to a inner interpreter and primitives words (system, uart, interrupts, stacks, math, moves) dependent of a CPU family.
  pretend to a outer interpreter and compond words independent of any specific CPU family.

# References

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
    
4. this f2u implementation for ATMEGA8, 
    no use of SP intructions (pop, push, call, ret) reserving and leaving those for external extensions and libraries;
    instruction pointer is Z (r31:r30) for lpm instruction;
    first stack pointer is Y (r29:r28) for forth return stack;
    working pair register is W (r25:r24) for forth working register;
    
; the interpreter

    _EXIT:  ; 4, pull ip from rsp
        ld ZH, Y+
        ld ZL, Y+
      
    _NEXT:  ; 18
        ; 6, load W with contents of cell at Z, only works in program memory (flash)
        lpm WH, Z+
        lpm WL, Z+
        
        ; 4, if is zero, then exec
        mov r0, WH
        or  r0, WL
        brbs 1, _EXEC 
        
        ; 4, push ip into rsp
        st -Y, ZL 
        st -Y, ZH
        
        ; 4, point to next reference
        movw ZL, WL
        rjmp _NEXT
        
    _EXEC:  ; 2
        ijmp
        
; the dicionary, inside PFA 
  
    leaf ==>  (0x0000), code ... code, rjmp _EXIT

    twig ==>  ptr ... ptr, _EXIT
    
; considerations
    
    efficient code;
    twig dicionary is CPU independent;
    all twig words have a payload  last references;
    all leaf words have a payload as NULL and last jump;
    the memory model is not unified, separate address for flash, sdram;
    ??? minus one reference execution per each word in exchange of a NULL test
  
# notes

1. Leaf routine does not do any call. Twig routines do.


