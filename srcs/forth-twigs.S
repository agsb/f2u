
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
;
; is ZZZZ, hook for incompleteness 
;
HEADER "ZZZZ", "ZZZZ",
    .word LIT, undefined, LIT, 12, TYPE, CR, ENDS 
 
;********************************************************************** 
;
;   stack words
;
;----------------------------------------------------------------------
;
; ok ( w2 w1 -- w1 ) 
;
HEADER "NIP", "NIP",
    .word SWAP, DROP, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w3 w2 w1 -- w2 w3 w1 ) 
;
HEADER "SWIP", "SWIP",
    .word TOR, SWAP, RTO, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w2 w1 -- w2 w1 w2 ) 
;
;HEADER "OVER", "OVER",
;    .word TOR, DUP, RTO, SWAP, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w3 w2 w1 -- w2 w1 w3 ) 
;
HEADER "ROT", "ROTU",
    .word SWIP, SWAP, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w3 w2 w1 -- w1 w3 w2 ) 
;
HEADER "-ROT", "ROTD",
    .word SWAP, SWIP, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w2 w1 --  w1 w2 w1 ) 
;
HEADER "TUCK", "TUCK",
    .word SWAP, OVER, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w3 w2 w1 --  w1 w2 w3 ) 
;
HEADER "FLIP", "FLIP",
    .word SWAP, SWIP, SWAP, ENDS 

;----------------------------------------------------------------------
;
; ok ( w1 w2 -- 0 | -1) 
;
HEADER "=", "EQUAL",
    .word MINUS, ZEQU, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- 0 | -1) 
;
HEADER "<>", "NOTEQUAL",
    .word EQUAL, INVERT, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- 0 | -1 ) 
; w1 > w2
HEADER ">", "GTHAN",
    .word SWAP, LTHAN, ENDS 
 
;----------------------------------------------------------------------
;  ok 0>  must be signed 
;
HEADER "0>", "ZEROGT",
     .word ZERO, LTHAN, ENDS 
 
;----------------------------------------------------------------------
;  ok 0< must be signed 
;
HEADER "0<", "ZEROLT",
    .word ZERO, SWAP, LTHAN, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w * CELL  ) 
; CELL is 2, multiply by 2, easy way 
;
HEADER "CELLS", "CELLS",
    .word SHL, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w + CELL ) 
;
HEADER "CELL+", "CELLPLUS",
    .word CELL, PLUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w - CELL ) 
;
HEADER "CELL-", "CELLMINUS",
    .word CELL, MINUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w + 1 ) 
;
HEADER "1+", "ONEPLUS",
     .word ONE, PLUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w - 1 ) 
;
HEADER "1-", "ONEMINUS",
     .word ONE, MINUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w + 2 ) 
;
HEADER "2+", "TWOPLUS",
     .word TWO, PLUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w - 2 ) 
;
HEADER "2-", "TWOMINUS",
     .word TWO, MINUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( u w -- ) 
;
HEADER "+!", "PLUSTO",
    .word DUP, TOR, AT, PLUS, RTO, TO, ENDS 
 
;********************************************************************** 
;
;    load variables 
;
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "TIB", "TIB",
    .word LIT, TIB0, ENDS
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "LATEST", "LATEST",
    .word LIT, LAST, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "STATE", "STATE",
    .word LIT, STAT, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "BASE", "BASE",
    .word LIT, BASE, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "EP", "EPP",
    .word LIT, VEP, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "DP", "DP",
    .word LIT, VDP, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "UP", "UP",
    .word LIT, VUH, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
; stack for variables from end of stacks
HEADER "UD", "UD",
    .word LIT, VUS, ENDS
 
;********************************************************************** 
; 
;   basic words
;
;----------------------------------------------------------------------
;   strange changes ?
;   all compilation is done in sram, then need a trick
;
;   up is a pointer to next free cell in sram, from the end of TIB
;   dp is a pointer to next free cell in flash
;   fp is a pointer to last dp, used when write sram to flash 
;   up0 is the end of TIB
;
;   here return where dp is, used for absolute branch and zbranch,
;   uhere returns where up is, 
;   comma writes in sram, and 
;   allot updates up and dp pointers
;   when done to write sram to flash, fp = up, up = up0
;
;----------------------------------------------------------------------
;
; ok HERE ( -- w ) 
;
HEADER "UHERE", "UHERE",
    .word UP, AT, ENDS 
 
