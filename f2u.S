
/*
 *  DISCLAIMER:
 *
 *  Copyright © 2020, Alvaro Barcellos,
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

/* get some magic constants */

;----------------------------------------------------------------------
#include <avr/io.h>

;----------------------------------------------------------------------
;
; 02/12/2020
;
; Alvaro Gomes Sobral Barcellos
;
; u2forth
;

/*

  inspired on eforth from books and papers from C. H. Ting
 
  just experience for small microcontrolers
 
  emulates a virtual uCi, really, really, 
	
  just using SEG and PC, ((0x3D) + 0x20) is reserved for interrups (future)
 
  still no interrupts
 
  still no multitasks
 
/*
;----------------------------------------------------------------------
; dictionary structure
;
 .word  link    link to previous
 .byte  size    sizeof name OR mask 0x1F
 .ascii "name"   name, plus a pad byte with BL (0x32) if size is odd
 .word  param,   many
*/

;----------------------------------------------------------------------

18/04/2021
	Rewrite all from u2f*, using a new minimal forth engine as NOOP word 

*/

    .NOLIST

    .LIST

;----------------------------------------------------------------------
#include "equates.inc" 

;----------------------------------------------------------------------
#include "macros.inc"

;----------------------------------------------------------------------
#include "boot.inc"

;----------------------------------------------------------------------
; start of dictionary
;
;----------------------------------------------------------------------


;----------------------------------------------------------------------
;
; forth engine,
;
LEAF 3, "NOOP"
NOOP:
	NOOP
_EXIT:
	ld r31, Y+
	ld r30, Y+
_THIS:
	ld r25, Z+
	ld r24, Z+
_EXEC:
	mov r0, r25
	or  r0, r24
	brne _ENTER
	ijmp
_ENTER:
	st -Y, r30
	st -Y, r31
_NEXT:
	movw r30, r24
	rjmp _THIS
 
;----------------------------------------------------------------------
; init instruction pointer and etc
;
LEAF 3, "BYE"
BYE:
	NOOP
	rjmp RESET
	POON

;----------------------------------------------------------------------
;
; init return stack
;
LEAF 5, "ABORT"
ABORT:
	NOOP
;	init registers
    eor _work_, _work_
    eor _zero_, _zero_
    eor tos_high, tos_high
    eor tos_low, tos_low
    eor nds_high, nds_high
    eor nds_low, nds_low
    eor wrk_high, wrk_high
    eor wrk_low, wrk_low
    ldi zh, hi8(_INIT)
    ldi zl, lo8(_INIT)
; init return stack
    ldi rsp_high, hi8(RSP_TOP)
    ldi rsp_low, lo8(RSP_TOP)
	rjmp QUIT

;----------------------------------------------------------------------
;
; init parameter stack
;
LEAF 4, "QUIT"
QUIT:
; init parameter stack
    ldi psp_high, hi8(PSP_TOP)
    ldi psp_low, lo8(PSP_TOP)
	rjmp NOOP

;----------------------------------------------------------------------
;
; init registers 
;

;----------------------------------------------------------------------
; ok push a value from flash into parameter stack
;
LEAF 4, "NOOP"
NOOP:
    rjmp CORE

;----------------------------------------------------------------------
#include "uart.inc"

;----------------------------------------------------------------------
; ok push a value from flash into parameter stack
;
LEAF 7, "doLIT"
DOLIT:
    pspush nds_low, nds_high
    movw nds_low, tos_low
    next_wrk
    rjmp CORE

;----------------------------------------------------------------------
; get address of a variable ????
;
LEAF 4, "doVAR"
DOVAR:
    ; zzz ?
    rjmp CORE

;----------------------------------------------------------------------
; get address of a constant ????
;
LEAF 4, "doCON"
DOCON:
    ; zzz ?
    rjmp CORE

;----------------------------------------------------------------------
;
; ok if 0 branch ( a -- F | T )
;
LEAF 7, "?BRANCH"
QMBRANCH:
	pull_wrk
    sbiw wrk_low, 1
    breq BRANCH
    rjmp CORE

;----------------------------------------------------------------------
; ok branch
LEAF 6, "BRANCH"
BRANCH:
    next_wrk
    rjmp GOES

;----------------------------------------------------------------------
; ok exec pull new ip from parameter stack
;
LEAF 4, "EXEC"
EXEC:
    pull_wrk
    rjmp GOES

;----------------------------------------------------------------------
; ok exit pull new ip from return stack
;
LEAF 4, "EXIT"
EXIT:
    rspull zl, zh
    rjmp ENTER 

