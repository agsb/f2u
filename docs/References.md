# FORTH ENGINES

# dictionary

the dictionary is a linked list of (link, size + flags, name, pad, (code or references))

Example of dictionary structure (adapted from jonasforth.S)
---
```
defword:  ; one reference DOCOL to all compound words, 
                                           (..........all cells are references.........)   
+---------+---+---+---+---+---+---+---+---+----------+------------+------------+-------+
| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL    | DUP        | PLUS       | EXIT  |
+---------+---+---+---+---+---+---+---+---+-----|----+------------+------------+-------+
           len                         pad      |        
                                                +--->  points to codewords

defcode:  ; one macro NEXT to all primitives
                          ( reference,...........code............................macro)
+---------+---+---+---+---+----------------+--------------+--------------+------------+
| LINK    | 3 | D | U | P | points to code | pull w, ps++ | push --ps, w | macro NEXT |
+---------+---+---+---+---+-------|--------+--------------+--------------+------------+
           len                    |
                                  +-------> points to code following
OBS: classic format
```

in this:
---
```
defword:  ; no docol, minus one reference per compound word

+-------+---+---+---+---+---+---+---+---+-----+------+-------+
| LINK  | 6 | D | O | U | B | L | E | 0 | DUP | PLUS | ENDS  |     
+-------+---+---+---+---+---+---+---+---+-----+------+-------+
         len                         pad
      
defcode:  ; with NULL, one reference per primitive word

+-------+---+---+---+---+-----+--------------+---------------+-------------+----------+
| LINK  | 3 | D | U | P | 0x0 | pull w, ps++ |  push --ps, w |push --ps, w | jmp link |
+-------+---+---+---+---+-----+--------------+---------------+-------------+----------+
         len              NULL

+-------+---+---+---+---+---+---+--------------+--------------+----------+--------------+----------+
| LINK  | 1 | P | L | U | S | 0 | pull w, ps++ | pull t, ps++ | add w, t | push --ps, w | jmp link |
+-------+---+---+---+---+---+---+--------------+--------------+----------+--------------+----------+
         len                 pad

OBS: 0x0 in codeword for all primitives, no DO_COLON in codeword for all compounds

```

Some comparations of implementations of Forth.
All use concepts as next, nest aka docolon, unnest aka semmis and exit.

---
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
    
twig ==> _nest, BL ptr, BL ptr, BL ptr, _unest         
```
### ; considerations

> high (most) efficient code;

> all dicionary is CPU dependent;

> all compond words have a payload per reference;

> the memory model is unified, flash and sram are continuous address;

### ; notes

>the instruction BL accepts +/- 32 Mb offset, then dictionary must be less than 32 MB, but using 4 bytes per word, it is about 8M words, with 2 words per reference, then almost 4M for use, still a lot of free address space.

_in my opinion, is the best and ideal solution per cpu, at cost of size and portability_

*Impossible to use, this implementation uses far more memory than a Atmega8 have.*

---
# 2. In flashforth, <https://flashforth.com/index.html>, for avr uCs with at least 32k flash

    interleaves rcall and rjmp inside dictionary; 
    all dicionary is CPU dependent;
    all twig words have a payload as first and last references;
    all leaf words have a payload as self reference and last jump;
    Can not run into a Atmega8 with 8k flash.
---
# 3. In amforth for AVR family, <https://github.com/lowfatcomputing/amforth-all/> <http://amforth.sourceforge.net/>  

"AmForth is an interactive 16-bit Forth for Atmel ATmega microcontrollers.
It does not need additional hard or software. It works completely on
the controller (no cross-compiler)."

"Amforth is influenced by (early versions of) avrforth"

The interpreter code as excerpt from version 6.9, 18/10/2020, Matthias Trute, Erich Wälde et alli.

```asm
; XH:XL is Instruction pointer, 
; ZH:ZL is program memory pointer, 
; WH:WL is working register, 
; Tmp1:Tmp0 is a scratch temporary

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
      ijmp 

DO_EXIT:  ; 6
      pop XH
      pop XL
      rjmp DO_NEXT
```
; the dicionary, inside PFA

- leaf ==>  (ptr of code0), code0, code ... , (rjmp DO_NEXT)
    
- twig ==>  (ptr of DO_COLON), ptr ... ptr, (ptr of DO_EXIT)

### ; considerations

> traditional and efficient code;

> twig dictionary is CPU independent;

> all twig words have a payload as first and last references (DO_COL and DO_EXIT);

> all leaf words have a payload as first reference (to self) and last jump;

> the memory model is not unified, separate address for flash, sdram.

> why two "adiw WL, 1" ? Adjust Z to a even address

---
# 4. In this F2U implementation for ATMEGA8, 
  
All primitive words use a branch and link model, with next reference explicity keeped into a reserved register to later return.

All compound words use a call and return model, with next reference pushed into and pulled from the return stack.

Not using Atmega8 instructions call, return, pop and push.

This inner interpreters only works for program memory (flash), due specific address flash memory squema for AVRs using lpm 

```
;----------------------------------------------------------------------
 ; inner interpreter,
 ; it is also a primitive word
 ; (mcu cycles)
 ; also called semis
 HEADER "ENDS", "ENDS"
 ; does nothing and mark as primitive
    NOOP

 ; pull ips from rsp
 _exit:     ;(4)
    ld  zpm_low, Y+
    ld  zpm_high, Y+

 ; load w with contents of cell at ips
 _next:     ;(10)
    lsl zpm_low
    rol zpm_high
    lpm wrk_low, Z+
    lpm wrk_high, Z+
    ror zpm_high
    ror zpm_low
    
 ; if zero (NULL) is a primitive word
 _void:     ;(3)
    mov _work_, wrk_low
    or _work_, wrk_high
    brbs BIT_ZERO, _branch

 ; else is a reference
 _enter:    ;(7)
    st -Y, zpm_low
    st -Y, zpm_high
    movw zpm_low, wrk_low 
    rjmp _next

 ; then branch, for exec it
 _branch:   ;(5)
    movw wrk_low, zpm_low   ; copy this reference
    adiw wrk_low, 2         ; point to next reference
    movw ipr_low, wrk_low   ; keep this reference
    ijmp

 ; then link, for continue
 _link:     ;(3)
    movw zpm_low, ipr_low ; points to next reference
    rjmp _next
```
## Why branch and link ? 

This really saves stack depth and reduce overall instruction code size by simplifly some primitives.

A good essay, by David Frech, at <https://muforth.nimblemachines.com/call-versus-branch-and-link/>, asserts "There is a jump involved, so perhaps a pipeline refill occurs.", but always will have a jump.
## the dictionary

I like use the terms leaf for primitives words and twig for compound words, as in <https://muforth.nimblemachines.com/threaded-code/>.
  
    ;------------- independent 
    
    twig ==>  ref, ..., leaf, ... , ref, _ends
    
    leaf ==>  0x00, (ptr)
    
    ;-------------- dependent
    
    ; table trampolim
    (rjmp ref), (rjmp ref) ....
    
    ; inner interpreter
    (_void) (0x00), _exit, _next, _enter, _branch, _link,
    
    ; code for primitives
    (ptr) code ... code (rjmp _link)

### ; considerations

    efficient code as cost of speed;
    twigs are dicionary is CPU independent;
    all twig words have only a payload at last references;
    all leaf words have a payload by starts with NULL and ends with a jump;

    leaf (could) do references to trampolim table, with real references of primitives;

### Codes and Parameters

1. I2C implementation reference at flashforth

2. SPI implementation reference at flashforth

### Reviews

about RNG, https://hackaday.com/2018/01/08/entropy-and-the-arduino/

