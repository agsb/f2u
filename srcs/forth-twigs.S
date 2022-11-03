
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
;
;    load variables 
;
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "TIB", "TIB",
    .word DOCON, TIB0, ENDS
    POON 
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "LATEST", "LATEST",
    .word DOVAR, LIST, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "STATE", "STATE",
    .word DOVAR, STAT, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "BASE", "BASE",
    .word DOVAR, BASE, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "(sram)", "sram_",
    .word DOVAR, LAST, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "(eeprom)", "eeprom_",
    .word DOVAR, KEEP, ENDS
 
;----------------------------------------------------------------------
;
; ok ( -- w) 
;
HEADER "(flash)", "flash_",
    .word DOVAR, HEAP, ENDS
 
;********************************************************************** 

;----------------------------------------------------------------------
;
; is HERE 
;
HEADER "HERE", "HERE",
    .word HEAP, AT, ENDS 
 
;----------------------------------------------------------------------
;
; is ALLOT 
;
HEADER "ALLOT", "ALLOT",
    .word HEAP, PLUSTO, ENDS 
 
;----------------------------------------------------------------------
;
; is ALIGN 
;
HEADER "ALIGN", "ALIGN",
    .word HEAP, AT, ALIGNED, HEAP, TO, ENDS 
 
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
    .word DUP, SWIP, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w3 w2 w1 --  w1 w2 w3 ) 
;
HEADER "FLIP", "FLIP",
    .word SWAP, SWIP, SWAP, ENDS 

;********************************************************************** 
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
;
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
    .word SWAP, OVER, AT, PLUS, SWAP, TO, ENDS 
 
;----------------------------------------------------------------------
;
; ok COMMMA ( w -- ) 
;
HEADER ",", "COMMA",
    .word HERE, TO, CELL, ALLOT, ENDS 
 
;----------------------------------------------------------------------
;
; ok this puts next cell into stack and compiles into HERE 
;
HEADER "COMPILE", "COMP",
    .word RTO, DUP, AT, COMMA, CELLPLUS, TOR, ENDS 
 
;----------------------------------------------------------------------
;
; ok compile a eow 
;
HEADER "EXIT", "EXIT",
    .word COMP, ENDS, ENDS

;----------------------------------------------------------------------
;
; ok execute xt from tos
;
HEADER "EXEC", "EXEC",
    .word TOR, ENDS

;----------------------------------------------------------------------
;
; ok make a word recursive 
;
HEADER "TAIL", "TAIL",
    .word RAT, CELL, MINUS, RTO, ENDS

;----------------------------------------------------------------------
;
; ok unconditional compile next word 
;
HEADER "POSTPONE", "POSTPONE", F_IMMEDIATE,
    .word FIND, COMMA, ENDS 

;----------------------------------------------------------------------
;
; Control words review. there is no more offset BRANCH.
;
;----------------------------------------------------------------------
 
;----------------------------------------------------------------------
;
; ok MARK 
; places a address of next cell in tos
; places a holder to self in next cell in dictionary
HEADER "MARKTO", "MARKTO", F_IMMEDIATE,
    .word HERE, DUP, COMMA, ENDS 
 
;----------------------------------------------------------------------
;
; ok MARK 
; places a address of next cell in tos
; places a holder to self in next cell in dictionary
HEADER "TOMARK", "TOMARK", F_IMMEDIATE,
    .word HERE, SWAP, TO, ENDS 
 
;----------------------------------------------------------------------
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
    .word INVERT, UNTIL, ENDS 
 
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
    .word DROP, AHEAD, HERE, SWAP, ENDS 
 
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
    .word COMP, TOR, HERE, ENDS 
 
;----------------------------------------------------------------------
;
; is TXEN ( -- ) R:( -- h u ) 
;
HEADER "TXEN", "TXEN", F_IMMEDIATE
    .word RTO, ONEMINUS, DUP, IF, TOR, DUP, EXEC, ELSE, DROP, DROP, ENDS 
 
;----------------------------------------------------------------------
;
; is NEXT ( -- ) R:( -- h u ) 
;
HEADER "NEXT", "NEXT", F_IMMEDIATE
    .word COMP, TXEN, COMMA, ENDS

;----------------------------------------------------------------------
;
; DO and LOOP runs from 0x8000 till 0x7FFF, -32768 to 32767
; counting from 0 to 65535, as Forth-83
; ZZZZ
;
;----------------------------------------------------------------------
;
; ok DO (Forth-83)
;
HEADER "DO", "DO", F_IMMEDIATE,
    .word HERE, TOR, DOCON, 0x8000, 
    .word PLUS, DUP, TOR, MINUS, TOR, ENDS 
 
;----------------------------------------------------------------------
;
; ok DONT (not Forth-83)
;
HEADER "DONT", "DONT", F_IMMEDIATE,
    .word DROP, DROP, HERE, ENDS 
 
