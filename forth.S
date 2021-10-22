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

/*
;
;    Small Forth for ATmega8
;
;---------------------------------------------------------------------
; dictionary structure
;    
;    cell size is a word of 16 bits
;
 .word  link    link to previous
 .byte  size    sizeof name OR flags
 .ascii "name" name, plus a pad byte with BL (0x32) if size is odd
 .word  param,  many

;----------------------------------------------------------------------

*/

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
.section .text
.org 0x100
.global forth
forth:
;----------------------------------------------------------------------
; inner interpreter,
; it is also a primitive word
;
HEADER "ENDS", "ENDS"
; does nothing and mark as primitive
    NOOP

; pull ips from rsp
_exit:             
    rspull zpm_low, zpm_high

; load w with contents of cell at ips 
_next:            
    pmload wrk_low, wrk_high ; also increments zpm

; if not zero then is a compound word, aka a twig, go to _enter
    ;*** must test for NULL
    
    cpi wrk_low, 0
    brne _enter
    cpi wrk_high, 0
    brne _enter

; else branch and link, for exec it 
_branch:
    movw wrk_low, zpm_low   ; copy this reference
    adiw wrk_low, 2         ; point to next reference
    movw ipr_low, wrk_low   ; keep this reference
    ijmp

_link:
    movw zpm_low, ipr_low ; points to next reference
    rjmp _next

; else is a reference
_enter:            
    rspush zpm_low, zpm_high ; push next reference
    movw zpm_low, wrk_low ; point to this reference
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
HEADER "0=", "ZEROEQU"
    NOOP
    pspull wrk_low, wrk_high
	or wrk_low, wrk_high
	cpi wrk_low, 0
    brne _ffalse 
_ftrue:
    ser wrk_low
    ser wrk_high
    WOOP

;----------------------------------------------------------------------
; ok ! to (x a -- )
; only in sram
HEADER "!", "TO"
    NOOP
    pspull zpm_low, zpm_high
    pspull wrk_low, wrk_high
    srsave wrk_low
    srsave wrk_high
    POON

;----------------------------------------------------------------------
; ok @ at ( a -- w )
; only in sram
HEADER "@", "AT"
    NOOP
    pspull zpm_low, zpm_high
    srload wrk_low
    srload wrk_high
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
    and wrk_high, tos_high
    and wrk_low, tos_low
    com wrk_high
    com wrk_low
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
;**********************************************************************

;----------------------------------------------------------------------
;    load variables

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
HEADER "HERE", "here_"
    NOOP
    ldi wrk_low, lo8(HERE)
    ldi wrk_high, hi8(HERE)
    WOOP

;----------------------------------------------------------------------
; ok ( -- w)
;
HEADER "LATEST", "last_"
    NOOP
    ldi wrk_low, lo8(LAST)
    ldi wrk_high, hi8(LAST)
    WOOP

;----------------------------------------------------------------------
; ok ( -- w)
;
HEADER "STATE", "state_"
    NOOP
    ldi wrk_low, lo8(STAT)
    ldi wrk_high, hi8(STAT)
    WOOP

;----------------------------------------------------------------------
; ok ( -- w)
;
HEADER "BASE", "base_"
    NOOP
    ldi wrk_low, lo8(BASE)
    ldi wrk_high, hi8(BASE)
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
;
; ok ( -- w)
; beware, it blocks! test if can receive a char
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
; beware, it blocks! test if can send a char 
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

;----------------------------------------------------------------------
;
; ( --- ) 
; tricky 
; iBUGGED ZZZZ NOT REALLY 
; all new word starts at THIS=0, 1 and 2 bytes is link, 3 byte is size+flags
HEADER "(immediate)", "immediate"
    NOOP
    ldi zpm_low, lo8(LINE)
    ldi zpm_high, hi8(LINE)
    adiw zpm_low, 2
    srload wrk_low
    ori wrk_low, F_IMMEDIATE
    sbiw zpm_low, 1
    srsave wrk_low
    POON
    
;----------------------------------------------------------------------
;
; ok ( --- w ) 
; ????
; push the value pointed by next to stack, updates next
; only for flash
; push the value pointed by next into stack
HEADER "(dovar)", "doref"
    NOOP
    movw zpm_low, ipr_low
    pmload wrk_low, wrk_high
    movw ipr_low, zpm_low
    WOOP

;----------------------------------------------------------------------
;
; ok ( --- w )
; ????
; push the value of next to stack, updates next
; only for flash
; push next to stack
HEADER "(docon)", "doval"
    NOOP
    movw zpm_low, ipr_low
    movw wrk_low, zpm_low
    adiw zpm_low, 2
    movw ipr_low, zpm_low
    WOOP

