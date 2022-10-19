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
; scratch register r16:r17 
; 
; Can only use LPM to access flash memory ? YES! 
; 
; forth: all constants in flash
;
; user: all constants and all variables in sdram 
; 
; why ? flash memory suports only 10.000 cycles 
; 
 
;---------------------------------------------------------------------- 
; starts just above sram ends 
;
; use the address to determine if is flash or is sram, above is flash :)
; 
.section .text 
.org FORTH_INI
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
_void:
    mov _work_, wrk_low 
    or _work_, wrk_high 
    brbs BIT_ZERO, _jump
 
; else is a reference 
_enter: 
    rspush zpm_low, zpm_high ; push next reference 
    movw zpm_low, wrk_low ; point to this reference 
    rjmp _next 
 
; then jump, for exec it, save next return into ips 
_jump: 
    adiw zpm_low, 2	     
    movw ips_low, zpm_low    
    sbiw zpm_low, 2	     
    ijmp 
 
; then link, for continue, load return from ips 
_link: 
    movw zpm_low, ips_low ; points to next reference 
    rjmp _next 
 
;---------------------------------------------------------------------- 
 
;********************************************************************** 
; 
;    init of minimal words 
;---------------------------------------------------------------------- 
 
;---------------------------------------------------------------------- 
; ok 0= 
; 
HEADER "0=", "ZEQU" 
    NOOP 
    or tos_low, tos_high
    brbs BIT_ZERO, _ftrue
_ffalse:
    clr tos_low 
    clr tos_high 
    POON
_ftrue: 
    ser tos_low 
    ser tos_high 
    POON
 
;---------------------------------------------------------------------- 
; ok ! to (w a -- ) 
; only in sram 
HEADER "!", "TO" 
    NOOP 
    movw  zpm_low, tos_low
    pspull tos_low, tos_high 

; if above _forth_ is flash 
    ldi wrk_high, hi8(_forth_) 
    cpi zpm_low, lo8(_forth_) 
    cpc zpm_high, wrk_high 
    brge _isflash_to 
 
_isram_to: 
    srsave tos_low 
    srsave tos_high
    pspull tos_low, tos_high 
    POON 
 
_isflash_to: 
;   do flash flush, later :( still not done zzzz
    POON 
 
;---------------------------------------------------------------------- 
; ok @ at ( a -- w ) 
; only in sram 
HEADER "@", "AT" 
    NOOP 
    movw zpm_low, tos_low 
 
; if above _forth_ is flash 
    ldi wrk_high, hi8(_forth_) 
    cpi zpm_low, lo8(_forth_) 
    cpc zpm_high, wrk_high 
    brge _isflash_at 
 
_isram_at: 
    srload tos_low 
    srload tos_high 
    POON
 
_isflash_at: 
    pmload tos_low, tos_high 
    POON
 
;---------------------------------------------------------------------- 
; ok ( -- rsp) 
; put the top of return stack at tos
;
HEADER "RS@", "RPAT" 
    NOOP 
    pspush tos_low, tos_high 
    movw tos_low, rsp_low 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- psp ) 
; put the top of parameter stack at tos
; 
HEADER "PS@", "SPAT" 
    NOOP 
    pspush tos_low, tos_high 
    movw tos_low, psp_low 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 NAND w1 ) 
; 
HEADER "NAND", "NAND" 
    NOOP 
    pspull nos_low, nos_high 
    and tos_low, nos_low 
    and tos_high, nos_high 
    com nos_low 
    com nos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 + w1 ) 
HEADER "+", "PLUS" 
    NOOP 
    pspull nos_low, nos_high 
    clc 
    add tos_low, nos_low 
    adc tos_high, nos_high 
    POON 
 
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
    pspush tos_low, tos_high
    ldi tos_low, lo8(TIB) 
    ldi tos_high, hi8(TIB) 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "LATEST", "LATEST" 
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, lo8(LAST) 
    ldi tos_high, hi8(LAST) 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "STATE", "STATE" 
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, lo8(STAT) 
    ldi tos_high, hi8(STAT) 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "BASE", "BASE" 
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, lo8(RADX) 
    ldi tos_high, hi8(RADX) 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "(sram)", "sram_" 
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, lo8(SRAM_LAST) 
    ldi tos_high, hi8(SRAM_LAST) 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "(eeprom)", "eeprom_" 
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, lo8(EEPROM_LAST) 
    ldi tos_high, hi8(EEPROM_LAST) 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w) 