;----------------------------------------------------------------------
;
; ok HERE ( -- w ) 
;
HEADER "HERE", "HERE",
    .word DP, AT, ENDS 
 
;----------------------------------------------------------------------
;
; ok ALLOT ( u -- ) 
; not standart: updates DP and UP
;
HEADER "ALLOT", "ALLOT",
    .word DUP
    .word UP, AT, PLUS, UP, TO 
    .word DP, AT, PLUS, DP, TO 
    .word ENDS 
 
;----------------------------------------------------------------------
;
; is ALIGN 
; not standart: updates DP and UP
;
HEADER "ALIGN", "ALIGN",
    .word UP, AT, ALIGNED, UP, TO
    .word DP, AT, ALIGNED, DP, TO
    .word ENDS 
 
;----------------------------------------------------------------------
;
; ok COMMMA ( w -- ) 
; not standart: updates DP and UP
;
HEADER ",", "COMMA", F_IMMEDIATE
    .word UHERE, TO, CELL, ALLOT, ENDS 
 
;----------------------------------------------------------------------
;
; ok TOMMA ( a2 a1 -- ) 
; not standart: do not update DP or UP, 
;   just do TO (a2 a1-a2+UP -- )
;
HEADER "<,", "TOMMA", F_IMMEDIATE
    .word OVER, MINUS, UHERE, PLUS, TO, ENDS 
 
;----------------------------------------------------------------------
;
; is DOVAR ( -- a )
;
HEADER "DOVAR", "DOVAR",
    .word LIT, ENDS 
 
;----------------------------------------------------------------------
;
; is DOCON ( -- w ) 
;       
HEADER "DOCON", "DOCON",
    .word LIT, AT, ENDS 
 
;----------------------------------------------------------------------
;
; is DOTO ( w -- ) 
;
HEADER "DOTO", "DOTO",
    .word LIT, TO, ENDS 
 
;----------------------------------------------------------------------
;
; ok this puts next cell into stack and compiles into HERE 
; used only in precompiled sources as forth-twigs
; ????
HEADER "COMP", "COMP", F_IMMEDIATE
    .word LIT, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok compile a eow 
;
HEADER "EXIT", "EXIT", F_IMMEDIATE
    .word COMP, ENDS, ENDS

;----------------------------------------------------------------------
;
; ok execute xt from tos
;
HEADER "EXEC", "EXEC", F_IMMEDIATE
    .word TOR, ENDS

;----------------------------------------------------------------------
;
; ok make a word recursive 
;
HEADER "TAIL", "TAIL", 
    .word RAT, CELL, MINUS, RTO, ENDS

;----------------------------------------------------------------------
;
; Control words review. there is no more offset BRANCH.
;
;----------------------------------------------------------------------
 
;----------------------------------------------------------------------
;
; ok MARKTO 
; places a address of cell
; places to address to self in a holder, 
; and left address of holder at stack
;
HEADER "MARKTO", "MARKTO", F_IMMEDIATE,
    .word HERE, DUP, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok TOMARK 
; places a address of cell 
; resolves a back reference to last holder 
; and places a address to self at holder 
HEADER "TOMARK", "TOMARK", F_IMMEDIATE,
    .word HERE, SWAP, TOMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok BEGIN 
;
HEADER "BEGIN", "BEGIN", F_IMMEDIATE,
    .word HERE, ENDS 
 
;----------------------------------------------------------------------
;
; ok AGAIN resolves a unconditional branch 
;
HEADER "AGAIN", "AGAIN", F_IMMEDIATE,
    .word COMP, BRANCH, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok UNTIL resolves a conditional branch, as C do { ... } while (0) 
;
HEADER "UNTIL", "UNTIL", F_IMMEDIATE,
    .word COMP, ZBRANCH, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok UNLESS 
;
HEADER "UNLESS", "UNLESS", F_IMMEDIATE, 
    .word ZEQU, UNTIL, ENDS 
 
;----------------------------------------------------------------------
;
; ok IF (executed if tos is not zero)
;
HEADER "IF", "IF", F_IMMEDIATE,
    .word COMP, ZBRANCH, MARKTO, ENDS 
 
;----------------------------------------------------------------------
;
; ok GO (executed ever)
;
HEADER "GO", "GO", F_IMMEDIATE,
    .word COMP, BRANCH, MARKTO, ENDS 
 