;----------------------------------------------------------------------
; ok enter, push next ip into return stack
;
LEAF 5, "ENTER"
ENTER:
    next_wrk
    rspush zl, zh
GOES:
    sbiw wrk_low, 1 ; point to opcode.
    movw zl, wrk_low
    rjmp CORE

;---------------------------------------------------------------------
;
; read a opcode in [ip]
;
LEAF 4, "CORE"
CORE:

; next instruction

    lpm r0, Z+

; try  0, 1, 2, 3

; equal to 0 NOOP
    dec r0    
    brlt CORE    
; equal to 1  
    dec r0
    brlt CORE    
; equal to 2 
    dec r0
    brlt ENTER    
; equal to 3 
    dec r0
    breq EXIT    
; greather then 3
    rjmp _CORE  


;----------------------------------------------------------------------
; ?? ok +! to
LEAF 2, "+!"
PLUSTO:
    rspush xl, xh
    movw xl, tos_low
    ld wrk_high, X+
    ld wrk_low, X+
    add wrk_low, nds_low
    adc wrk_high, nds_high
    st -X, wrk_low
    st -X, wrk_high
    rspull xl, xh
    rjmp TWODROP

;----------------------------------------------------------------------
; ok ! to (works only in sram)
LEAF 1, "!"
TO:
    movw wrk_low, ip_low
	movw ip_low, tos_low
    st Z+, nds_high
    st Z+, nds_low
_TO1:
    movw ip_low, wrk_low
    rjmp TWODROP

;----------------------------------------------------------------------
; ok C!
LEAF 1, "C!"
CTO:
    movw wrk_low, ip_low
	movw ip_low, tos_low
    st Z+, nds_high
    rjmp _TO1

;----------------------------------------------------------------------
; ok @ at (works only in sram)
LEAF 1, "@"
AT:
    movw wrk_low, ip_low
	movw ip_low, tos_low
    ld tos_high, z+
    ld tos_low, z+
_AT1:
    movw ip_low, wrk_low
    rjmp CORE

;----------------------------------------------------------------------
; ok C@ cat
LEAF 1, "C@"
CAT:
    movw wrk_low, ip_low
	movw ip_low, tos_low
    ld tos_high, z+
    eor tos_high, tos_high
    rjmp _AT1


;----------------------------------------------------------------------
#include "stacks.inc"

;----------------------------------------------------------------------
;
;    ok 
LEAF 5, "1+"
ONEPLUS:
    movw wrk_low, tos_low
    adiw wrk_low, 1
    movw tos_low, wrk_low
    rjmp CORE

;----------------------------------------------------------------------
;
;    ok
LEAF 2, "1-"
ONEMINUS:
    movw wrk_low, tos_low
    sbiw wrk_low, 1
    movw tos_low, wrk_low
    rjmp CORE

;----------------------------------------------------------------------
#include "bits.inc"

;----------------------------------------------------------------------
;  ok 0>
LEAF 2, "0>"
ZEROGT:
    pull_wrk
    sbiw wrk_low, 1
    brge _ZEROGT1
    rjmp FTRUE
_ZEROGT1:
    rjmp FFALSE
;----------------------------------------------------------------------
;  ok 0<
LEAF 2, "0<"
ZEROLT:
	pull_wrk
    sbiw wrk_low, 1
    brge _ZEROLT1
    rjmp FFALSE
_ZEROLT1:
    rjmp FTRUE

;----------------------------------------------------------------------
; ok 0=
LEAF 2, "0="
ZEROEQ:
	pull_wrk
    sbiw wrk_low, 1
    breq _ZEROEQ1
    rjmp FFALSE
_ZEROEQ1:
    rjmp FTRUE

;----------------------------------------------------------------------
; ok XOR
LEAF 3, "XOR"
XOR:
    eor nds_low, tos_low
    eor nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok AND
LEAF 3, "AND"
AND:
    and nds_low, tos_low
    and nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok OR
LEAF 2, "OR"
OR:
    or nds_low, tos_low
    or nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok +
LEAF 1, "+"
PLUS:
    add nds_low, tos_low
    adc nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok -
LEAF 1, "-"
MINUS:
    sub nds_low, tos_low
    sbc nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; <
LEAF 1, "<"
LTHAN:
    sub nds_low, tos_low
    sbc nds_high, tos_high
    brlt _LTHAN1
    rjmp FTRUE
_LTHAN1:
    rjmp FFALSE

