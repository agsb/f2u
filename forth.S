/* 
 *  DISCLAIMER" 
 * 
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos, 
 * 
 *  Permission is hereby granted, free of charge, to any person obtaining 
 *  a copy of this software and associated documentation files (the 
 *  "Software"), to deal in the Software without restriction, including 
 *  without limitation the rights to use, copy, modify, merge, publish, 
 *  distribute, sublicense, and/or sell copies of the Software, and to 
 *  permit persons to whom the Software is furnished to do so, subject to 
 *  the following conditions" 
 * 
 *  The above copyright notice and this permission notice shall be 
 *  included in all copies or substantial portions of the Software. 
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
 * 
 */ 
 
;--------------------------------------------------------------------- 
; 
;    A small Forth for ATmega8 
; 
;--------------------------------------------------------------------- 
; dictionary structure 
; 
; cell size is a word of 16 bits 
; 
; .word  link    link to previous 
; .byte  size    sizeof name OR flags 
; .ascii "name"  name, plus a pad byte with BL (0x32) if size is odd 
; .word  param,  many references 
; 
;---------------------------------------------------------------------- 
 
; 
; classics 
; 
.NOLIST 
.LIST 
 
;---------------------------------------------------------------------- 
; start of dictionary 
; 
 
;---------------------------------------------------------------------- 
; 
; this is the forth inner engine, 
; 
; a compound word, aka twig, must end with a reference to ENDS 
; 
; a primitive work, aka leaf, must start with NOOP and ends with POON 
; 
; the size byte must be masked by: or 0xF0 
; 
; memory pointer r31:r30 as Z 
; return stack pointer r29:r28 as Y 
; working register r25:r24 as W 
; temporary tos register r23:r22 
; temporary nds register r21:r20 
; instruction pointer r18:r19 
; scratch register r0 
; 
; Can only use LPM to access flash memory ? YES! 
; 
; all constants in flash, all variables in sdram 
; 
; why ? flash memory suports only 10.000 cycles 
; 
 
;---------------------------------------------------------------------- 
; starts just above sram ends 
;
; use the address to determine if is flash or is sram, above is flash :)
; 
.section .text 
.org 0x460 
.global forth 
_forth_: 
;---------------------------------------------------------------------- 
; inner interpreter, 
; it is also a primitive word 
; 
; also called semis 
HEADER "ENDS", "ENDS" 
; does nothing and mark as primitive 
    NOOP 
 
; pull ips from rsp 
_exit: 
    rspull zpm_low, zpm_high 
 
; load w with contents of cell at ips 
_next: 
    pmload wrk_low, wrk_high ; also increments zpm 
 
; if zero (NULL) is a primitive word 
    mov _work_, wrk_low 
    or _work_, wrk_high 
    sbrs _work_, BIT_ZERO 
    rjmp _branch 
 
; else is a reference 
_enter: 
    rspush zpm_low, zpm_high ; push next reference 
    movw zpm_low, wrk_low ; point to this reference 
    rjmp _next 
 
; then branch, for exec it 
_branch: 
    movw wrk_low, zpm_low   ; copy this reference 
    adiw wrk_low, 2     ; point to next reference 
    movw ipr_low, wrk_low   ; keep this reference 
    ijmp 
 
; then link, for continue 
_link: 
    movw zpm_low, ipr_low ; points to next reference 
    rjmp _next 
 
;---------------------------------------------------------------------- 
; 
; using no cached 
; (1st, 2nd, 3rd, 4th, ...) 
; 
; all operations are done in W (r24:r25) as acumulator 
; and it must be pushed when need else is scratch. 
; may use temporary Tos (r22:r23) and Nos (r20:r21) 
; 
;---------------------------------------------------------------------- 
 
;********************************************************************** 
; 
;    init of minimal words 
;---------------------------------------------------------------------- 
 
;---------------------------------------------------------------------- 
; ok ( -- 0 ) 
; also a shortcut for false and push W into acumulator, used in many words 
HEADER "0", "ZERO" 
    NOOP 
_ffalse: 
    clr wrk_low 
    clr wrk_high 
_pushw: 
    pspush wrk_low, wrk_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok 0= 
; 
HEADER "0=", "ZEQU" 
    NOOP 
    test_zero wrk_low, wrk_high 
    rjmp _ffalse 
_ftrue: 
    ser wrk_low 
    ser wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ! to (w a -- ) 
; only in sram 
HEADER "!", "TO" 
    NOOP 
    pspull zpm_low, zpm_high 
    pspull wrk_low, wrk_high 
 
