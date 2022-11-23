
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
;********************************************************************** 

;----------------------------------------------------------------------
;
; ok ( w a -- ) 
; just write a word
HEADER "!E", "TOEE", F_LEAP
    .word OVER, OVER, CTOE, ONE, PLUS, TOR, ENDIAN, RTO, CTOE, ENDS   

;----------------------------------------------------------------------
;
; ok ( w -- u ) 
;   w1 = b1b2 w2=b3b4 ~ u = b1b3 ????
;   w1 0x00ff and, w2 0x00ff and, 
;   w1 = b100, w2 = b300, w2 endian, w2 = 00b3
;   w1 w2 or
;
HEADER "@E", "ATEE", F_LEAP
    .word DUP, CATE, SWAP, CATE
    .word LIT, 0x00FF, AND
    .word ENDIAN, SWAP
    .word LIT, 0x00FF, AND
    .word OR, ENDS

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
; moved to primitives
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
HEADER "DP", "DPP",
    .word LIT, VDP, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "HP", "HPP",
    .word LIT, VHP, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
; stack for variables from end of stacks
;
HEADER "UP", "UPP",
    .word LIT, VUP, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
;HEADER "RS$", "RSIS",
;    .word LIT, RS0, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
;HEADER "PS$", "PSIS",
;    .word LIT, PS0, ENDS
 

;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "DEPTH", "DEPTH",
    .word PSAT, LIT, PS0, MINUS, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "RDEPTH", "RDEPTH",
    .word RSAT, LIT, RS0, MINUS, ENDS
 

;********************************************************************** 
; 
;   basic words
;
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
;   hp is a pointer to next free cell in sram, syncronous with dp 
;
;   here return where dp is, used for absolute branch and zbranch,
;   uhere returns where hp is, used for place in sram,
;   comma writes in sram, and allot updates up and dp pointers
;   when done to write sram to flash
;
;----------------------------------------------------------------------
;
; ok HERE ( -- w ) 
;
HEADER "UHERE", "UHERE",
    .word HPP, AT, ENDS 
 
;----------------------------------------------------------------------
;
; ok HERE ( -- w ) 
;
HEADER "HERE", "HERE",
    .word DPP, AT, ENDS 
 
;----------------------------------------------------------------------
;
; ok ALLOT ( u -- ) 
; not standart: updates DP and UP
 
HEADER "ALLOT", "ALLOT",
    .word DUP
    .word HPP, AT, PLUS, HPP, TO 
    .word DPP, AT, PLUS, DPP, TO 
    .word ENDS 
 
;----------------------------------------------------------------------
;
; is ALIGN 
; not standart: updates DP and UP
;
HEADER "ALIGN", "ALIGN",
    .word HPP, AT, ALIGNED, HPP, TO
    .word DPP, AT, ALIGNED, DPP, TO
    .word ENDS 
 
;----------------------------------------------------------------------
;
; ok CCOMMA ( w -- ) 
;
HEADER "C,", "CCOMMA", F_IMMEDIATE
    .word UHERE, CTO, ONE, ALLOT, ENDS 
 
;----------------------------------------------------------------------
;
; ok COMMMA ( w -- ) 
;
HEADER ",", "COMMA", F_IMMEDIATE
    .word UHERE, TO, CELL, ALLOT, ENDS 
 
;----------------------------------------------------------------------
;
; ok TOMMA ( a2 a1 -- ) 
; not standart, no updates DP or UP, 
;   just do TO (a2 a1-a2+UP -- )
;
HEADER "<,", "TOMMA", F_IMMEDIATE
    .word OVER, MINUS, UHERE, PLUS, TO, ENDS 
 
;-------------------------------------'---------------------------------
;
; is DOVAR ( -- a ), place the address of next cell into stack, 
;   R> DUP 2+ >R
;
HEADER "DOVAR", "DOVAR",
    .word RTO, DUP, TWOPLUS, TOR, ENDS 
 
;-------------------------------------'---------------------------------
;
; is DOCON ( -- a ), place the contents of next cell into stack, 
;   R> DUP 2+ >R @
;
HEADER "DOCON", "DOCON",
    .word DOVAR, AT, ENDS 