;----------------------------------------------------------------------
; ok ( w1 w2 -- 0 | -1)
;
HEADER "=", "EQUAL"
    NOOP
    pspull wrk_low, wrk_high
    pspull tos_low, tos_high
    cp wrk_low, tos_low
    cpc wrk_high, tos_high
    brne _iffalse
    rjmp _iftrue

;----------------------------------------------------------------------
; ok ( w1 w2 -- 0 | -1)
;
;
HEADER "<>", "NOTEQUAL"
    NOOP
    pspull wrk_low, wrk_high
    pspull tos_low, tos_high
    cp wrk_low, tos_low
    cpc wrk_high, tos_high
    breq _iffalse
    rjmp _iftrue

;----------------------------------------------------------------------
; nok ( w1 w2 -- 0 | -1 )
;
;
HEADER "<", "LTHAN"
    NOOP
    pspull wrk_low, wrk_high
    pspull tos_low, tos_high
    cp wrk_low, tos_low
    cpc wrk_high, tos_high
    brcs _iffalse
    rjmp _iftrue

;----------------------------------------------------------------------
; nok ( w1 w2 -- 0 | -1 )
;
HEADER ">", "GTHAN"
    NOOP
    pspull wrk_low, wrk_high
    pspull tos_low, tos_high
    cp wrk_low, tos_low
    cpc wrk_high, tos_high
    brcc _iffalse
    rjmp _iftrue

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
;  ok 0>    must be signed
;
HEADER "0>", "ZEROGT"
    NOOP
    pspull wrk_low, wrk_high
    sbiw wrk_low, 1
    brge _iffalse
    rjmp _iftrue

;----------------------------------------------------------------------
;  ok 0<
;
HEADER "0<", "ZEROLT"
    NOOP
    pspull wrk_low, wrk_high
    sbiw wrk_low, 1
    brge _iftrue
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
; ok ( w -- ) 
HEADER "P@", "SAT"
    NOOP
	movw wrk_low, psp_low
    WOOP

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
HEADER "DUP", "DUP"
    NOOP
    pspull wrk_low, wrk_high
    pspush wrk_low, wrk_high
    WOOP

;----------------------------------------------------------------------
; ok ( w1 w2 -- w2 w1 )
HEADER "SWAP", "SWAP"
    NOOP
    pspull tos_low, tos_high
    pspull wrk_low, wrk_high
    pspull tos_low, tos_high
    WOOP

;----------------------------------------------------------------------
; ok ( w1 w2 -- w1 w2 w1 )
;     F18A over
HEADER "OVER", "OVER"
    NOOP
    pspull tos_low, tos_high
    pspull wrk_low, wrk_high
    pspush wrk_low, wrk_high
    pspush tos_low, tos_high
    WOOP

;----------------------------------------------------------------------
; ok ( w1 w2 w3 -- w2 w3 w1 )
HEADER "ROT", "ROT"
    NOOP
    pspull tos_low, tos_high
    pspull nds_low, nds_high
    pspull wrk_low, wrk_high
    pspush nds_low, nds_high
    pspush tos_low, tos_high
    WOOP

;----------------------------------------------------------------------
; ok ( w -- 0 | w w )
; dup if tos not zero
;
HEADER "?DUP", "ZDUP"
    NOOP
    pspull wrk_low, wrk_high
    cpi wrk_low, 0
    brne 1f
    cpi wrk_high, 0
    brne 1f
    WOOP
1:
    pspush wrk_low, wrk_high
    WOOP

;----------------------------------------------------------------------
; ok ( u -- )
; branch IF tos IS zero
;
HEADER "?BRANCH", "QBRANCH"
    NOOP
    pspull wrk_low, wrk_high
    cpi wrk_low, 0
    brne 1f
    cpi wrk_high, 0
    brne 1f
; goto branch
    rjmp 2f 
; skip next
1:
    movw wrk_low, ipr_low
    adiw wrk_low, 2
    movw ipr_low, wrk_low
    POON

;----------------------------------------------------------------------
; ok ( branch next reference )
;
HEADER "BRANCH", "BRANCH"
    NOOP
2:
    movw zpm_low, ipr_low
    pmload wrk_low, wrk_high
    movw ipr_low, wrk_low
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

;----------------------------------------------------------------------
; ok ( w -- w / 2 ) same as shift right >> 1, signed
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
;  os doLIT ( -- w ), inverse of comma
;  from flash to data stack
;
HEADER "DOLIT", "DOLIT"
    NOOP
; load from flash program memory
    movw zpm_low, ipr_low
    pmload wrk_low, wrk_high
    movw ipr_low, zpm_low
    WOOP

;----------------------------------------------------------------------
;  zzz doVAR ( -- w ) from sram memory to data stack
;
HEADER "DOCON", "DOCON"
    NOOP
    WOOP

;----------------------------------------------------------------------
;  zzz doVAR ( -- w ) from sram memory to data stack
HEADER "DOVAR", "DOVAR"
    NOOP
    WOOP