; if above _forth_ is flash 
    ldi tos_high, hi8(_forth_) 
    cpi zpm_low, lo8(_forth_) 
    cpc zpm_high, tos_high 
    brge _isflash_to 
 
_isram_to: 
    srsave wrk_low 
    srsave wrk_high 
    POON 
 
_isflash_to: 
;   do flash flush, later :( still not done 
    POON 
 
;---------------------------------------------------------------------- 
; ok @ at ( a -- w ) 
; only in sram 
HEADER "@", "AT" 
    NOOP 
    pspull zpm_low, zpm_high 
 
; if above _forth_ is flash 
    ldi tos_high, hi8(_forth_) 
    cpi zpm_low, lo8(_forth_) 
    cpc zpm_high, tos_high 
    brge _isflash_at 
 
_isram_at: 
    srload wrk_low 
    srload wrk_high 
    WOOP 
 
_isflash_at: 
    pmload wrk_low, wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- rsp) 
; 
HEADER "RS@", "RPAT" 
    NOOP 
    movw wrk_low, rsp_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- psp ) 
; 
HEADER "PS@", "SPAT" 
    NOOP 
    movw wrk_low, psp_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 NAND w1 ) 
; 
HEADER "NAND", "NAND" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    and wrk_low, tos_low 
    and wrk_high, tos_high 
    com wrk_low 
    com wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 + w1 ) 
HEADER "+", "PLUS" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    clc 
    add wrk_low, tos_low 
    adc wrk_high, tos_high 
    WOOP 
 
;---------------------------------------------------------------------- 
;    end of minimal words 
; 
;********************************************************************** 
 
 
;********************************************************************** 
;    load variables 
; 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "TIB", "tib_" 
    NOOP 
    ldi wrk_low, lo8(TIB) 
    ldi wrk_high, hi8(TIB) 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "LATEST", "LATEST" 
    NOOP 
    ldi wrk_low, lo8(LAST) 
    ldi wrk_high, hi8(LAST) 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "STATE", "STATE" 
    NOOP 
    ldi wrk_low, lo8(STAT) 
    ldi wrk_high, hi8(STAT) 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "BASE", "BASE" 
    NOOP 
    ldi wrk_low, lo8(RADX) 
    ldi wrk_high, hi8(RADX) 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "(sram)", "sram_" 
    NOOP 
    ldi wrk_low, lo8(SRAM) 
    ldi wrk_high, hi8(SRAM) 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "(erom)", "erom_" 
    NOOP 
    ldi wrk_low, lo8(EROM) 
    ldi wrk_high, hi8(EROM) 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "FSHM", "here_" 
    NOOP 
    ldi zpm_low, lo8(FSHM) 
    ldi zpm_high, hi8(FSHM) 
    WOOP 
 
;---------------------------------------------------------------------- 
; 
; ok ( -- w) 
; beware, it blocks while test if can receive a char 
; 
HEADER "key", "key_" 
    NOOP 
1: 
    sbis 0x0b, 7 
    rjmp 1b 
2: 
    in wrk_low, 0x0c 
    clr wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- 0 | w) 
; test if can receive a char, or return FALSE 
; 
HEADER "key?", "qkey_" 
    NOOP 
3: 
    sbis 0x0b, 7 
    rjmp _ffalse 
    rjmp 2b 
 
;---------------------------------------------------------------------- 
; ok ( w -- ) 
; beware, it blocks while test if can send a char 
; 
HEADER "emit", "emit_" 
    NOOP 
1: 
    sbis 0x0b, 5 
    rjmp 1b 
2: 
    pspull wrk_low, wrk_high 
    out 0x0c, wrk_low 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w -- w 0) 
; test if can send a char, or return FALSE 
; 
HEADER "emit?", "qemit_" 
    NOOP 
3: 
    sbis 0x0b, 5 
    rjmp _ffalse 
    rjmp 2b 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; push timer counter 
; 
HEADER "millis", "millis_" 
    NOOP 
    movw wrk_low, ticks_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- -1 ) 
; 
HEADER "TRUE", "FTRUE" 
    NOOP 
_iftrue: 
    ser wrk_low 
    ser wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- 0 ) 
; 
HEADER "FALSE", "FFALSE" 
    NOOP 
_iffalse: 
    clr wrk_low 
    clr wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok (  -- 1) 
HEADER "1", "ONE" 
    NOOP 
    clr wrk_high 
    clr wrk_low 
    inc wrk_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- 0 | -1 ) 