; 
HEADER "(flash)", "flash_" 
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, lo8(FLASH_LAST) 
    ldi tos_high, hi8(FLASH_LAST) 
    POON 
 
;********************************************************************** 
;   usart i/O 
; 
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
    pspush tos_low, tos_high
    in tos_low, 0x0c 
    clr tos_high 
    POON 
 
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
    out 0x0c, tos_low 
    pspull tos_low, tos_high
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
    pspush tos_low, tos_high 
    movw tos_low, ticks_low 
    POON 
 
;********************************************************************** 
;---------------------------------------------------------------------- 
; ok ( -- -1 ) 
; 
HEADER "TRUE", "FTRUE" 
    NOOP 
    pspush tos_low, tos_high 
_iftrue: 
    ser tos_low 
    ser tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- 0 ) 
; 
HEADER "FALSE", "FFALSE" 
    NOOP 
    pspush tos_low, tos_high 
_iffalse: 
    clr tos_low 
    clr tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- 0 ) 
;
HEADER "0", "ZERO" 
    NOOP 
    pspush tos_low, tos_high 
    clr tos_low 
    clr tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok (  -- 1) 
HEADER "1", "ONE" 
    NOOP 
    pspush tos_low, tos_high 
    clr tos_high 
    clr tos_low 
    inc tos_low 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- 0 | -1 ) 
; 
HEADER "<", "LTHAN" 
    NOOP 
    pspull nos_low, nos_high 
    cp tos_low, nos_low 
    cpc tos_high, nos_high 
    brlt _iftrue 
    rjmp _iffalse 
 
;---------------------------------------------------------------------- 
; ok ( w -- ) ( -- W) 
;      
HEADER ">R", "TOR" 
    NOOP 
    rspush tos_low, tos_high 
    pspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w ) ( w -- ) 
;     
HEADER "R>", "RTO" 
    NOOP 
    pspush tos_low, tos_high 
    rspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- w ) ( w -- w ) 
;
HEADER "R@", "RAT" 
    NOOP 
    rspush tos_low, tos_high 
    ld tos_low, X
    ld tos_high, X
    POON 
 
;---------------------------------------------------------------------- 
; ok ( rsp -- ) 
;
HEADER "RS!", "RPTO" 
    NOOP 
    movw rsp_low, tos_low 
    pspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( psp -- ) 
;
HEADER "PS!", "SPTO" 
    NOOP 
    movw psp_low, tos_low 
    pspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w -- ) 
;     
HEADER "DROP", "DROP" 
    NOOP
PULL: 
    pspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w -- w w) 
;
HEADER "DUP", "DUP" 
    NOOP 
PUSH:
    pspush tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w2 w1 -- w1 w2 ) 
;
HEADER "SWAP", "SWAP" 
    NOOP 
    pspull nos_low, nos_high 
    pspush tos_low, tos_high 
    movw tos_low, nos_low
    POON 
 
;---------------------------------------------------------------------- 
; ok ( 0 | w -- 0 | w w ) 
; dup if tos not zero 
; 
HEADER "?DUP", "ZDUP" 
    NOOP 
    test_zero tos_low, tos_high, 1f 
    pspush tos_low, tos_high 
1: 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( u -- ) 
; branch IF tos IS zero 
; 
HEADER "?BRANCH", "ZBRANCH" 
    NOOP 
    test_zero tos_low, tos_high, _branch 
    movw zpm_low, ips_low 
    adiw zpm_low, 2 
    movw ips_low, zpm_low 
    pspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( branch next reference ) 
; 
; doing offsets in bytes 
HEADER "BRANCH", "BRANCH" 
    NOOP 
_branch: 
    movw zpm_low, ips_low 
    pmload wrk_low, wrk_high 
    add ips_low, wrk_low 
    adc ips_high, wrk_high 
    pspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( branch next reference ) 
; is as >R
HEADER "EXECUTE", "EXECUTE" 
    NOOP 
    rspush tos_low, tos_high 
    pspull tos_low, tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2-w1 ) 
; 
HEADER "-", "MINUS" 
    NOOP 
    pspull nos_low, nos_high 
    clc 
    sub tos_low, nos_low 
    sbc tos_high, nos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 AND w1 ) 
; 
HEADER "AND", "AND" 
    NOOP 
    pspull nos_low, nos_high 
    and  tos_low, nos_low 
    and  tos_high, nos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 OR w1 ) 