; pointer for a sram ref
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
HEADER "INV", "INV"
    NOOP
    pspull wrk_low, wrk_high
_inv:
    com wrk_low
    com wrk_high
    WOOP

;----------------------------------------------------------------------
; ok NEG
HEADER "NEG", "NEG"
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
; ok ???? ( a1 u1 a2 u2 -- flag)
; compare bytes from source++ to destination++, decrease count--
;
HEADER "COMPARE", "COMPARE"
    NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

    ; pull lenght 
    pspull tos_low, tos_high

    ; pull address
    pspull zpm_low, zpm_high
    
    ; pull lenght
    pspull nds_low, nds_high

    ; pull address
    pspull wrk_low, wrk_high

    ; push psp
    rspush psp_low, psp_high

    ; copy address
    movw psp_low, wrk_low

    ; no offset

1:  
    cp  tos_low, tos_high
    brbs BIT_ZERO, 2f

    cp  nds_low, nds_high
    brbs BIT_ZERO, 2f

    ld wrk_low, X+
    ld wrk_high, Z+
    cp wrk_low, wrk_high
    brbc BIT_ZERO, 3f

    subi tos_low, 1
    sbci tos_high, 0

    subi nds_low, 1
    sbci nds_high, 0

    ; again
    rjmp 1b

2:  
    cp tos_low, nds_low
    brbc BIT_ZERO,3f

    cp tos_high, nds_high
    brbc BIT_ZERO, 3f

    clr wrk_low
    clr wrk_high
    rjmp 4f

3:  
    ser wrk_low
    ser wrk_high

4:  
    rspull psp_low, psp_high
    WOOP

;----------------------------------------------------------------------
; ok ???? ( u w w -- )
;
; MOVE copy cells from source++ to destination++, decrease count--
HEADER "MOVE", "MOVE"
    NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

    ; pull origin
    pspull tos_low, tos_high
    
    ; pull destination
    pspull zpm_low, zpm_high

    ; pull counter
    pspull wrk_low, wrk_high

    ; test if zero
    cp wrk_low, wrk_high
    brbs BIT_ZERO, 2f

    ; push psp
    rspush psp_low, psp_high

    ; copy orign
    movw psp_low, tos_low

    ; no offset

1:  
      ; move a cell
    ld _work_, X+
    st Z+, _work_
    ld _work_, X+
    st Z+, _work_
    
    ; decrease counter
    sbiw wrk_low, 1

    ; again
    brbc BIT_ZERO, 1b

    ; pull psp
2:    
    rspull psp_low, psp_high
    POON


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
HEADER "CELL", "CELLSZ"
    NOOP
    ldi wrk_low, CELL_SIZE
    clr wrk_high
    WOOP

;----------------------------------------------------------------------
; ok ( w -- w * CELL  )
; CELL is 2, multiply by 2, easy way
;
HEADER "CELLS", "CELLS"
    NOOP
    rjmp SHL+2

;----------------------------------------------------------------------
;
; ok ( w -- w + CELL )
;
HEADER "CELL+", "CELLPLUS"
    NOOP
    pspull wrk_low, wrk_high
    adiw wrk_low, CELL_SIZE
    WOOP

;----------------------------------------------------------------------
;
; ok ( w -- w - CELL )
;
HEADER "CELL-", "CELLMINUS"
    NOOP
    pspull wrk_low, wrk_high
    sbiw wrk_low, CELL_SIZE
    WOOP

;----------------------------------------------------------------------
;
; ok ( w -- w + 1 )
;
HEADER "1+", "ONEPLUS"
    NOOP
    pspull wrk_low, wrk_high
    adiw wrk_low, 1
    WOOP

;----------------------------------------------------------------------
;
; ok ( w -- w - 1 )
;
HEADER "1-", "ONEMINUS"
    NOOP
    pspull wrk_low, wrk_high
    sbiw wrk_low, 1
    WOOP

;----------------------------------------------------------------------
;
; ok ( w -- w + 2 )
;
HEADER "2+", "TWOPLUS"
    NOOP
    pspull wrk_low, wrk_high
    adiw wrk_low, 2
    WOOP

;----------------------------------------------------------------------
;
; ok ( w -- w - 2 )
;
HEADER "2-", "TWOMINUS"
    NOOP
    pspull wrk_low, wrk_high
    sbiw wrk_low, 2
    WOOP

;----------------------------------------------------------------------
;
; ok ( u w -- ) 
;
HEADER "+!", "PLUSTO"
    NOOP
    pspull zpm_low, zpm_high
    pspull tos_low, tos_high
    srload wrk_low
    srload wrk_high
    clc
    add wrk_low, tos_low
    adc wrk_low, tos_low
    sbiw zpm_low, 2
    srsave wrk_low
    srsave wrk_high
    POON