;----------------------------------------------------------------------
;
; is LITERAL ( w -- ) 
;
HEADER "LITERAL", "LITERAL",
    .word LIT, LIT, COMMA, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok this puts next cell into stack and compiles into HERE 
; used only in precompiled sources as forth-twigs
; zzzz
HEADER "COMP", "COMP", F_IMMEDIATE
    .word RTO, DUP, CELLPLUS, TOR, AT, COMMA, ENDS 
 
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
; recursive return to last 
;
HEADER "TAIL", "TAIL", 
    .word RAT, CELL, MINUS, RTO, ENDS

;----------------------------------------------------------------------
;
; ok make a value ( w -- )
; header|lit|value|ends
; zzzz
HEADER "VALUE", "VALUE", 
    .word CREATE, DROP, LITERAL, ENDS

;----------------------------------------------------------------------
;
; ok make a to value 
; change value 
HEADER "TO", "TOVALUE", F_IMMEDIATE
    .word FIND, ONEPLUS, TO, ENDS

;----------------------------------------------------------------------
;
; ok make a defer
; zzzz no checks for 
HEADER "DEFER", "DEFER", 
    .word CREATE, LIT, ZZZZ, LIT, BRANCH, COMMA, COMMA, ENDS

;----------------------------------------------------------------------
;
; ok make a is 
;
HEADER "IS", "ISDEFER", F_IMMEDIATE
    .word FIND, ONEPLUS, SWAP, TO, ENDS

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
HEADER "MARKTO", "MARKTO", F_IMMEDIATE | F_COMPILE,
    .word HERE, DUP, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok TOMARK 
; places a address of cell 
; resolves a back reference to last holder 
; and places a address to self at holder 
HEADER "TOMARK", "TOMARK", F_IMMEDIATE | F_COMPILE,
    .word HERE, SWAP, TOMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok BEGIN 
;
HEADER "BEGIN", "BEGIN", F_IMMEDIATE | F_COMPILE,
    .word HERE, ENDS 
 
;----------------------------------------------------------------------
;
; ok AGAIN resolves a unconditional branch 
;
HEADER "AGAIN", "AGAIN", F_IMMEDIATE | F_COMPILE,
    .word COMP, BRANCH, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok UNTIL resolves a conditional branch, as C do { ... } while (0) 
;
HEADER "UNTIL", "UNTIL", F_IMMEDIATE | F_COMPILE,
    .word COMP, ZBRANCH, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok UNLESS 
;
HEADER "UNLESS", "UNLESS", F_IMMEDIATE | F_COMPILE, 
    .word ZEQU, UNTIL, ENDS 
 
;----------------------------------------------------------------------
;
; ok IF (executed if tos is not zero)
;
HEADER "IF", "IF", F_IMMEDIATE | F_COMPILE,
    .word COMP, ZBRANCH, MARKTO, ENDS 
 
;----------------------------------------------------------------------
;
; ok GO (executed ever)
;
HEADER "GO", "GO", F_IMMEDIATE | F_COMPILE,
    .word COMP, BRANCH, MARKTO, ENDS 
 
;----------------------------------------------------------------------
;
; ok THEN 
;
HEADER "THEN", "THEN", F_IMMEDIATE | F_COMPILE,
    .word ENDIF, ENDS 
 
;----------------------------------------------------------------------
;
; ok ENDIF resolves a forward branch 
;
HEADER "ENDIF", "ENDIF", F_IMMEDIATE | F_COMPILE,
    .word TOMARK, ENDS 
 
;----------------------------------------------------------------------
;
; ok ELSE (executed if tos is zero)
;
HEADER "ELSE", "ELSE", F_IMMEDIATE | F_COMPILE,
    .word GO, SWAP, TOMARK, ENDS 
 
;----------------------------------------------------------------------
;
; ok WHILE 
;
HEADER "WHILE", "WHILE", F_IMMEDIATE | F_COMPILE,
    .word IF, SWAP, ENDS 
 
;----------------------------------------------------------------------
;
; ok REPEAT 
;
HEADER "REPEAT", "REPEAT", F_IMMEDIATE | F_COMPILE,
    .word AGAIN, TOMARK, ENDS 
 
 
