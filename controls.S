
;----------------------------------------------------------------------
; from old fig-forth listings
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