; 
HEADER "<", "LTHAN" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    cp wrk_low, tos_low 
    cpc wrk_high, tos_high 
    brlt _iftrue 
    rjmp _iffalse 
 
;---------------------------------------------------------------------- 
; 
; ok ( w -- ) ( -- W) 
;     F18A push 
HEADER ">R", "TOR" 
    NOOP 
    pspull wrk_low, wrk_high 
    rspush wrk_low, wrk_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w ) ( w -- ) 
;    F18A pull 
HEADER "R>", "RTO" 
    NOOP 
    rspull wrk_low, wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- w ) ( w -- w ) 
HEADER "R@", "RAT" 
    NOOP 
    rspull wrk_low, wrk_high 
    rspush wrk_low, wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( rsp -- ) 
HEADER "RS!", "RPTO" 
    NOOP 
    pspull wrk_low, wrk_high 
    movw rsp_low, wrk_low 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( psp -- ) 
HEADER "PS!", "SPTO" 
    NOOP 
    pspull wrk_low, wrk_high 
    movw psp_low, wrk_low 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w ) 
;    F18A 
HEADER "PUSH", "PUSH" 
    NOOP 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w -- ) 
;    F18A drop 
HEADER "DROP", "DROP" 
PULL: 
    NOOP 
    pspull wrk_low, wrk_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w -- w w) 
;     F18A dup 
;     could be done using ldd Rd, Y + k 
HEADER "DUP", "DUP" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspush wrk_low, wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w2 w1 -- w1 w2 ) 
HEADER "SWAP", "SWAP" 
    NOOP 
    pspull tos_low, tos_high 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w -- 0 | w w ) 
; dup if tos not zero 
; 
HEADER "?DUP", "ZDUP" 
    NOOP 
; copy the top 
    pspull wrk_low, wrk_high 
    test_zero wrk_low, wrk_high 
    rjmp 1f 
    pspush wrk_low, wrk_high 
1: 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( u -- ) 
; branch IF tos IS zero 
; 
HEADER "?BRANCH", "ZBRANCH" 
    NOOP 
    pspull wrk_low, wrk_high 
    test_zero wrk_low, wrk_high 
    rjmp 2f 
    movw wrk_low, ipr_low 
    adiw wrk_low, 2 
    movw ipr_low, wrk_low 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( branch next reference ) 
; 
; doing offsets in bytes 
HEADER "BRANCH", "BRANCH" 
    NOOP 
2: 
    movw zpm_low, ipr_low 
    pmload wrk_low, wrk_high 
    add ipr_low, wrk_low 
    adc ipr_high, wrk_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( branch next reference ) 
; 
HEADER "EXEC", "EXEC" 
    NOOP 
    pspull wrk_low, wrk_high 
    rspush wrk_low, wrk_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2-w1 ) 
; 
HEADER "-", "MINUS" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    clc 
    sub wrk_low, tos_low 
    sbc wrk_high, tos_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 AND w1 ) 
; 
HEADER "AND", "AND" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    and  wrk_high, tos_high 
    and  wrk_low, tos_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 OR w1 ) 
; 
HEADER "OR", "OR" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    or   wrk_high, tos_high 
    or   wrk_low, tos_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 XOR w1 ) 
; 
HEADER "XOR", "XOR" 
    NOOP 
    pspull wrk_low, wrk_high 
    pspull tos_low, tos_high 
    eor   wrk_high, tos_high 
    eor   wrk_low, tos_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w -- w * 2 ) same as shift left << 1, unsigned 
; 
HEADER "2*", "SHL" 
    NOOP 
_shl: 
    pspull wrk_low, wrk_high 
    clc 
    lsl   wrk_low 
    rol   wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w -- w / 2 ) same as shift right >> 1, unsigned 
; 
HEADER "2/", "SHR" 
    NOOP 
_shr: 
    pspull wrk_low, wrk_high 
    clc 
    lsr wrk_low 
    ror wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w -- w * 2 ) same as shift left << 1, signed 
; 
HEADER "2*A", "SHLA" 
    NOOP 
    pspull wrk_low, wrk_high 
    clc 
    bst wrk_high, 7 
    cbr wrk_high, 7 
    lsl wrk_low 
    rol wrk_high 
    bld wrk_high, 7 
    WOOP 
 