;----------------------------------------------------------------------
; @eforth
; is AHEAD (a forward goto)
;
HEADER "AHEAD", "AHEAD", F_IMMEDIATE | F_COMPILE,
    .word GO, ENDS 
 
;----------------------------------------------------------------------
; @eforth
; is AFT 
;
HEADER "AFT", "AFT", F_IMMEDIATE | F_COMPILE,
    .word DROP, GO, HERE, SWAP, ENDS 
 
;----------------------------------------------------------------------
;
; is HOOK 
;
HEADER "HOOK", "HOOK", F_IMMEDIATE | F_COMPILE,
    .word BEGIN, TOR, ENDS 
 
;----------------------------------------------------------------------
;
; is BACK 
;
HEADER "BACK", "BACK", F_IMMEDIATE | F_COMPILE,
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
; rever zzzz
/*
\ CASE's implementation imported from Gforth.
\
\ Usage
\ ( n )
\ CASE
\    1 OF .... ENDOF
\    2 OF .... ENDOF
\    OTHERWISE
\ END-CASE
\
\ Remember not to consume the element in the OTHERWISE case.
*/
;----------------------------------------------------------------------
;
; is CASE ( a -- )
;
HEADER "CASE", "CASE", F_IMMEDIATE
    .word LIT, 0x00, ENDS

;----------------------------------------------------------------------
;
; is OF ( -- )
;
HEADER "OF", "OF", F_IMMEDIATE
    .word ONEPLUS, TOR, COMP, OVER, COMP, EQUAL, COMP, IF, COMP, DROP, RTO, ENDS

;----------------------------------------------------------------------
;
; is ENDOF ( -- )
;
HEADER "ENDOF", "ENDOF", F_IMMEDIATE
    .word TOR, COMP, ELSE, RTO, ENDS

;----------------------------------------------------------------------
;
; is ENDCASE ( a -- ) 
;
HEADER "ENDCASE", "ENDCASE", F_IMMEDIATE
    .word COMP, DROP 
    .word FOR, COMP, THEN, NEXT, ENDS

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
;   is <#
;
HEADER "<#", "LTSNUM",
    .word PAD, LIT, HLD, TO, ENDS

;----------------------------------------------------------------------
;   is #>
;
HEADER "#>", "SNUMGT",
    .word TWODROP, HLD, AT, PAD, OVER, MINUS, ENDS

;----------------------------------------------------------------------
;   is #
;   : # 0 BASE @ UM/MOD >R BASE @ UM/MOD SWAP DIGIT HOLD R> ; 
;
HEADER "#", "SNUM",
    .word ZERO, BASE, AT, UMBYMOD, TOR, BASE, AT, UMBYMOD
    .word SWAP, DIGIT, HOLD, RTO, ENDS

;----------------------------------------------------------------------
;   is #S
;   : #S BEGIN # 2DUP OR 0= UNTIL ; 
;
HEADER "#S", "SNUMS",
    .word SNUM, TWODUP, OR, ZEQU, ZBRANCH, SNUMS

;----------------------------------------------------------------------
;   is HOLD
;   : HOLD HLD @ CHAR- DUP HLD ! C! ; 
;
HEADER "HOLD", "HOLD",
    .word HLD, AT, CHARMINUS, DUP, HLD, TO, CTO, ENDS

;----------------------------------------------------------------------
;   is SIGN
;   : SIGN 0< IF [CHAR] - HOLD THEN ; 
;
HEADER "SIGN", "SIGN",
    .word ZEROLESS, ZBRANCH, 2f
    .word [CHAR], MINUS, HOLD
2:  .word ENDS

;----------------------------------------------------------------------
;
; is  ( u1 u2 -- u3 )
;
HEADER "UM-", "UMMINUS",
1:
    .word NEGATE, UMPLUS, ENDS
;----------------------------------------------------------------------
;
; is  ( -- )
;   no checks
;
HEADER "U-", "ULESS",
    .word UPP, AT, CELL, MINUS, DUP, UPP, TO, ENDS

