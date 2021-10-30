
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

;----------------------------------------------------------------------
;
;   MUST use gnu cpp 
;   use with .S (upper S) or
;    use with -x assembler-with-cpp
;
;     can't use alias 
;----------------------------------------------------------------------
;
; all defines, equs, macros are defined in this file
;
;----------------------------------------------------------------------
;
;    about registers 
;
; r1:r0 reserved and used in self atmega8 instructions, as spm, mul, des etc
;

; generic scratch 
#define _work_ r2

; always zero, keep by interrupt
#define _zero_ r3

; sreg keep in interrupts
#define _sreg_ r4

; offset for adjust timer0 interrupt counter
#define _offs_ r5

; ticks counter for timer0 at 1 ms
#define ticks_low r6
#define ticks_high r7

; Z generic pointer for access sram and flash memory
#define zpm_low r30
#define zpm_high r31

; Y return stack pointer for access sram
#define rsp_low r28
#define rsp_high r29

; X parameter stack pointer for access sram
#define psp_low r26
#define psp_high r27

; work register
#define wrk_low r24
#define wrk_high r25

; fist temporary
#define tos_low r22
#define tos_high r23

; second temporary 
#define nds_low r20
#define nds_high r21

; instruction pointer register for branch and link return
#define ipr_low r18
#define ipr_high r19

;----------------------------------------------------------------------
;
;  trick adapted from amforth-6.9
;
.macro STRINGS string
;    .word DOSLIT
    .byte 8f - 7f
7:  .ascii "\\string"
8:  .balign 2
.endm

;----------------------------------------------------------------------
;
; header of leaf word in dictionary
;    flags must be 0x80, 0x40, 0x20, 0x10
;    size  must be 1 to 15
;
;----------------------------------------------------------------------
;
; set start reverse linked list
;
.set _link_, 0x0

.macro HEADER name, label, flags=0x0
is_\label:
    .p2align 1, 0x00
7:    
    .word _link_
    .set _link_, 7b
    .byte (9f - 8f) + \flags
8:    
    .ascii "\name"
9:    
    .p2align 1, 0x20
\label:
.endm

;----------------------------------------------------------------------
; little endian !!! AVR
;
;    A    Z (r31:r30) is used as generic address pointer
;    R    Y (r29:r28) is used as return stack pointer    
;    S    X (r27:r26) is used as data/parameter stack pointer
;    W    W (r25:r24) is used as generic work register
;    
;
;   all stacks grows downwards.
;
;----------------------------------------------------------------------
;    push into return stack, 
.macro rspush low, high 
    st -Y, \low
    st -Y, \high
.endm

;----------------------------------------------------------------------
;    pull from return stack, 
.macro rspull low, high
    ld \high, Y+
    ld \low, Y+
.endm

;----------------------------------------------------------------------
;    push into data stack, 
.macro pspush low, high
    st -X, \low
    st -X, \high
.endm

;----------------------------------------------------------------------
;    pull from data stack, 
.macro pspull low, high
    ld \high, X+
    ld \low, X+
.endm

;----------------------------------------------------------------------
;    load from program memory (flash)
;    only works with TWO lpm !!!
;    Z address in bytes!
.macro pmload low, high
    lsl zpm_low
    rol zpm_high
    lpm \low, Z+
    lpm \high, Z+
    ror zpm_high
    ror zpm_low
.endm

;----------------------------------------------------------------------
;    load from static memory (sram), increments pointer
;
.macro srload byte
    ld \byte, Z+
.endm

;----------------------------------------------------------------------
;    save to static memory (sram), increments pointer
;
.macro srsave byte
    st Z+, \byte 
.endm

;----------------------------------------------------------------------
; also io@
;
.macro peek address, register
    .if (\address < $40)
    in \register, \address
    .else
    lds \register, \address
    .endif
.endm

;----------------------------------------------------------------------
; also io!
;
.macro poke address, register
    .if (\address < $40)
    out \address, \register
    .else
    sts \address, \register
    .endif
.endm

;----------------------------------------------------------------------
; test, skip next if not zero
;
; for Atmega8:
; __SREG__ is 0x3F
; BIT_ZERO is 1
;
.macro test_zero low, high
    mov _work_, \low
    or _work_, \high
    sbrs _work_, BIT_ZERO
.endm