;-------------------------------------------------------------------------- 
; ok ( w -- w / 2 ) same as shift right >> 1, no sense 10010111 -> 10001011 
; 
HEADER "2/A", "SHRA" 
    NOOP 
    pspull wrk_low, wrk_high 
    clc 
    bst wrk_high, 7 
    cbr wrk_high, 7 
    lsr wrk_low 
    ror wrk_high 
    bld wrk_high, 7 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( nAnB -- nBnA ) swap bytes in a word 
HEADER "><", "ENDIAN" 
    NOOP 
    pspull wrk_high, wrk_low 
    WOOP 
 
;---------------------------------------------------------------------- 
;  os LITL ( -- w ), inverse of comma 
;  from flash to data stack 
;  all prinmitives use branch and link, 
;    the next is holding in ipr 
; 
HEADER "LITL", "LITL" 
    NOOP 
    movw zpm_low, ipr_low 
    pmload wrk_low, wrk_high 
    movw ipr_low, zpm_low 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok C! ( c a -- ) 
; sorry all in words 
HEADER "C!", "CTO" 
    NOOP 
    rjmp TO 
 
;---------------------------------------------------------------------- 
; ok C@ ( c a -- ) 
; sorry all in words 
HEADER "C@", "CAT" 
    NOOP 
    rjmp AT 
 
;---------------------------------------------------------------------- 
; ok INV 
HEADER "INVERT", "INVERT" 
    NOOP 
    pspull wrk_low, wrk_high 
_inv: 
    com wrk_low 
    com wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok NEG 
HEADER "NEGATE", "NEGATE" 
    NOOP 
    pspull wrk_low, wrk_high 
_neg: 
    neg wrk_low 
    neg wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ABS 
HEADER "ABS", "ABS" 
    NOOP 
    pspull wrk_low, wrk_high 
_abs: 
 
    sbrc wrk_high, 7 
    rjmp _neg 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( w -- w ) 
;  data space pointer align to CELL, atmega is always 
 
HEADER "ALIGN", "ALLIGN" 
    NOOP 
    pspull wrk_low, wrk_high 
    adiw wrk_low, 1 
    cbr wrk_low, 0 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( -- CELL ) 
; CELL is 2 ; size of a cell 
; 
HEADER "CELL", "CELL" 
    NOOP 
    ldi wrk_low, CELL_SIZE 
    clr wrk_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( a1 a2 u -- 0 | 1) 
; compare bytes from source++ to destination++, decrease count-- 
; returns 0 if equal (no differ) 
; 
HEADER "CSAME", "CSAME" 
    NOOP 
    ; WARNING No bound check and counter equal 0 moves nothing 
 
    ; pull lenght 
    pspull tos_low, tos_high 
 
    ; pull address source 
    pspull zpm_low, zpm_high 
 
    ; pull address destin 
    pspull nds_low, nds_high 
 
    ; push psp 
    rspush psp_low, psp_high 
 
    ; copy address 
    movw psp_low, nds_low 
 
    ; no offset 
 
1: 
    movw wrk_low, tos_low 
    or tos_low, tos_high 
    brbs BIT_ZERO, 2f 
 
    subi wrk_low, 1 
    movw tos_low, wrk_low 
 
    ld wrk_low, X+ 
    ld wrk_high, Z+ 
    or wrk_low, wrk_high 
    brbc BIT_ZERO, 3f 
 
    ; again 
    rjmp 1b 
 
2: 
    ; equal 
    clr wrk_low 
    clr wrk_high 
    rjmp 4f 
3: 
    ; not equal 
    ser wrk_low 
    ser wrk_high 
4: 
    ; pull psp 
    rspull psp_low, psp_high 
    WOOP 
 
;---------------------------------------------------------------------- 
; ok ( a1 a2 u -- ) 
; 
; MOVE copy bytes from source++ to destination++, decrease count-- 
HEADER "CMOVE", "CMOVE" 
    NOOP 
    ; WARNING No bound check and counter equal 0 moves nothing 
 
    ; pull lenght 
    pspull tos_low, tos_high 
 
    ; pull address source 
    pspull zpm_low, zpm_high 
 
    ; pull address destin 
    pspull nds_low, nds_high 
 
    ; push psp 
    rspush psp_low, psp_high 
 
    ; copy address 
    movw psp_low, nds_low 
 
    ; no offset 
 
1: 
    movw wrk_low, tos_low 
    or tos_low, tos_high 
    brbs BIT_ZERO, 2f 
 
    subi wrk_low, 1 
    movw tos_low, wrk_low 
 
    ; move a cell 
    ld _work_, X+ 
    st Z+, _work_ 
 
    ; again 
    rjmp 1b 
 