;----------------------------------------------------------------------
; >
LEAF 1, ">"
GTHAN:
    sub nds_low, tos_low
    sbc nds_high, tos_high
    brge _GTHAN1
    rjmp FFALSE
_GTHAN1:
    rjmp FTRUE

;----------------------------------------------------------------------
; >
LEAF 1, "="
EQUAL:
    sub nds_low, tos_low
    sbc nds_high, tos_high
    breq _EQUAL1
    rjmp FFALSE
_EQUAL1:
    rjmp FTRUE

;----------------------------------------------------------------------
; ok INV
LEAF 3, "INV"
INV:
    com tos_low
    com tos_high
    rjmp CORE

;----------------------------------------------------------------------
; ok NEG
LEAF 3, "NEG"
NEG:
    neg tos_low
    neg tos_high
    rjmp CORE

;----------------------------------------------------------------------
; ok 2*
LEAF 2, "2*"
SHL:
    lsl tos_low
    rol tos_high
    rjmp CORE

;----------------------------------------------------------------------
; ok 2/
LEAF 2, "2/"
SHR:
    asr tos_high
    ror tos_low
    rjmp CORE

;----------------------------------------------------------------------
; UM+
LEAF 3, "UM+"
UPLUS:
    ; do signed plus
    add nds_low, tos_low
    adc nds_high, tos_high
    ; preserve carry at tos
    eor tos_low, tos_low
    eor tos_high, tos_high
    rol tos_low
    rjmp CORE

;----------------------------------------------------------------------
;
; CMOVE copy from source++ to destination++, decrease w
LEAF 5, "CMOVE"
CMOVE:
    ; WARNING No bound check
    ; tos source
    ; nds destination
    ; w   1 or many, 0 does nothing

;    source exchange tos to psp (Y)

    movw wrk_low, tos_low
    movw tos_low, psp_low
    movw psp_low, wrk_low

;    destination exchange nds and rsp (X)

    movw wrk_low, nds_low
    movw nds_low, rsp_low
    movw rsp_low, wrk_low

    ; get the counter
    pspull wrk_low, wrk_high

    ; no offset

_CMOVE1:
    ; decrease counter

    sbiw wrk_low, 1
    brlt _CMOVE2

    ; move a byte
    ld _work_, Y+
    st X+, _work_

    ; again
    rjmp _CMOVE1

_CMOVE2:

    movw psp_low, tos_low
    movw rsp_low, nds_low

    rspull tos_low, tos_high
    rspull nds_low, nds_high

    rjmp  CORE

;----------------------------------------------------------------------
; CMOVE> copy from source+w to destination+w, decrease w
LEAF 5, "CMOVE>"
CMOVEGT:
    ; WARNING No bound check
    ; tos source
    ; nds destination
    ; w 1 or many, 0 does nothing

;    source exchange tos and psp (Y)

    movw wrk_low, tos_low
    movw tos_low, psp_low
    movw psp_low, wrk_low

;    destination exchange nds and rsp (X)

    movw wrk_low, nds_low
    movw nds_low, rsp_low
    movw rsp_low, wrk_low

    ; get the counter
    pspull wrk_low, wrk_high

    ; offset predecrements

    adiw wrk_low, 1

    add psp_low, wrk_low
    adc psp_high, wrk_high

    add rsp_low, wrk_low
    adc rsp_high, wrk_high

    sbiw wrk_low, 1

_CMOVEGT1:
    ; decrease counter
    sbiw wrk_low, 1
    brlt _CMOVEGT2

    ; move a byte
    ld _work_, -Y
    st -X, _work_

    ; again
    rjmp _CMOVEGT1

_CMOVEGT2:

    movw psp_low, tos_low
    movw rsp_low, nds_low

    rspull tos_low, tos_high
    rspull nds_low, nds_high

    rjmp  CORE

;----------------------------------------------------------------------
;
; ok ALIGN, easy as cell is 2 bytes
; if lsb set sum 1
;
LEAF 5, "ALIGN"
ALLIGN:
    movw wrk_low, tos_low
    adiw wrk_low, 1
    movw tos_low, wrk_low
    lsr tos_low
    lsl tos_low
    rjmp CORE

;----------------------------------------------------------------------
;
; ok CELL is 2 ; size of a cell
;
LEAF 2, "CELL"
CELLSZ:
    ldi wrk_low, CELL_SIZE
    eor wrk_high, wrk_high
    rjmp PUSHS