; 
HEADER "OR", "OR" 
    NOOP 
    pspull nos_low, nos_high 
    or   tos_low, nos_low 
    or   tos_high, nos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w1 w2 -- w2 XOR w1 ) 
; 
HEADER "XOR", "XOR" 
    NOOP 
    pspull nos_low, nos_high 
    eor  tos_low, nos_low 
    eor  tos_high, nos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w -- w * 2 ) same as shift left << 1, unsigned 
; 
HEADER "2*", "SHL" 
    NOOP 
_shl: 
    clc 
    lsl   tos_low 
    rol   tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w -- w / 2 ) same as shift right >> 1, unsigned 
; 
HEADER "2/", "SHR" 
    NOOP 
_shr: 
    clc 
    lsr tos_low 
    ror tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( nAnB -- nBnA ) swap bytes in a word 
HEADER "><", "ENDIAN" 
    NOOP 
    mov _work_, tos_low
    mov tos_low, tos_high
    mov tos_high, _work_
    POON 
 
;---------------------------------------------------------------------- 
;  os DOCON ( -- w ), (IP++) -> Tos
;   inverse of comma 
;   from flash to data stack 
;   was DOLIT
HEADER "DOCON", "DOCON" 
    NOOP 
    pspush tos_low, tos_high
    movw zpm_low, ips_low 
    pmload tos_low, tos_high 
    movw ips_low, zpm_low 
    POON 
 
;---------------------------------------------------------------------- 
;  os DOVAR ( -- w ), IP++ -> Tos 
;  from flash to data stack 
; 
HEADER "DOVAR", "DOVAR" 
    NOOP 
    pspush tos_low, tos_high
    movw tos_low, ips_low 
    adiw tos_low, 2
    movw ips_low, tos_low
    sbiw tos_low, 2
    POON 
 
;---------------------------------------------------------------------- 
; ok C! ( c a -- ) 
; only works in sram
HEADER "C!", "CTO" 
    NOOP 
    movw zpm_low, tos_low
    pspull tos_low, tos_high
    st Z, tos_low
    pspull tos_low, tos_high 
    rjmp TO 
 
;---------------------------------------------------------------------- 
; ok C@ ( a -- c ) 
; only works in sram
HEADER "C@", "CAT" 
    NOOP 
    movw zpm_low, tos_low
    ld tos_low, Z
    clr tos_high
    rjmp AT 
 
;---------------------------------------------------------------------- 
; ok INV 
HEADER "INVERT", "INVERT" 
    NOOP 
_inv: 
    com tos_low 
    com tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok NEG 
HEADER "NEGATE", "NEGATE" 
    NOOP 
_neg: 
    neg tos_low 
    neg tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( w -- w ) 
;  data space pointer align to CELL, atmega is always 
 
HEADER "ALIGN", "ALLIGN" 
    NOOP 
    adiw tos_low, 1 
    cbr tos_low, 0 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( -- CELL ) 
; CELL is 2 ; size of a cell 
; 
HEADER "CELL", "CELL" 
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, CELL_SIZE 
    clr tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( a1 a2 u -- 0 | 1) 
; compare bytes from source++ to destination++, decrease count-- 
; returns 0 if equal (no differ) 
; 
HEADER "CSAME", "CSAME" 
    NOOP 
    ; WARNING No bound check and counter equal 0 moves nothing 
 
    ; pull address source 
    pspull zpm_low, zpm_high 
 
    ; pull address destin 
    pspull nos_low, nos_high 
 
    ; no offset 
 
    ; free Y
    rspush psp_low, psp_high
    movw psp_low, nos_low

1: 
    mov _work_, tos_low
    or _work_, tos_high
    brbs BIT_ZERO, 2f
 
    ld wrk_low, Y+ 
    ld wrk_high, Z+ 
    or wrk_low, wrk_high 
    brbc BIT_ZERO, 3f 
 
    ; again 
    sbiw tos_low, 1
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
    POON 
 
;---------------------------------------------------------------------- 
; ok ( s d u -- ) 
; 
; MOVE (forward) copy bytes from source++ to destination++, decrease count-- 
HEADER "CMOVE", "CMOVE" 
    NOOP 
    ; WARNING No bound check and counter equal 0 moves nothing 
 
    ; pull address source 
    pspull zpm_low, zpm_high 
 
    ; pull address destin 
    pspull nos_low, nos_high 
 
    ; free Y
    rspush psp_low, psp_high
    movw psp_low, nos_low

    ; no offset 
 