;----------------------------------------------------------------------
;
; ok THEN 
;
HEADER "THEN", "THEN", F_IMMEDIATE,
    .word ENDIF, ENDS 
 
;----------------------------------------------------------------------
;
; ok ENDIF resolves a forward branch 
;
HEADER "ENDIF", "ENDIF", F_IMMEDIATE,
    .word TOMARK, ENDS 
 
;----------------------------------------------------------------------
;
; ok ELSE (executed if tos is zero)
;
HEADER "ELSE", "ELSE", F_IMMEDIATE,
    .word GO, SWAP, TOMARK, ENDS 
 
;----------------------------------------------------------------------
;
; ok WHILE 
;
HEADER "WHILE", "WHILE", F_IMMEDIATE,
    .word IF, SWAP, ENDS 
 
;----------------------------------------------------------------------
;
; ok REPEAT 
;
HEADER "REPEAT", "REPEAT", F_IMMEDIATE,
    .word AGAIN, TOMARK, ENDS 
 
 
;----------------------------------------------------------------------
; @eforth
; is AHEAD (a forward goto)
;
HEADER "AHEAD", "AHEAD", F_IMMEDIATE,
    .word GO, ENDS 
 
;----------------------------------------------------------------------
; @eforth
; is AFT 
;
HEADER "AFT", "AFT", F_IMMEDIATE,
    .word DROP, GO, HERE, SWAP, ENDS 
 
;----------------------------------------------------------------------
;
; is HOOK 
;
HEADER "HOOK", "HOOK", F_IMMEDIATE,
    .word BEGIN, TOR, ENDS 
 
;----------------------------------------------------------------------
;
; is BACK 
;
HEADER "BACK", "BACK", F_IMMEDIATE,
    .word RTO, AGAIN, ENDS 
 
;----------------------------------------------------------------------
;
; is FOR ( u -- ) R:( -- h u )
; count down, from +32767
HEADER "FOR", "FOR", F_IMMEDIATE
    .word COMP, TOR, BEGIN, ENDS 
 
;----------------------------------------------------------------------
;
; is TXEN ( -- ) R:( -- h u ) 
;
HEADER "TXEN", "TXEN", 
    .word RTO, ONEMINUS
    .word DUP, ZBRANCH, 1f  
    .word DUP, TOR 
1:
    .word ENDS

;----------------------------------------------------------------------
;
; is NEXT ( -- ) R:( -- h u ) 
;
HEADER "NEXT", "NEXT", F_IMMEDIATE
    .word COMP, TXEN, UNLESS, ENDS

;----------------------------------------------------------------------
;
; is  ( a u -- )
;
HEADER "CR", "CR",
    .word LIT, 0x0D, EMIT, ENDS

;----------------------------------------------------------------------
;
; is  ( a u -- )
;
HEADER "LF", "LF",
    .word LIT, 0x0A, EMIT, ENDS

;----------------------------------------------------------------------
;
; is  ( a u -- )
;
HEADER "BL", "BL",
    .word LIT, 0x20, EMIT, ENDS

;----------------------------------------------------------------------
;
; is  ( a u -- )
;   
HEADER "DOT", "DOT",
    .word ZZZZ, EMIT, ENDS

;----------------------------------------------------------------------
;
; is  ( a u -- )
;
HEADER "TYPE", "TYPE",
1:
    .word DUP, ZBRANCH, 2f
    .word ONEMINUS, TOR, DUP, AT, EMIT, ONEPLUS, RTO
    .word BRANCH, 1b
2:
    .word DROP, DROP, ENDS 
  
;----------------------------------------------------------------------
;
HEADER "COLD", "COLD", F_LEAP
    NOOP 
    .word LIT, PS0, PSTO
    .word LIT, RS0, RSTO
    .word LIT, US0, UD, TO
    .word LIT, 0x00, STATE, TO
    .word LIT, 0x10, BASE, TO
    .word LIT, WARM, RTO
    .word ENDS 
 
;----------------------------------------------------------------------
;
HEADER "WARM", "WARM", F_LEAP
    NOOP 
    ; verify error code 
    ; resets etc 
    .word TURN, AT, EXEC, QUIT, ENDS 
 
;----------------------------------------------------------------------
; does reset 
;
HEADER "BYE", "BYE", F_LEAP
    .word REST, AT, EXEC, RESET, ENDS 