;----------------------------------------------------------------------
;
; ok CELL is 2, multiply by 2
;
LEAF 5, "CELLS"
CELLS:
    rjmp SHL

;----------------------------------------------------------------------
;
; ok add CELL_SIZE
;
LEAF 5, "CELL+"
CELLPLUS:
    movw wrk_low, tos_low
    adiw wrk_low, CELL_SIZE
    movw tos_low, wrk_low
    rjmp CORE

;----------------------------------------------------------------------
;
; ok sub CELL_SIZE
;
LEAF 5, "CELL-"
CELLMINUS:
    movw wrk_low, tos_low
    sbiw wrk_low, CELL_SIZE
    movw tos_low, wrk_low
    rjmp CORE

;----------------------------------------------------------------------
; ????
;
; http://www.avr-asm-tutorial.net/avr_en/apps/random_tn13/random_calc_tn13.html
;
;    good seeds
;
;    B167 4A3C 9879 B61E 7B26 
;    A858 1F88 50D5 419D 5537
;    0224 0527 5EB6 1E6D BCDC
;    92FF C206 0ECD 9361 2823
;    BE0B B303 6462 0E4C 3D24
;
LEAF 3, "_RND_"
RND:
;    load seed
    lds wrk_low, _RANDW
    lds wrk_high, _RANDW + 1
;
;    run magics
;
    eor    wrk_low, wrk_high
    swap wrk_low
    add wrk_high, wrk_low

;    save seed
    sts _RANDW, wrk_low
    sts _RANDW + 1, wrk_high
;
    rjmp PUSHS
    
;----------------------------------------------------------------------
;
; trampoline for 127 primitives
;
;----------------------------------------------------------------------
;
; order IS opcode sequence
;
;---------------------------------------------------------------------
JUMPS:

;---------------------------------------------------------------------
;
; do not change order, hard coded in macros
; opcode 0, 1, 2, 3, 4, 5, 6, 7
;
;---------------------------------------------------------------------
.balign 2

;---------------------------------------------------------------------
; those are checked first and directly
;
;    rjmp NOOP ; 
;    rjmp CORE ; 
;    rjmp ENTER ; 
;    rjmp EXIT ; 

;---------------------------------------------------------------------
; those are reserved
;
    rjmp RESET ; reserved
    rjmp CORE ; reserved
    rjmp CORE ; reserved
    rjmp CORE ; reserved

;---------------------------------------------------------------------
;
; could NOT change order after done dictionary.
;
;---------------------------------------------------------------------
.balign 2

    rjmp ABORT 
    rjmp ALLIGN 
    rjmp AND 
    rjmp AT 
    rjmp BITSCLEAR 
    rjmp BITSSET 
    rjmp BITSTOGGLE 
    rjmp BRANCH 
    rjmp BYE 
    rjmp CAT 
    rjmp CELLMINUS 
    rjmp CELLPLUS 
    rjmp CELLS 
    rjmp CELLSZ 
    rjmp CMOVE 
    rjmp CMOVEGT 
    rjmp CTO 
    rjmp DOLIT 
;    rjmp DOVAR 
;	 rjmp DOCON
    rjmp DROP 
    rjmp DSHL 
    rjmp DSHR 
    rjmp DUP 
    rjmp EMITQM 
    rjmp EQUAL 
    rjmp EXEC 
    rjmp GTHAN 
    rjmp GTR 
    rjmp INV 
    rjmp IOYO 
    rjmp KEYQM 
    rjmp LTHAN 
    rjmp MINUS 
    rjmp NEG 
    rjmp NOOP 
    rjmp ONEMINUS 
    rjmp ONENEG 
    rjmp ONEPLUS 
    rjmp OR 
    rjmp OVER 
    rjmp PLUS 
    rjmp PLUSTO 
    rjmp PSAT 
    rjmp PSTO 
    rjmp PUSHS 
    rjmp QMBRANCH 
    rjmp QMDUP 
    rjmp QUIT 
    rjmp RAT 
    rjmp RGT 
    rjmp ROT 
    rjmp RSAT 
    rjmp RSTO 
    rjmp SDIV 
    rjmp SHL 
    rjmp SHR 
    rjmp SMUL 
    rjmp SWAP 
    rjmp TO 
    rjmp TWODROP 
    rjmp TWODUP 
    rjmp TWOSWAP
    rjmp UMBYMOD 
    rjmp UMUL 
    rjmp UPLUS 
    rjmp XOR 
    rjmp ZERO 
    rjmp ZEROEQ 
    rjmp ZEROGT 
    rjmp ZEROLT 

