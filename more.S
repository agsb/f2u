
;----------------------------------------------------------------------
;
; ok BEGIN
HEADER, "BEGIN", "BEGIN", F_IMMEDIATE
	.word HERE ENDS

;----------------------------------------------------------------------
;
; ok AGAIN
HEADER, "AGAIN", "AGAIN", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok UNTIL
HEADER, "UNTIL", "UNTIL", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok IF
HEADER, "IF", "IF", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok ELSE
HEADER, "ELSE", "ELSE", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok THEN
HEADER, "THEN", "THEN", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok AFT
HEADER, "AFT", "AFT", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok AHEAD
HEADER, "AHEAD", "AHEAD", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok WHILE
HEADER, "WHILE", "WHILE", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok REPEAT
HEADER, "REPEAT", "REPEAT", F_IMMEDIATE
	.word ENDS

;----------------------------------------------------------------------
;
; ok interpret
HEADER "(quit)", "quit"
	NOOP
	POON

;----------------------------------------------------------------------
;
; ok comma
HEADER ":", "colon"
	.word iscompile, flash, HERE, AT ; for LAST link
	.word create, HERE, SWAP, ENDS

;----------------------------------------------------------------------
;
; ok semmi
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

