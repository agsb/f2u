
;----------------------------------------------------------------------
;	from various forths
;	prime eforth	
;
;	this is a already "COMPILED" dictionary
;

#define	X_COMPILE = 1
#define X_INTERPRET = 0
;----------------------------------------------------------------------
;
HEADER "WARM", "WARM"
.word DOLIT, 16, BASE, TO, DOLIT, 0, STATE, TO, COLD _LAST

HEADER "[", "LBRACKET"
.word DOLIT, X_COMPILE, STATE, TO, _LAST
		
HEADER  "]", "RBRACKET"
.word DOLIT, X_INTERPRET, STATE, TO, _LAST
		
HEADER "HEX", "HEX"
.word DOLIT, 16, BASE, TO, _LAST

HEADER "DEC", "DEC"
.word DOLIT, 10, BASE, TO, _LAST

HEADER "2>R", "TWOTOR"
.word SWAP, TOR, TOR, _LAST

HEADER "2R>", "TWORTO"
.word RTO, RTO, SWAP, _LAST

HEADER "VARIABLE", "VARIABLE"
.word   CREATE, COMPILE, DOLIT, 0x0000, COMMA, _LAST

; : LITERAL COMPILE DOLIT , ; IMMEDIATE
HEADER "LITERAL", "LITERAL"
.word COMPILE, DOLIT, COMMA, _LAST

HEADER "PAD", "PAD"
.word   PAD, AT, _LAST

HEADER "TIB", "TIB"
.word   TIB, AT, _LAST

HEADER "ALLOT", "ALLOT"
.word   CP, PLUSTO, _LAST

HEADER "HERE", "HERE"
.word   CP, AT, _LAST

HEADER "," "COMMA"
.word	HERE, TO, CELL, ALLOT, _LAST

HEADER "<MARK" "LMARK"
.word HERE, _LAST

HEADER "<RESOLVE" "LRESOLVE"
.word COMMA, LAST

HEADER ">MARK" "GMARK"
.word HERE, 0, COMMA, _LAST

HEADER ">RESOLVE" "GRESOLVE"
.word HERE, SWAP, CELL, MINUS,  TO, _LAST

HEADER "COMPILE" "COMPILE"
.word TICK, COMMA, _LAST

; : IF COMPILE ?BRANCH >MARK ; IMMEDIATE
HEADER "IF", "IF"
.word COMPILE, ZBRANCH, GMARK, _LAST

HEADER "ELSE", "ELSE"
.word COMPILE, BRANCH, GMARK, SWAP, GRESOLVE, _LAST 

: THEN >RESOLVE ; IMMEDIATE
HEADER "THEN", "THEN"
.word GRESOLVE, _LAST 

; : BEGIN <MARK ; IMMEDIATE
HEADER "BEGIN", "BEGIN"
.word LMARK, _LAST

; : AGAIN COMPILE BRANCH <RESOLVE ; IMMEDIATE
HEADER "AGAIN", "AGAIN"
.word COMPILE, BRANCH, LRESOLVE, _LAST

; : UNTIL COMPILE ?BRANCH <RESOLVE ; IMMEDIATE
HEADER "UNTIL", "UNTIL"
.word COMPILE, ZBRANCH, LRESOLVE, _LAST

; : FOR COMPILE >R <MARK ; IMMEDIATE
HEADER "FOR", "FOR"
.word COMPILE, TOR, LMARK, _LAST

: NEXT COMPILE NEXT <RESOLVE ; IMMEDIATE
HEADER "NEXT", "NEXT"
.word COMPILE, DONEXT, LRESOLVE, _LAST

; PASSPARSE
HEADER "CPARSE", "CPARSE"
.word  	OVER, OVER, ONEPLUS, ROT, CAT, ROT, EQUAL,  _LAST

; PARSE (c1 a1 -- ca u)
HEADER "PARSE", "PARSE"
.word  	PASSPARSE, INV, ZBRANCH, PARSE,	ONEMINUS, DUP, ROT, SWAP,
PARSE2: 
.word 	PASSPARSE, ZBRANCH, PARSE2, ONEMINUS, SWAP, DROP, OVER, MINUS, _LAST
	 
;----------------------------------------------------------------------
; : ELSE [COMPILE] AHEAD SWAP [COMPILE] THEN ; IMMEDIATE
HEADER "ELSE", "ELSE"
.word  

: WHILE [COMPILE] IF SWAP ; IMMEDIATE
: WHEN [COMPILE] IF OVER ; IMMEDIATE
: REPEAT [COMPILE] AGAIN >RESOLVE ; IMMEDIATE
: RECURSE LAST @ NAME> , ; IMMEDIATE


;----------------------------------------------------------------------
HEADER "'" "TICK"
.word	zzzzzz, _LAST

HEADER "[COMPILE]", "DOCOMPILE"
.word	TICK, COMMA, _LAST

