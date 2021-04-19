# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have to do ride bicycles"*

This is a evolution from what I learning with u2forth, ATMEGA8 assembler and forth interpreters from eforth, avr-forth, gforth, etc

# Introduction

# Diferences

1. In eforth for Cortex M4, a esp32, Dr. C.H.Ting uses a optimal aprouach for forth engine, but need cpu family specific instructions (ISA) *inline into dictionary*.

  _in my opinion best and ideal solution_

; the interpreter, in code:

    _next:    BX LR                 ; branch to ptr in LR, link register
    _nest:    STMFD R2!, {LR}       ; push LR into return stack
    _unnest:  LDMFD R2!, {PC}       ; pull PC from return stack
    BL ptr                          ; branch and link, ( mov LR ptr, inc LR, inc LR, jmp ptr)

; the dictionary, inside PFA:

    leaf ==> instr, instr, instr, instr, _next
    
    twig ==> _nest, *BL* ptr, *BL* ptr, *BL* ptr, _unest

2. In amforth for AVR family,

; the interpreter, in meta-code
    
    DO_COLON:
      push IP
      move IP, W
      incr IP
    DO_NEXT:
      move Z, IP
      readflash W, (Z+)
      incr IP
    DO_EXECUTE:
      move Z, W
      readflash Tmp, (Z+)      
      move Z, rmp
      ijmp (Z)
    DO_EXIT:
      pop IP
      rjmp DO_NEXT

; the dicionary, inside PFA 
  
    leaf ==>  (Self), code ... code, rjmp DO_NEXT
    
    twig ==>  DO_COLON, ptr ... ptr, DO_EXIT
   
4. this f2u implementation for ATMEGA8, 
    no use of SP intructions (pop, push, call, ret) reserving and leaving those for external extensions and libraries;
    instruction pointer is Z (r31:r30) for lpm instruction;
    first stack pointer is Y (r29:r28) for forth return stack;
    second stack pointer is X (r27:r26) for forth parameter stack;
    working pair register is W (r25:r24) for forth working register;
    top of parameter stack in (r23:r22) for first cell in stack;
    second of parameter stack in (r21:r20) for second cell in stack;
    
; the interpreter

    LAST: ; does nothing and mark instructions code
        nop
        nop
      
    _EXIT: ; pull ip from rsp
        ld ip_high, Y+
        ld ip_low, Y+
      
    _THIS: ; load w with contents of cell at ip, only works in program memory (flash)
        lpm wrk_high, Z+
        lpm wrk_low, Z+

    _EXEC: ; check if is zero, then jump to next cell, else continue
        mov tmp, wrk_high
        or  tmp, wrk_low
        brne _ENTER
        ijmp

    _ENTER: ; push ip into rsp
        st -Y, ip_low 
        st -Y, ip_high

    _NEXT: ; point to next reference
        movw ip_low, wrk_low
        rjmp _THIS

; the dicionary, inside PFA 
  
    leaf ==>  (0x0000), code ... code, rjmp _EXIT

    twig ==>  ptr ... ptr, LAST
    
  
# notes

1. in read program memory, readflash, (LPM Ri, Z+) Ri any register and Z (r31:r30), Z never can be odd. use LSL r30, ROL r31, for adjust to even.

