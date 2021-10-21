# FORTH ENGINES

Some comparations of implementations of Forth.
All use concepts as next, nest aka docolon, unnest aka semmis and exit.

# 1. eForth for Cortex M4

Dr. C.H.Ting take a optimal approach for forth engine, for a ESP32, using cpu family specific instructions (ISA) *inline into dictionary* 
<http://forth.org/OffeteStore/1013_eForthAndZen.pdf>

Cortex M4 is a Harvard CPU, have do unified memory model, could have 512k flash and 96k sram,.

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

> BL accepts +/- 32 Mb offset, then dictionary must be less than 32 MB, 

> With 32M of flash memory, but using 4 bytes per word, it is about 8M, with 2 words per reference then almost 4M for use, still a lot of free address space.  

_in my opinion, is the best and ideal solution per cpu, at cost of size and portability_

*Impossible to use, this implementation uses far more memory than a Atmega8 have.*

# 2. In amforth for AVR family, <http://amforth.sourceforge.net/>  

(who, when, why) ?

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

### Codes and Parameters


1. I2C implementation reference at flashforth

2. SPI implementation reference at flashforth