;----------------------------------------------------------------------
;   User Stack from end sram
;
;----------------------------------------------------------------------
;
; is  ( -- )
;   no checks
;
HEADER "U+", "UMORE",
    .word UPP, AT, CELL, PLUS, DUP, UPP, TO, ENDS

;----------------------------------------------------------------------
;
; is  ( u -- )
;
HEADER "U@", "UAT",
1:
    .word UPP, AT, ENDS

;----------------------------------------------------------------------
;
; is  ( u -- )
;
HEADER "U!", "UTO",
1:
    .word UPP, TO, ENDS

;----------------------------------------------------------------------
;
; is  ( u -- )
;
HEADER ">U", "USV",
1:
    .word UPP, AT, TO, ENDS

;----------------------------------------------------------------------
;
; is  ( -- u )
;
HEADER "U>", "ULD",
1:
    .word UPP, AT, AT, ENDS

;----------------------------------------------------------------------
;
HEADER "COLD0", "COLDZERO", F_LEAP
    
    .word LIT, 0x0000, LIT, VOID, TO 
    .word LIT, 0x0000, LIT, LIVE, TO 
    .word LIT, 0x0000, LIT, TURN, TO 
    .word LIT, 0x0000, LIT, REST, TO 

    .word LIT, ZZZZ, LIT, LAST, TO 
    .word LIT, free_flash, LIT, VDP, TO
    .word LIT, EP0, LIT, VEP, TO

    .word LIT, UH0, LIT, VHP, TO
    .word LIT, US0, LIT, VUP, TO
    .word ENDS

;----------------------------------------------------------------------
;
HEADER "EELOAD", "EELOAD", F_LEAP
    .word ZERO, DUP, ATEE, LIT, VOID, TO 
    .word TWO, PLUS, DUP, ATEE, LIT, LIVE, TO 
    .word TWO, PLUS, DUP, ATEE, LIT, TURN, TO 
    .word TWO, PLUS, DUP, ATEE, LIT, REST, TO 

    .word TWO, PLUS, DUP, ATEE, LIT, LAST, TO 
    .word TWO, PLUS, DUP, ATEE, LIT, VDP, TO 
    .word TWO, PLUS, DUP, ATEE, LIT, VEP, TO 
    .word TWO, PLUS, DUP, ATEE, LIT, VUP, TO 
    .word ENDS

;----------------------------------------------------------------------
;
HEADER "EESAVE", "EESAVE", F_LEAP
    .word ZERO, DUP, LIT, VOID, AT, SWAP, TOEE 
    .word TWO, PLUS, DUP, LIT, LIVE, AT, SWAP, TOEE 
    .word TWO, PLUS, DUP, LIT, TURN, AT, SWAP, TOEE 
    .word TWO, PLUS, DUP, LIT, REST, AT, SWAP, TOEE 

    .word TWO, PLUS, DUP, LIT, LAST, AT, SWAP, TOEE 
    .word TWO, PLUS, DUP, LIT, VDP, AT, SWAP, TOEE 
    .word TWO, PLUS, DUP, LIT, VEP, AT, SWAP, TOEE 
    .word TWO, PLUS, DUP, LIT, VUP, AT, SWAP, TOEE 
    .word ENDS

;----------------------------------------------------------------------
;
HEADER "COLD", "COLD", F_LEAP
    .word EELOAD
    .word LIT, LIVE, ZEQU, ZBRANCH, _safe
    .word COLDZERO, EESAVE  
_safe:    
    .word LIT, RS0, RSTO
    .word LIT, PS0, PSTO
    .word LIT, 0x00, STATE, TO
    .word LIT, 0x10, BASE, TO
    .word LIT, WARM, RTO
    .word LIT, LIVE, DUP, AT, ONE, PLUS, SWAP, TO 
    .word ENDS 
 
;----------------------------------------------------------------------
;
HEADER "WARM", "WARM", F_LEAP
    ; verify error code 
    ; resets etc 
    .word TURN, AT, EXEC, QUIT, ENDS 
 
;----------------------------------------------------------------------
; does reset 
;
HEADER "BYE", "BYE", F_LEAP
    .word EESAVE
    .word REST, AT, EXEC, RESET, ENDS 