2: 
    ; pull psp 
    rspull psp_low, psp_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( a1 a2 u -- ) 
; 
; MOVE copy bytes from source-- to destination--, decrease count-- 
HEADER "BMOVE", "BMOVE" 
    NOOP 
    ; WARNING No bound check and counter equal 0 moves nothing 
 
    ; pull lenght 
    pspull tos_low, tos_high 
 
    ; pull address source 
    pspull zpm_low, zpm_high 
 
    ; pull address destin 
    pspull nds_low, nds_high 
 
    ; push psp 
    rspush psp_low, psp_high 
 
    ; copy address 
    movw psp_low, nds_low 
 
    ; do offset
    add zpm_low, wrk_low
    adc zpm_high, wrk_high
    add psp_low, wrk_low
    adc psp_high, wrk_high
 
    ; move a byte
1:
    movw wrk_low, tos_low 
    or tos_low, tos_high 
    brbs BIT_ZERO, 2f 
 
    subi wrk_low, 1 
    movw tos_low, wrk_low 

    ld _work_, -X
    st -Z, _work_

    ; again 
    rjmp 1b 

2:
    ; pull psp
    rspull psp_low, psp_high
    POON


 
;********************************************************************** 
; 
;    the follow definitions of compound words 
;    are as already compiled into a list of references, 
;    that is a sequence of cells. 
;    No preorder because the assembler does translation 
;    of names to address (references) 
; 
;    (some adapted from old fig-forth listings) 
; 
;---------------------------------------------------------------------- 
; ok ( w2 w1 -- w2 w1 w2 ) 
; 
HEADER "OVER", "OVER" 
    .word SWAP, DUP, TOR, SWAP, RAT, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w3 w2 w1 -- w2 w1 w3 ) 
; 
HEADER "ROT", "ROT" 
    .word TOR, SWAP, RAT, SWAP, ENDS 
 
;---------------------------------------------------------------------- 
; ok (  -- 2) 
HEADER "2", "TWO" 
    .word ONE, SHL, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- 0 | -1) 
; 
HEADER "=", "EQUAL" 
    .word MINUS, ZEQU, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- 0 | -1) 
; 
HEADER "<>", "NOTEQUAL" 
    .word EQUAL, INVERT, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- 0 | -1 ) 
; 
HEADER ">", "GTHAN" 
    .word SWAP, LTHAN, ENDS 
 
;---------------------------------------------------------------------- 
;  ok 0>  must be signed 
; 
HEADER "0>", "ZEROGT" 
     .word ZERO, LTHAN, ENDS 
 
;---------------------------------------------------------------------- 
;  ok 0< must be signed 
; 
HEADER "0<", "ZEROLT" 
    .word ZERO, SWAP, LTHAN, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w -- w * CELL  ) 
; CELL is 2, multiply by 2, easy way 
; 
HEADER "CELLS", "CELLS" 
    .word SHL, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ( w -- w + CELL ) 
; 
HEADER "CELL+", "CELLPLUS" 
    .word CELL, PLUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ( w -- w - CELL ) 
; 
HEADER "CELL-", "CELLMINUS" 
    .word CELL, MINUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ( w -- w + 1 ) 
; 
HEADER "1+", "ONEPLUS" 
     .word ONE, PLUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ( w -- w - 1 ) 
; 
HEADER "1-", "ONEMINUS" 
     .word ONE, MINUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ( w -- w + 2 ) 
; 
HEADER "2+", "TWOPLUS" 
     .word TWO, PLUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ( w -- w - 2 ) 
; 
HEADER "2-", "TWOMINUS" 
     .word TWO, MINUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ( u w -- ) 
; 
HEADER "+!", "PLUSTO" 
    .word SWAP, OVER, AT, PLUS, SWAP, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok \] 