HEADER "PARSE", "PARSE"
.word  TOIN, DUP, ZBRANCH, DUP, @, DUP, 

;----------------------------------------------------------------------
HEADER "KEY", "KEY"
.word   KEYQM, QMBRANCH, KEY, _LAST	

;----------------------------------------------------------------------
HEADER "EMIT", "EMIT"
.word   EMITQM, QMBRANCH, EMIT, _LAST	

;----------------------------------------------------------------------
HEADER "CR", "CREMIT"
.word   CR, EMIT, LF, EMIT, _LAST		

;----------------------------------------------------------------------
HEADER "BL", "BLEMIT"
.word   BL, EMIT, _LAST		

;----------------------------------------------------------------------
HEADER "IMMEDIATE?", "IMMEDIATEQM"
.word   DOLIT, F_IMMEDIATE, ZEROEQ, QMBRANCH, FTRUE, FFALSE, _LAST		

;----------------------------------------------------------------------
;	COMPILE?
HEADER "COMPILE?", "COMPILEQM"
.word   DOLIT, F_COMPILE, ZEROEQ, QMBRANCH, FTRUE, FFALSE, _LAST		

;----------------------------------------------------------------------
;	HIDDEN?
HEADER "HIDDEN?", "HIDDEN"
.word   DOLIT, F_HIDDEN, ZEROEQ, QMBRANCH, FTRUE, FFALSE, _LAST

;----------------------------------------------------------------------
; forth2012
;	but only ASCII, not UTF-8 aka CHAR
;
HEADER "TYPE", "TYPE"
.word   DUP, QMBRANCH, _TYPE1, OVER, CAT, EMIT, ONEMINUS, SWAP, ONEPLUS, SWAP, BRANCH, DUP	
_TYPE1:
.word   TWODROP, _LAST		

;----------------------------------------------------------------------
;
;	define base constants
;
		ONE	= 1
		TWO = 2
		SIX = 6
		OCT = 8
		TEN = 10
		DUO = 12
		HEX = 16


;----------------------------------------------------------------------
HEADER "DIGIT", "DIGIT"
.word DOLIT, 0x0900, OVER, LTHAN, DOLIT, 0x0700, AND, PLUS, DOLIT, '0', PLUS, _LAST

;----------------------------------------------------------------------
HEADER "<#", "BDIGS"
.word   PAD, HLD, TO, _LAST

;----------------------------------------------------------------------
HEADER ":", "COLON"
.word   ISCOMP, BEGIN, BL, FIND, DUP, IF, FFALSE, EQUAL, IF, EXECUTE, STACKQ, ABORTQT
.ascii	", "stack empty \"" 
.word   ELSE, COMMA, THEN, ELSE, _LAST

;----------------------------------------------------------------------
HEADER ";", "SEMMI"
.word POSTPONE, _LAST, REVEAL, POSTPONE, OPENCOL, _LAST

;----------------------------------------------------------------------
;	eforth	ok 
;
HEADER "CATCH", "CATCH"
.word   SPAT, GTR, HANDLER, AT, GTR, RPAT, HANDLER, TO, EXECUTE, RGT, HANDLER, TO, RGT, DROP, FFALSE, _LAST

;----------------------------------------------------------------------
;	eforth	ok 
;
HEADER "THROW", "THROW"
.word   HANDLER, AT, PSTO, RGT, HANDLER, TO, RGT, SWAP, RGT, SPTO, DROP, RGT, _LAST

;----------------------------------------------------------------------
;	eforth	ok 
;
HEADER "'", "TICK"
.word   TOKEN, NAMEQ, QMBRANCH, _LAST, THROW, _LAST

;----------------------------------------------------------------------
;	eforth	ok 
;
HEADER "[COMPILE]", "COMPILEMD"
.word   RGT, DUP, AT, COMMA, CELLPLUS, RGT, PLUSTO , _LAST

;----------------------------------------------------------------------
;	
;	create a word in dictionary, uses next word in TIB pointed by
;
HEADER "CREATE", "CREATE"
.word _LAST

;----------------------------------------------------------------------
;	
;	create a word in dictionary, uses next word in TIB pointed by
;
HEADER "DOES>", "DOES>"
.word _LAST

;----------------------------------------------------------------------
;
HEADER "CONSTANT", "CONSTANT"
.word CREATE, COMMA, DOES, AT, _LAST

;----------------------------------------------------------------------
;
HEADER "VARIABLE", "VARIABLE"
.word CREATE, DOLIT, 0x0000, COMMA, _LAST

;-----------------------------------------------------------------
; eforth
;
HEADER "doVAR", "doVAR"
.word   _LAST

;----------------------------------------------------------------------
; eforth
;
HEADER "doVOC", "doVOC"
.word   _LAST

;----------------------------------------------------------------------
; eforth
;
HEADER "doUSER", "doUSER"
.word   _LAST

;----------------------------------------------------------------------
; eforth
;
HEADER "FORTH", "FORTH"
.word   _LAST