;----------------------------------------------------------------------
;
; is QDO ( u n -- ) (Forth-83)
;
HEADER "QDO", "QDO", F_IMMEDIATE,
    .word OVER, OVER, MINUS, COMP, ZBRANCH, HERE, DO, ENDS 
 
;----------------------------------------------------------------------
;
; ok LOOP (Forth-83)
;
HEADER "LOOP", "LOOP", F_IMMEDIATE,
    .word RAT, ONEPLUS, ZBRANCH, ZZZZ 
    .word RPAT, CELL, MINUS, CELL, MINUS
    .word ENDS 
 
;----------------------------------------------------------------------
;
; ok LEAVE (Forth-83)
;
HEADER "LEAVE", "LEAVE", F_IMMEDIATE,
    .word RTO, RTO, MINUS, ZZZZ, ENDS 
 
;--------------------------------------------------------------------
;
;----------------------------------------------------------------------
;
HEADER "COLD", "COLD", F_LEAP
    NOOP 

; restart return stack 
    ldi rsp_low, lo8(RS0) 
    ldi rsp_high, hi8(RS0) 

; restart parameter stack 
    ldi psp_low, lo8(PS0) 
    ldi psp_high, hi8(PS0) 

; preload to WARM 
    ; next word 
    ldi zpm_low, lo8(WARM) 
    ldi zpm_high, hi8(WARM) 
    rspush zpm_low, zpm_high 
    POON 
 
;----------------------------------------------------------------------
;
HEADER "WARM", "WARM", F_LEAP
    NOOP 
    ; verify error code 
    ; resets etc 
    POON 
 
;----------------------------------------------------------------------
; does reset 
;
HEADER "BYE", "BYE", F_LEAP
    NOOP 
    rjmp RESET 
    POON 

;----------------------------------------------------------------------
;
; is \]  
;
HEADER "]", "RBRAC",
    .word ONE, STATE, TO, ENDS 
 
;----------------------------------------------------------------------
;
; is \[ 
;
HEADER "[", "LBRAC", F_IMMEDIATE
    .word ZERO, STATE, TO, ENDS 
 
;----------------------------------------------------------------------
;
; is TOGGLE ( a f -- )
;
HEADER "TOGGLE", "TOGGLE",
    .word OVER, AT, XOR, SWAP, TO, ENDS 
 
;----------------------------------------------------------------------
;
; is >NFA ( a f -- )
; from link to c_name
;
HEADER ">NFA", "TONFA",
    .word CELL, PLUS, ENDS

;----------------------------------------------------------------------
;
; is >CFA ( a f -- )
; from link to code
HEADER ">CFA", "TOCFA", 
    .word CELL, PLUS, DUP, AT, F_UNMASK, AND, PLUS, ENDS

;----------------------------------------------------------------------
;
; is HIDDEN 
;
HEADER "HIDDEN", "HIDDEN",
    .word LATEST, TONFA, F_HIDDEN, TOGGLE, ENDS 

;----------------------------------------------------------------------
;
; is IMMEDIATE 
;
HEADER "IMMEDIATE", "IMMEDIATE", 
    .word LATEST, TONFA, F_IMMEDIATE, TOGGLE, ENDS 

;----------------------------------------------------------------------
;
; is COMPILE_ONLY 
;
HEADER "COMPILE_ONLY", "COMPILE_ONLY",
    .word LATEST, TONFA, F_COMPILE, TOGGLE, ENDS 

;----------------------------------------------------------------------
;
; is compile a header 
;
HEADER "CREATE", "CREATE",
    .word ENDS

;----------------------------------------------------------------------
;
; is gets a cc<chars>cc from source
;   ( -- a n )
;
HEADER "PARSE", "PARSE"
    .word ENDS

;----------------------------------------------------------------------
;
; is compile a header 
;
HEADER "FIND", "FIND",
    .word ENDS

;----------------------------------------------------------------------
;
; is  
;
HEADER ":", "COLON",
    .word CREATE, RBRAC, ENDS 
 
;----------------------------------------------------------------------
;
; is  
;
HEADER ";", "SEMMI",
    .word EXIT, LBRAC, ENDS 
  

;----------------------------------------------------------------------
;
; is  
;
;HEADER "INTERPRET", "INTERPRET",
;    .word WORD, DUP2, FIND, DUP, QBRANCH, notfound
;    .word LINK2XT, NIP, NIP, EXECUTE, BRANCH, INTERPRET
;notfound:    
;    .word DROP, DUP2, TONUMBER, QBRANCH, notnumber
;    .word NIP, NIP, BRANCH, INTERPRET
;notnumber:
;    .word EUNDEFI, AT, EXECUTE, BRANCH, INTERPRET
;    .word ENDS
;  