;---------------------------------------------------------------------
;
; check in CORE have 3 dec
;
_CORE:
    
; offset by multiply by 2

    lsl r0
    rol r1

; load table address

    ldi wrk_low, lo8(JUMPS)
    ldi wrk_high, hi8(JUMPS)

; take offset

    add wrk_low, r0
    adc wrk_high, r1

; pseudo
; why not:  movw r30, r24; ijmp;

    push wrk_low
    push wrk_high
    ret

;---------------------------------------------------------------------
;
; end trampoline
;
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; ????
LEAF 3, "D2/"
DSHR:
    lsr nds_low
    ror nds_high
    ror tos_low
    ror tos_high
    rjmp CORE

;----------------------------------------------------------------------
; ????
LEAF 3, "D2*"
DSHL:
    lsl nds_low
    rol nds_high
    rol tos_low
    rol tos_high
    rjmp CORE

;----------------------------------------------------------------------
;
;    "div16u" - 16/16 Bit Unsigned Division
;
; ok UM/MOD
LEAF 6, "UM/MOD"
UMBYMOD:
;
;***** Subroutine Register Variables

#define drem16uL r14
#define drem16uH r15
#define dres16uL r16
#define dres16uH r17

#define dd16uL r16
#define dd16uH r17
#define dv16uL r18
#define dv16uH r19

#define dcnt16u r20

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code

div16u: clr wrk_low ;clear remainder Low byte
    sub wrk_high,wrk_high;clear remainder High byte and carry
    ldi r16,17 ;init loop counter
d16u_1: rol nds_low ;shift left dividend
    rol nds_high
    dec r16 ;decrement counter
    brne d16u_2 ;if done
d16ures:
;
;    move operands
;
    movw nds_low, r16
    movw tos_low, r14
    rjmp CORE

d16u_2: rol wrk_low ;shift dividend into remainder
    rol wrk_high
    sub wrk_low,tos_low ;remainder = remainder - divisor
    sbc wrk_high,tos_high ;
    brcc d16u_3 ;if result negative
    add wrk_low,tos_low ; restore remainder
    adc wrk_high,tos_high
    clc ; clear carry to be shifted into result
    rjmp d16u_1 ;else
d16u_3: sec ; set carry to be shifted into result
    rjmp d16u_1


;----------------------------------------------------------------------
;
;    "div16s" - 16/16 Bit Signed Division
;
; ok /
LEAF 1, "/"
SDIV:
;
;***** Subroutine Register Variables
;

#define drem16sL r14
#define drem16sH r15
#define dres16sL r16
#define dres16sH r17

#define dd16sL r16
#define dd16sH r17
#define dv16sL r18
#define dv16sH r19


#define dcnt16s r20

#define    d16s    r21

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code
;
div16s: mov    d16s,dd16sH    ;move dividend High to sign register
    eor    d16s,dv16sH    ;xor divisor High with sign register
    sbrs    dd16sH,7    ;if MSB in dividend set
    rjmp    d16s_1
    com    dd16sH    ;    change sign of dividend
    com    dd16sL
    subi    dd16sL,lo8(-1)
    sbci    dd16sL,hi8(-1)
d16s_1: sbrs    dv16sH,7    ;if MSB in divisor set
    rjmp    d16s_2
    com    dv16sH    ;    change sign of divisor
    com    dv16sL
    subi    dv16sL,lo8(-1)
    sbci    dv16sL,hi8(-1)
d16s_2: clr    drem16sL    ;clear remainder Low byte
    sub    drem16sH,drem16sH;clear remainder High byte and carry
    ldi    dcnt16s,17     ;init loop counter

d16s_3: rol    dd16sL    ;shift left dividend
    rol    dd16sH
    dec    dcnt16s    ;decrement counter
    brne    d16s_5    ;if done
    sbrs    d16s,7    ;    if MSB in sign register set
    rjmp    d16s_4
    com    dres16sH    ;    change sign of result
    com    dres16sL
    subi    dres16sL,lo8(-1)
    sbci    dres16sH,hi8(-1)
d16s_4:      ;    return
d16sres:
    movw nds_low, r16
    movw tos_low, r14
    rjmp CORE

d16s_5: rol    drem16sL    ;shift dividend into remainder
    rol    drem16sH
    sub    drem16sL,dv16sL ;remainder = remainder - divisor
    sbc    drem16sH,dv16sH ;
    brcc    d16s_6    ;if result negative
    add    drem16sL,dv16sL ;    restore remainder
    adc    drem16sH,dv16sH
    clc     ;    clear carry to be shifted into result
    rjmp    d16s_3    ;else
