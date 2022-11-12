
/*
 *  DISCLAIMER
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
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
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
; .ascii "name"  name, plus a pad byte with BL (0x32) if size is even 
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
; memory pointer r30:r31 as Z 
; parameter stack pointer r28:r29 as Y 
; return stack pointer r26:r27 as X 
; top of stack r24:r25 
; nos, temporary next of stack r22:r23 
; wrk, temporary working r20:r21 
;
; _zero_, always zero, keeped by timer0
; _work_, scratch
;
; Can only use LPM to access flash memory ? YES! 
;
; forth: all constants in flash
;
; user: no constants and variables in sdram 
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
; on AVR use Z for access flash
;
;   temporary use zpm, wrk, _word_
;
HEADER "ENDS", "ENDS", F_LEAP
; does nothing and mark as primitive 
    NOOP 
 
; pull ips from rsp 
_unnest:  
    rspull zpm_low, zpm_high 
    ; rjump _next
 
; load w with contents of cell at ips 
_next: 
    pmload wrk_low, wrk_high ; also increments zpm 
 
; if zero (NULL) is a primitive word 
_void:
    or wrk_low, wrk_high 
    brbs BIT_ZERO, _jump
 
; else is a reference ( 2 extra cycles )
_nest: 
    rspush zpm_low, zpm_high ; push next reference 
    movw zpm_low, wrk_low ; point to this reference 
    rjmp _next 
 
; then jump, for exec it 
_jump: 
    ijmp 
 
; then link, for continue 
_link: 
    rjmp _unnest 
 
;********************************************************************** 
;
;   bios i/O 
;
;----------------------------------------------------------------------
;
; ok ( -- w) 
; beware, it blocks while test if can receive a char 
;
HEADER "KEY", "KEY", F_LEAP
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
;
; ok ( -- FALSE | TRUE ) 
; test if can receive a char, or return FALSE 
;
HEADER "KEY?", "QKEY", F_LEAP
    NOOP 
3: 
    sbis 0x0b, 7 
    rjmp _iffalse 
    rjmp _iftrue 
 
;----------------------------------------------------------------------
;
; ok ( w -- ) 
; beware, it blocks while test if can send a char 
;
HEADER "EMIT", "EMIT", F_LEAP
    NOOP 
1: 
    sbis 0x0b, 5 
    rjmp 1b 
2: 
    out 0x0c, tos_low 
    pspull tos_low, tos_high
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- FALSE | TRUE ) 
; test if can send a char, or return FALSE 
;
HEADER "EMIT?", "QEMIT", F_LEAP
    NOOP 
3: 
    sbis 0x0b, 5 
    rjmp _iffalse 
    rjmp _iftrue 
 
;----------------------------------------------------------------------
;
; ok ( c e -- ) 
;   write a byte to eprom 
;
HEADER "C!E", "CTOEE", F_LEAP
    NOOP 
    pspull nos_low, nos_high

_ee_write:
; Wait for completion of previous write
    sbic EECR, EEWE
    rjmp _ee_write

; Set up address  in address register
    out EEARH, tos_high
    out EEARL, tos_low

; Write data to Data Register
    out EEDR, nos_low

; prepare    
    cli
    in r2, __SREG__

; Write logical one to EEMPE
    sbi EECR, EEMWE
; Start eeprom write by setting EEWE
    sbi EECR, EEWE

; restore
    out __SREG__, r2
    sei
    POON

;----------------------------------------------------------------------
;
; ok ( e -- u ) 
;   read eeprom
;
HEADER "C@E", "CATEE", F_LEAP
    NOOP 
    pspull nos_low, nos_high

_ee_read:
; Wait for completion of previous write
    sbic EECR, EEWE
    rjmp _ee_read

; Set up address in address register
    out EEARH, tos_high
    out EEARL, tos_low

; Start eeprom read by writing EERE
    sbi EECR, EERE
; Read data from Data Register
    in tos_low, EEDR
    clr tos_high
    POON

;----------------------------------------------------------------------
;
; ok ( w -- u ) 
; also io@
; only sram
;
HEADER "C@P", "CATIO", F_LEAP
    NOOP 
_peek:
    movw zpm_low, tos_low  
    ld tos_low, Z
    clr tos_high
    POON

;----------------------------------------------------------------------
;
; ok ( u w -- ) 
; also io!
; only sram
;
HEADER "C!P", "CTOIO", F_LEAP
    NOOP
_poke:
    movw zpm_low, tos_low  
    st Z, tos_low
    pspull tos_low, tos_high
    POON
    
;----------------------------------------------------------------------
;
; ok ( -- w) 
; push timer counter 
;
HEADER "MILLIS", "MILLIS", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    mov tos_low, ticks_low 
    mov tos_high, ticks_high 
    POON 
 
;********************************************************************** 
;
;   primitive words 
;
;----------------------------------------------------------------------
 
;----------------------------------------------------------------------
;
; ok ( -- -1 ) 
;
HEADER "TRUE", "FTRUE", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
_iftrue: 
    ser tos_low 
    ser tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- 0 ) 
;
HEADER "FALSE", "FFALSE", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
_iffalse: 
    clr tos_low 
    clr tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok 0= 
;
HEADER "0=", "ZEQU", F_LEAP
    NOOP 
    adiw tos_low, 0
    brbs BIT_ZERO, _iftrue
    brbc BIT_ZERO, _iffalse
    POON
 
;----------------------------------------------------------------------
;
; ok 0< 
;
HEADER "0<", "ZLTH", F_LEAP
    NOOP 
    ; 0x80
    andi tos_high, 0x80
    brbc BIT_ZERO, _iftrue
    brbs BIT_ZERO, _iffalse
    POON

;----------------------------------------------------------------------
;
; ok ( u1 u2 -- f ) 
;   unsigned lessthan 
;   if u1 < u2, true, else, false
;
HEADER "U<", "UMLESS", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    clc 
    cp  nos_low, tos_low 
    cpc nos_high, tos_high 
1:    
    brlt 2f 
    rjmp _iffalse
2:
    rjmp _iftrue
    POON

;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w3 f ) 
;   unsigned plus 
;
HEADER "UM+", "UMPLUS", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    clc 
    add tos_low, nos_low 
    adc tos_high, nos_high 
    pspush tos_low, tos_high
    ; preserve carry
1:
    clr tos_high
    clr tos_low
2:    
    brcc 3f
    inc tos_low
3:
    POON 
 
;----------------------------------------------------------------------
;
; ok ! to (w a -- ) 
; only in sram 
;
HEADER "!", "TO", F_LEAP
    NOOP 
    movw  zpm_low, tos_low
    pspull tos_low, tos_high 
    srsave tos_low 
    srsave tos_high
    pspull tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok @ at ( a -- w ) 
; only in sram 
;
HEADER "@", "AT", F_LEAP
    NOOP 
    movw zpm_low, tos_low 
    srload tos_low 
    srload tos_high 
    POON
 
;----------------------------------------------------------------------
;
; ok ( w -- ) ( -- W) 
;
HEADER ">R", "TOR", F_LEAP
    NOOP 
    rspush tos_low, tos_high 
    pspull tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- w ) ( w -- ) 
;
HEADER "R>", "RTO", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    rspull tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- w ) ( w -- w ) 
;
HEADER "R@", "RAT", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    rspull tos_low, tos_high 
    rspush tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( rsp -- ) 
;
HEADER "RS!", "RSTO", F_LEAP
    NOOP 
    movw rsp_low, tos_low 
    pspull tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( psp -- ) 
;
HEADER "PS!", "PSTO", F_LEAP
    NOOP 
    movw psp_low, tos_low 
    pspull tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- rsp) 
; put the address to top of return stack at tos
;
HEADER "RS@", "RSAT", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    movw tos_low, rsp_low 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- psp ) 
; put the address to top of parameter stack at tos
;
HEADER "PS@", "PSAT", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    movw tos_low, psp_low 
    POON 

;----------------------------------------------------------------------
;
; ok ( w -- ) 
;     
;
HEADER "DROP", "DROP", F_LEAP
    NOOP
PULL: 
    pspull tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w -- w w) 
;
HEADER "DUP", "DUP", F_LEAP
    NOOP 
PUSH:
    pspush tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w2 w1 -- w1 w2 ) 
;
HEADER "SWAP", "SWAP", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    pspush tos_low, tos_high 
    movw tos_low, nos_low
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w2 w1 -- w2 w1 w2 ) 
;
HEADER "OVER", "OVER", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    pspush nos_low, nos_high 
    pspush tos_low, tos_high 
    movw tos_low, nos_low
    POON 
 
;----------------------------------------------------------------------
;
; ok ( 0 | w -- 0 | w w ) 
; dup if tos not zero 
;
HEADER "?DUP", "ZDUP", F_LEAP
    NOOP 
    cp tos_low, tos_high
    brbs BIT_ZERO, 1f 
    pspush tos_low, tos_high 
1: 
    POON 

;----------------------------------------------------------------------
;
; ok ( w1 w2 -- 0 | -1 ) 
;
HEADER "<", "LTHAN", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    cp tos_low, nos_low 
    cpc tos_high, nos_high 
    brlt 1f 
    rjmp _iffalse
1:
    rjmp _iftrue
    POON
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w2 + w1 ) 
;   signed plus
;
HEADER "+", "PLUS", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    clc 
    add tos_low, nos_low 
    adc tos_high, nos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w1 - w2 ) 
;   signed minus, 0 5 -- -5
;
HEADER "-", "MINUS", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    clc 
    sub nos_low, tos_low 
    sbc nos_high, tos_high 
    movw tos_low, nos_low
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w2 NAND w1 ) 
;
HEADER "NAND", "NAND", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    and tos_low, nos_low 
    and tos_high, nos_high 
    com nos_low 
    com nos_high 
    POON 

;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w2 AND w1 ) 
;
HEADER "AND", "AND", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    and  tos_low, nos_low 
    and  tos_high, nos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w2 OR w1 ) 
;
HEADER "OR", "OR", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    or   tos_low, nos_low 
    or   tos_high, nos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w2 XOR w1 ) 
;
HEADER "XOR", "XOR", F_LEAP
    NOOP 
    pspull nos_low, nos_high 
    eor  tos_low, nos_low 
    eor  tos_high, nos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok INV 
;
HEADER "INVERT", "INVERT", F_LEAP
    NOOP 
_inv: 
    com tos_low 
    com tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok NEG 
;
HEADER "NEGATE", "NEGATE", F_LEAP
    NOOP 
_neg: 
    neg tos_low 
    neg tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w -- w * 2 ) same as shift left << 1, unsigned 
;
HEADER "2*", "SHL", F_LEAP
    NOOP 
_shl: 
    clc 
    lsl   tos_low 
    rol   tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w -- w / 2 ) same as shift right >> 1, unsigned 
;
HEADER "2/", "SHR", F_LEAP
    NOOP 
_shr: 
    clc 
    lsr tos_low 
    ror tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( nAnB -- nBnA ) swap bytes in a word 
;
HEADER "><", "ENDIAN", F_LEAP
    NOOP 
    mov wrk_low, tos_low
    mov tos_low, tos_high
    mov tos_high, wrk_low
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- ) ( branch next reference ) 
;   no more offsets then no more branch
HEADER "BRANCH", "BRANCH", F_LEAP
    NOOP 
_branch: 
    rspull zpm_low, zpm_high 
    pmload nos_low, nos_high 
    rspush nos_low, nos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( u -- ) 
; if tos is not zero, skip next 
; 
HEADER "0BRANCH", "ZBRANCH", F_LEAP
    NOOP 
    movw nos_low, tos_low
    pspull tos_low, tos_high
    cp nos_low, nos_high
    brbs BIT_ZERO, _branch 
    ; skips
    rspull zpm_low, zpm_high 
    adiw zpm_low, 2 
    rspush zpm_low, zpm_high 
    POON
 
;----------------------------------------------------------------------
;
;  ok LIT ( -- w ), 
;  push a value from flash to data stack 
;  
HEADER "LIT", "LIT", F_LEAP
    NOOP 
    pspush tos_low, tos_high
    rspull zpm_low, zpm_high
    pmload tos_low, tos_high 
    rspush zpm_low, zpm_high
    POON 
 
;----------------------------------------------------------------------
;
; ok ( w -- w ) 
;  data space pointer align to CELL, atmega is always 
 
;
HEADER "ALIGNED", "ALIGNED", F_LEAP
    NOOP 
    adiw tos_low, 1 
    cbr tos_low, 0 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- CELL ) 
; CELL is 2 ; size of a cell 
;
HEADER "CELL", "CELL", F_LEAP
    NOOP 
    pspush tos_low, tos_high
    ldi tos_low, CELL_SIZE 
    clr tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok C! ( c a -- ) 
; only works in sram
;
HEADER "C!", "CTO", F_LEAP
    NOOP 
    movw zpm_low, tos_low
    pspull tos_low, tos_high
    st Z, tos_low
    pspull tos_low, tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok C@ ( a -- c ) 
; only works in sram
;
HEADER "C@", "CAT", F_LEAP
    NOOP 
    movw zpm_low, tos_low
    ld tos_low, Z
    clr tos_high
    POON 
;----------------------------------------------------------------------
;
; ok ( -- 0 ) 
;
HEADER "0", "ZERO", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    clr tos_low 
    clr tos_high 
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- 1 ) 
;
HEADER "1", "ONE", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    clr tos_high 
    ldi tos_low, 1
    POON 

;----------------------------------------------------------------------
;
; ok ( -- 0 ) 
;
HEADER "2", "TWO", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    clr tos_high 
    ldi tos_low, 2
    POON 
 
;----------------------------------------------------------------------
 