; 
HEADER  "]", "RBRAC", 
    .word ONE, STATE, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok \[ 
; 
HEADER  "[", "LBRAC", F_IMMEDIATE 
    .word ZERO, STATE, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok TOGGLE ( a f -- )
; 
HEADER  "TOGGLE", "TOGGLE", 
    .word OVER, AT, XOR, SWAP, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok >NFA ( a f -- )
; 
HEADER  ">NFA", "TONFA", 
    .word CELL, PLUS, ENDS

;---------------------------------------------------------------------- 
; 
; ok >CFA ( a f -- )
; 
HEADER  ">CFA", "TOCFA", 
    .word CELL, PLUS, DUP, AT, F_UNMASK, AND, PLUS, ENDS

;---------------------------------------------------------------------- 
; 
; ok HIDDEN 
; 
HEADER  "HIDDEN", "HIDDEN", 
    .word LATEST, TONFA, F_HIDDEN, TOGGLE, ENDS 

;---------------------------------------------------------------------- 
; 
; ok IMMEDIATE 
; 
HEADER  "IMMEDIATE", "IMMEDIATE", 
    .word LATEST, TONFA, F_IMMEDIATE, TOGGLE, ENDS 

;---------------------------------------------------------------------- 
; 
; ok COMPILE_ONLY 
; 
HEADER  "COMPILE_ONLY", "COMPILE_ONLY", 
    .word LATEST, TONFA, F_COMPILE_ONLY, TOGGLE, ENDS 

;---------------------------------------------------------------------- 
; 
; ok HERE 
; 
HEADER  "HERE", "HERE", 
    .word FSHM, AT, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ALLOT 
; 
HEADER  "ALLOT", "ALLOT", 
    .word FSHM, PLUSTO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok COMMMA ( w -- ) 
HEADER  ",", "COMMA", 
    .word HERE, TO, CELL, ALLOT, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok this takes next cell and compiles into HERE 
; 
HEADER  "COMP", "COMP", 
    .word LITL, COMMA, ENDS 
 
;---------------------------------------------------------------------- 
; ok  
HEADER  ":", "COLON", 
    .word CREATE, HIDDEN, RBRAC, ENDS 
 
;---------------------------------------------------------------------- 
; ok  
HEADER  ";", "SEMMI", 
    .word COMP, ENDS, HIDDEN, LBRAC, ENDS 
 
;---------------------------------------------------------------------- 
; ok  ZZZZ
HEADER  "CREATE", "CREATE", 
    .word ENDS 

;---------------------------------------------------------------------- 
; 
; ok BACK 
HEADER  "BACK", "BACK", F_IMMEDIATE 
    .word HERE, SWAP, MINUS, COMMA, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok MARK 
HEADER  "MARK", "MARK", F_IMMEDIATE 
    .word HERE, 0, COMMA, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok BEGIN 
HEADER  "BEGIN", "BEGIN", F_IMMEDIATE 
    .word HERE, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok AGAIN resolves a backward branch 
HEADER  "AGAIN", "AGAIN", F_IMMEDIATE 
    .word COMP, BRANCH, BACK, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok UNTIL 
HEADER  "UNTIL", "UNTIL", F_IMMEDIATE 
    .word COMP, ZBRANCH, BACK, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok UNLESS 
HEADER  "UNLESS", "UNLESS", F_IMMEDIATE 
    .word INVERT, UNTIL, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok IF 
HEADER  "IF", "IF", F_IMMEDIATE 
    .word COMP, ZBRANCH, MARK, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ENDIF resolves a forward branch 
; note: use of store if addres is not 'here' 
HEADER  "ENDIF", "ENDIF", F_IMMEDIATE 
    .word DUP, HERE, MINUS, SWAP, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok THEN 
HEADER  "THEN", "THEN", F_IMMEDIATE 
    .word ENDIF, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ELSE 
HEADER  "ELSE", "ELSE", F_IMMEDIATE 
    .word COMP, BRANCH, MARK, SWAP, ENDIF, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok WHILE 
HEADER  "WHILE", "WHILE", F_IMMEDIATE 
    .word IF, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok REPEAT 
HEADER  "REPEAT", "REPEAT", F_IMMEDIATE 
    .word TOR, TOR, AGAIN, RAT, RAT, MINUS, ENDIF, ENDS 
 
;---------------------------------------------------------------------- 
; does reset 
; 
HEADER "BYE", "BYE" 
    NOOP 
    rjmp RESET 
    POON 
 
;---------------------------------------------------------------------- 
; 
HEADER "COLD", "COLD" 
    NOOP 
; restart return stack 
    ldi rsp_low, lo8(RSP) 
    ldi rsp_high, hi8(RSP) 
; restart parameter stack 
    ldi psp_low, lo8(PSP) 
    ldi psp_high, hi8(PSP) 
; restart buffers etc???? 
; preload to WARM 
    ; next word 
    ldi zpm_low, lo8(WARM) 
    ldi zpm_high, hi8(WARM) 
    rspush zpm_low, zpm_high 
    POON 
 
;---------------------------------------------------------------------- 
; 
HEADER  "WARM", "WARM" 
    NOOP 
    ; verify error code 
    ; resets etc 
    POON 
 