d16s_6: sec     ;    set carry to be shifted into result
    rjmp    d16s_3

;----------------------------------------------------------------------
;
;* "mpy16s" - 16x16 Bit Signed Multiplication
; ok *
LEAF 1, "*"
SMUL:
;***** Subroutine Register Variables

#define mc16sL r16
#define mc16sH r17     
#define mp16sL r18     
#define mp16sH r19     

#define m16s0 r18    
#define m16s1 r19    
#define m16s2 r20     
#define m16s3 r21    

#define mcnt16s r22     

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code
mpy16s: clr    m16s3     ;clear result byte 3
    sub    m16s2,m16s2    ;clear result byte 2 and carry
    ldi    mcnt16s,16     ;init loop counter
m16s_1: brcc    m16s_2    ;if carry (previous bit) set
    add    m16s2,mc16sL    ;    add multiplicand Low to result byte 2
    adc    m16s3,mc16sH    ;    add multiplicand High to result byte 3
m16s_2: sbrc    mp16sL,0    ;if current bit set
    sub    m16s2,mc16sL    ;    sub multiplicand Low from result byte 2
    sbrc    mp16sL,0    ;if current bit set
    sbc    m16s3,mc16sH    ;    sub multiplicand High from result byte 3
    asr    m16s3     ;shift right result and multiplier
    ror    m16s2
    ror    m16s1
    ror    m16s0
    dec    mcnt16s    ;decrement counter
    brne    m16s_1    ;if not done, loop more
m16sres:
    mov nds_low, r16
    rjmp CORE

;----------------------------------------------------------------------
;
; "mpy16u" - 16x16 Bit Unsigned Multiplication
;
; ok UM*
LEAF 3, "UM*"
UMUL:
;
;***** Subroutine Register Variables

#define mc16uL r16
#define mc16uH r17
#define mp16uL r18
#define mp16uH r19

#define m16u0 r18     
#define m16u1 r19     
#define m16u2 r20     
#define m16u3 r21     

#define mcnt16u r22     

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code
;
mpy16u: clr wrk_high ;clear 2 highest bytes of result
    clr wrk_low
    ldi r16,16 ;init loop counter
    lsr tos_high
    ror tos_low

m16u_1: brcc noad8 ;if bit 0 of multiplier set
    add wrk_low,nds_low ;add multiplicand Low to byte 2 of res
    adc wrk_high,nds_high ;add multiplicand high to byte 3 of res
noad8: ror wrk_high ;shift right result byte 3
    ror wrk_low ;rotate right result byte 2
    ror r19 ;rotate result byte 1 and multiplier High
    ror r18 ;rotate result byte 0 and multiplier Low
    dec r16 ;decrement loop counter
    brne m16u_1 ;if not done, loop more
m16ures:
;
;    move operands
;
    movw nds_low, r18
    rjmp CORE

;----------------------------------------------------------------------

;----------------------------------------------------------------------
;*************************************************************************
;*     *
;*      Convert unsigned 16 bit to 5 digit ASCII    *
;*     *
;*    Author: Peter Dannegger     *
;*     *
;*************************************************************************
; https://www.avrfreaks.net/forum/smallest-and-fastest-binary-bcd-conversion?page=all
;
;
;input: R17, R16 = 16 bit value 0 ... 65535
;output: R20, R19, R18, R17, R16 = 5 digits (ASCII)
;cycle: 20 ... 170
;

bin16_ascii:

    ldi    r20, -1 + '0'
_bcd1:  inc    r20
    subi    r16, lo8(10000)    
    sbci    r17, hi8(10000)
    brcc    _bcd1

    ldi    r19, 10 + '0'
_bcd2:  dec    r19
    subi    r16, lo8(-1000)  
    sbci    r17, hi8(-1000)
    brcs    _bcd2

    ldi    r18, -1 + '0'
_bcd3:  inc    r18
    subi    r16, lo8(100)   
    sbci    r17, hi8(100)
    brcc    _bcd3

    ldi    r17, 10 + '0'
_bcd4:  dec    r17
    subi    r16, -10     
    brcs    _bcd4

    subi    r16, -'0'
    ret

;----------------------------------------------------------------------
#include "constants.inc" 

;----------------------------------------------------------------------
#include "variables.inc" 

;----------------------------------------------------------------------
#include "twigs.inc" 

;----------------------------------------------------------------------

