
;----------------------------------------------------------------------
;
;  ccomma is only used in header of a word
;
HEADER "c,", "CCOMMA"
	.word HERE, CAT, TO, HERE, CAT, ONEPLUS, HERE, TO, _LAST

;----------------------------------------------------------------------
;
; ok comma :)
;
HEADER ",", "COMMA"
	.word HERE, AT, TO, HERE, AT, TWOPLUS, HERE, TO, _LAST

;----------------------------------------------------------------------
;
; ok allot :)
;
HEADER "ALLOT", "ALLOT"
	.word HERE, AT, PLUS, HERE, TO, _LAST 

/*
;----------------------------------------------------------------------
;
; ok colon :)
;
HEADER ":", "COLON"
	.word PARSE, 
	.word LAST, COMMA, 
	.word HERE, TO,    
_COLON0:
	.word AT, ZBRANCH, _COLON1,
	.word DUP, TWOPLUS, CAT,  
	.word DUP, F_HIDDEN, AND, ZBRANCH, _COLON2,
	.word DROP, BRANCH, _COLON0,
_COLON2:
	.word 	

;----------------------------------------------------------------------
;
; ok semmi-colon :)
;
HEADER ";", "SEMMI"
	.word LAST, TWOPLUS, DUP, CAT, F_HIDDEN, XOR, SWAP, CTO, 
	.word F_INTERP, STATE, TO,
	.word HERE, DOLIT, _LAST, COMMA, _LAST

*/
