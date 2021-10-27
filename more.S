
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
; ok BACK
HEADER, "BACK", "BACK", F_IMMEDIATE
	.word HERE, SUB, COMMA, ENDS

;----------------------------------------------------------------------
;
; ok BEGIN
HEADER, "BEGIN", "BEGIN", F_IMMEDIATE
	.word HERE, ENDS

;----------------------------------------------------------------------
;
; ok AGAIN
HEADER, "AGAIN", "AGAIN", F_IMMEDIATE
	.word COMP, BRANCH, BACK, ENDS

;----------------------------------------------------------------------
;
; ok UNTIL
HEADER, "UNTIL", "UNTIL", F_IMMEDIATE
	.word COMP, ZBRANCH, BACK, ENDS

;----------------------------------------------------------------------
;
; ok IF
HEADER, "IF", "IF", F_IMMEDIATE
	.word COMP, ZBRANCH, HERE, ZERO, COMMA, ENDS

;----------------------------------------------------------------------
;
; ok ENDIF
; note: use of store if addres is not 'here'
HEADER, "ENDIF", "ENDIF", F_IMMEDIATE
	.word HERE, OVER, SUB, SWAP, STORE, ENDS

;----------------------------------------------------------------------
;
; ok THEN
HEADER, "THEN", "THEN", F_IMMEDIATE
	.word ENDIF, ENDS

;----------------------------------------------------------------------
;
; ok ELSE
HEADER, "ELSE", "ELSE", F_IMMEDIATE
	.word COMP, BRANCH, HERE, ZERO, COMMA, 
	.word SWAP, ENDIF, ENDS

;----------------------------------------------------------------------
;
; ok WHILE
HEADER, "WHILE", "WHILE", F_IMMEDIATE
	.word IF, TWOP, ENDS

;----------------------------------------------------------------------
;
; ok REPEAT
HEADER, "REPEAT", "REPEAT", F_IMMEDIATE

	.word TOR, TOR, AGAIN, FROMR, FROMR, 
	.word SUB, ENDIF, ENDS

;----------------------------------------------------------------------
;
; ok interpret
HEADER "(quit)", "quit"
	NOOP
	POON

;----------------------------------------------------------------------
;
; ok colon ????
HEADER ":", "colon"
	.word iscompile, flash, HERE, AT ; for LAST link
	.word create, HERE, SWAP, ENDS

;----------------------------------------------------------------------
;
; ok semmi ????
HEADER ";", "semmi"
	.word isexecute, flush, updateep, ENDS

;----------------------------------------------------------------------
;
; ok 
;	updates the eprom permanent pointers, keeping things between reboots 
;   last is link to last word
;   here is the next free address in flash
;   were is the next free address in sram
;       keep in mind that all variables must be at sram
;
HEADER "(updateep)", "updateep"
	NOOP
	.word LAST, TO, hereto, lastto, ENDS

;----------------------------------------------------------------------
;
; ok 
;	
HEADER "CREATE", "CREATE"
	NOOP
	.word create, HERE, ENDS

;----------------------------------------------------------------------
; 	ok ( a u -- ) 
;
;	called after parse ;)
;
HEADER    "<BUILDS", "builds"
    NOOP
	POON

;----------------------------------------------------------------------
;    ok ( a u -- ) 
;
;	called after parse ;)
;
HEADER    "DOES>", "does"
    NOOP
	POON

;----------------------------------------------------------------------
; ok variable
;	ZZZZZ must check init sram and limits
;
HEADER "(variable)", "variable"
	.word (sram), DUP, AT 
	.word DUP, create, comma 
	.word DUP, ZERO, SWAP, TO 
	.word TWOMINUS, SWAP, TO
	.word updateep, ENDS