;----------------------------------------------------------------------
; all primitives must start with NOOP and end with POON
;    a  nop (0x0000) is used as a null reference, and marks all primitives
;    as they are really a branch and link mark
;
; many primitives saves work register at end, 
;    then for save bytes, ends with WOOP, 
;    that goes to _pushw, that goes to POON 
;

.macro NOOP
    nop
.endm

.macro WOOP
    rjmp _pushw
.endm

.macro POON
    rjmp _link
.endm

;**********************************************************************
;  constant values
;
;     %s/#define *\([^ ]*\) */ \1 = /
;    %s/ *\([^ ]*\) *= */#define \1 /

;----------------------------------------------------------------------
;    sizes
;
; atmega8 have flash memory of 128 pages of 64 bytes
SPM_SIZE = 64

; buffer for flush flash
FIB_SIZE = SPM_SIZE

; "Column 72 means Continue", 72 always \0
; Readability is good
TIB_SIZE = 72

; small collate for numbers and words
; no more than 16 chars in a 16bit number system
PIC_SIZE = 16

; stacks 18 words deep. WISE as M00re said.
STACK_SIZE = 36

; default cell size
CELL_SIZE = 2

; default base
BASE_DEFAULT = 16

;----------------------------------------------------------------------
;   reserved eeprom used (256 words total, 248 avaliabe) 
;
eeprom = 0x00
e_void = eeprom + 0  ; always zero
e_seed = eeprom + 2  ; seed for random
e_turn = eeprom + 4  ; routine after boot
e_rest = eeprom + 6  ; routine before reset
e_last = eeprom + 8  ; last link addres to dictionary 
e_here = eeprom + 10 ; next free flash address for dictionary
e_sram = eeprom + 12 ; next free sram address for variables, as stack
e_erom = eeprom + 14 ; next free eprom address for values, as stack
e_free = eeprom + 16 

;----------------------------------------------------------------------
;   words can be 1 to 15 chars lenght, 
;   almost over for normal english ~10 letters words http://norvig.com/mayzner.html
;
;   flags 
;   IMMEDIATE, COMPILE, HIDEN, TOGGLE
;
F_IMMEDIATE = 0x80
F_COMPILE_ONLY = 0x40
F_HIDDEN = 0x20
F_TOGGLE = 0x10
F_COMMON = 0x00

F_TOMASK = 0xF0
F_UNMASK = 0x0F

; STATES BIT!
; execute  STATE == 0
; compile  STATE == 1
; postpone STATE == 2 or 3, only for next word

BIT_POSTPONE = 1
BIT_COMPILE = 0
BIT_EXECUTE = 0

/*
state       common    immediate
S_EXECUTE    execute   execute
S_COMPILE    compile   execute
S_POSTPONE   compile   compile

*/
;---------------------------------------------------------------------
; status register from error codes forth 2012
; minimal
NO_ERROR = 0
INVALID_MEMORY = -9
OVERFLOW = -11
WRITE_TO_READ_ONLY = -20
NOT_A_NUMBER = -24

;---------------------------------------------------------------------
; Flow Control
; assumes that all line edit is done at remote!
; no backspace, no delete, no moving cursor, just a static line.
; works as a screen or block, just receives a line till a CR or CR LF
; uses BS, ESC, CAN, XON, XOFF, for control 
;
XON_   =   0x11    ; ascii DC1 ^Q
XOFF_  =   0x13    ; ascii DC3 ^S

CR_    =   0x0d    ; ascci carriage return ^M
LF_    =   0x0a    ; ascii line feed ^J

CAN_   =   0x18    ; ascii cancel ^C
ESC_   =   0x1B    ; ascii escape ^[

BS_    =   0x08    ; ascii backspace ^H
TAB_   =   0x09    ; horizontal tab
BL_    =   0x20    ; ascii space 

BIT_ZERO = 1
BIT_CARRY = 0

SRAM_START = 0x060  ; SRAM from AVR manual
SRAM_END = 0x45F  ; SRAM from AVR manual

FLASH_RWW = 0x0000
FLASH_NRWW = 0x1E00    ; using optiboot in 512 bytes !!!!
FLASH_END = 0x1FFF 

FLASH_START = SRAM_END + 1    ; just a offset
FLASH_STOP = FLASH_NRWW - 1

/* for eeprom use */

E2P_PAGESIZE = 4
E2P_START = 0x000
E2P_END = 0x1FF

/* for flash flush */

SPM_PAGE = 64    

pagesize = (SPM_PAGE - 1)
pagemask = (~pagesize)

;----------------------------------------------------------------------