1: 
    mov _work_, tos_low
    or _work_, tos_high
    brbs BIT_ZERO, 2f
 
    ; move a cell 
    ld _work_, Y+ 
    st Z+, _work_ 
 
    ; again 
    sbiw tos_low, 1
    rjmp 1b 
 
2: 
    ; pull psp 
    rspull psp_low, psp_high 
    POON 
 
;---------------------------------------------------------------------- 
; ok ( s d u -- ) 
; 
; MOVE (backward) copy bytes from source-- to destination--, decrease count-- 
HEADER "BMOVE", "BMOVE" 
    NOOP 
    ; WARNING No bound check and counter equal 0 moves nothing 
 
    ; pull address source 
    pspull zpm_low, zpm_high 
 
    ; pull address destin 
    pspull nos_low, nos_high 
 
    ; free Y
    rspush psp_low, psp_high
    movw psp_low, nos_low

    ; do offset
    add zpm_low, tos_low
    adc zpm_high, tos_high
    add psp_low, tos_low
    adc psp_high, tos_high
 
    ; move a byte
1:
    mov _work_, tos_low
    or _work_, tos_high
    brbs BIT_ZERO, 2f
 
    ld _work_, -Y
    st -Z, _work_

    ; again 
    sbiw tos_low, 1
    rjmp 1b 

2:
    ; pull psp
    rspull psp_low, psp_high
    POON

;********************************************************************** 
; FORTH
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
; ok ( w3 w2 w1 -- w2 w3 w1 ) 
; 
HEADER "BIS", "BIS" 
    .word TOR, SWAP, RTO, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w2 w1 -- w2 w1 w2 ) 
; 
HEADER "OVER", "OVER" 
    .word SWAP, DUP, BIS, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w3 w2 w1 -- w2 w1 w3 ) 
; 
HEADER "ROT", "ROTU" 
    .word BIS, SWAP, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w3 w2 w1 -- w1 w3 w2 ) 
; 
HEADER "-ROT", "ROTD" 
    .word SWAP, BIS, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w2 w1 --  w1 w2 w1 ) 
; 
HEADER "TUCK", "TUCK" 
    .word DUP, BIS, ENDS 
 
;---------------------------------------------------------------------- 
; ok ( w3 w2 w1 --  w1 w2 w3 ) 
; 
HEADER "FLIP", "FLIP" 
    .word SWAP, BIS, SWAP, ENDS 

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
 
;**********************************************************************
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
    .word LATEST, TONFA, F_COMPILE, TOGGLE, ENDS 

;---------------------------------------------------------------------- 
; 
; ok HERE 
; 
HEADER  "HERE", "HERE", 
    .word FLASH_LAST, AT, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok ALLOT 
; 
HEADER  "ALLOT", "ALLOT", 
    .word FLASH_LAST, PLUSTO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok COMMMA ( w -- ) 
HEADER  ",", "COMMA", 
    .word HERE, TO, CELL, ALLOT, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok this puts next cell into stack and compiles into HERE 
; 
HEADER  "COMP", "COMP", 
    .word DOCON, COMMA, ENDS 
 
;----------------------------------------------------------------------
; ok compile a eow 
HEADER "FINITE", "FINITE"
    .word COMP, ENDS, ENDS

;----------------------------------------------------------------------
; ok compile a header 
HEADER "CREATE", "CREATE"
    .word ENDS

;----------------------------------------------------------------------
; ok gets a cc<chars>cc from source
;   ( -- a n )
HEADER "PARSE", "PARSE"
    .word ENDS
/*
          TOIN @ TIB @ TIB_SIZE PLUS MINUS <0 IF REFILL THEN
          TOIN @ 
          BEGIN DUP C@ 
            DUP ZERO = IF REFILL ??? THEN 
            BL = IF 1+ FALSE ELSE TRUE THEN UNTIL
          DUP BEGIN DUP C@ 
            DUP ZERO = IF REFILL ??? THEN 
            BL = INVERT IF 1+ FALSE ELSE TRUE THEN UNTIL
          DUP TOIN ! MINUS ENDS
*/

;---------------------------------------------------------------------- 
; ok  
HEADER  ":", "COLON", 
    .word CREATE, RBRAC, ENDS 
 
;---------------------------------------------------------------------- 
; ok  
HEADER  ";", "SEMMI", 
    .word FINITE, LBRAC, ENDS 
  
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
 
