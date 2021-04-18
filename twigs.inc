
;----------------------------------------------------------------------
;	eforth	ok 
;
TWIG 1, ","
COMMA: 
.word   HERE, DUP, CELLPLUS, CP, TO, TO, EXIT

;----------------------------------------------------------------------
;	: .word  VARIABLE CREATE  0 , ;
TWIG 8, "VARIABLE"
VARIABLE: 
.word   CREATE, LITERAL, 0x0000, COMMA, EXIT

;----------------------------------------------------------------------
;
TWIG 5, "ALLOT"
ALLOT: .word   LITERAL, CP, PLUSTO, EXIT

;----------------------------------------------------------------------
;
TWIG 4, "HERE"
HERE: .word   LITERAL, CP, AT, EXIT

;----------------------------------------------------------------------
;
TWIG 3, "PAD"
PAD: .word   HERE, LITERAL, BUFFER_SIZE, PLUS, EXIT

;----------------------------------------------------------------------
;
TWIG 5, "COUNT"
COUNT: .word   DUP, ONEPLUS, SWAP, CAT, EXIT

;----------------------------------------------------------------------
TWIG 5, "KEY"
KEY: .word   KEYQM, QMBRANCH, KEY, EXIT	

;----------------------------------------------------------------------
TWIG 5, "EMIT"
EMIT: .word   EMITQM, QMBRANCH, EMIT, EXIT	

;----------------------------------------------------------------------
TWIG 5, "CR"
CREMIT: .word   CR, EMIT, LF, EMIT, EXIT		

;----------------------------------------------------------------------
TWIG 5, "BL"
BLEMIT: .word   BL, EMIT, EXIT		

;----------------------------------------------------------------------
TWIG 10, "IMMEDIATE?"
IMMEDIATEQM: .word   LITERAL, F_IMMEDIATE, ZEROEQ, QMBRANCH, FTRUE, FFALSE, EXIT		

;----------------------------------------------------------------------
;	COMPILE?
TWIG 8, "COMPILE?"
COMPILEQM: .word   LITERAL, F_COMPILE, ZEROEQ, QMBRANCH, FTRUE, FFALSE, EXIT		

;----------------------------------------------------------------------
;	HIDDEN?
TWIG 7, "HIDDEN?"
HIDDEN: .word   LITERAL, F_HIDDEN, ZEROEQ, QMBRANCH, FTRUE, FFALSE, EXIT


;----------------------------------------------------------------------
; forth2012
;	but only ASCII, not UTF-8 aka CHAR
;
TWIG 5, "TYPE"
TYPE: .word   DUP, QMBRANCH, _TYPE1, OVER, CAT, EMIT, ONEMINUS, SWAP, ONEPLUS, SWAP, BRANCH, DUP	
_TYPE1: .word   TWODROP, EXIT		

;----------------------------------------------------------------------
; forth2012
;	but only ASCII, not UTF-8 aka CHAR
;
TWIG 5, "EXPECT"
EXPECT: .word   DUP, QMBRANCH, _EXPECT1, OVER, CAT, EMIT, ONEMINUS, SWAP, ONEPLUS, SWAP, BRANCH, DUP	
_EXPECT1: .word   TWODROP, EXIT		

;----------------------------------------------------------------------
;	ok	[	state is execute
TWIG 1, "["		
ISEXEC: .word   LITERAL, FFALSE, STATE, TO, EXIT

;----------------------------------------------------------------------
;	ok	]	state is compile
TWIG 1, "]"
ISCOMP: .word   LITERAL, FTRUE, STATE, TO, EXIT

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
; OCTAL		;	0	\0	null
TWIG 3, "OCT"
.word  LITERAL, 0x0008, BASE, TO, EXIT

;----------------------------------------------------------------------
; DECIMAL		;	0	\0	null
TWIG 3, "DEC"
.word  LITERAL, 0x000A, BASE, TO, EXIT

;----------------------------------------------------------------------
; HEXADECIMAL		;	0	\0	null
TWIG 3, "HEX"
.word  LITERAL, 0x0010, BASE, TO, EXIT

;----------------------------------------------------------------------
TWIG 5, "DIGIT"
.word LITERAL, 0x0009, OVER, LTHAN, LITERAL, 0x0007, AND, PLUS, LITERAL, '0', PLUS, EXIT

;----------------------------------------------------------------------
TWIG 2, "<#"
BDIGS: .word   PAD, HLD, TO, EXIT

;----------------------------------------------------------------------
TWIG 5, "BEGIN"
.word IMMEDIATE, HERE , EXIT

;----------------------------------------------------------------------
TWIG 5, "DO"
.word IMMEDIATE, POSTPONE, TWOTOR, HERE , EXIT

;----------------------------------------------------------------------
TWIG 1, ":"
COLON: 
.word   ISCOMP, BEGIN, BL, FIND, DUP, IF, FFALSE, EQUAL, IF, EXECUTE, STACKQ, ABORTQT
.ascii	" stack empty \"" 
.word   ELSE, COMMA, THEN, ELSE, EXIT

;----------------------------------------------------------------------
TWIG 1, ";"
.word POSTPONE, EXIT, REVEAL, POSTPONE, OPENCOL, EXIT

;----------------------------------------------------------------------
;	eforth	ok 
;
TWIG 5, "CATCH"
CATCH: 
.word   SPAT, GTR, HANDLER, AT, GTR, RPAT, HANDLER, TO, EXECUTE, RGT, HANDLER, TO, RGT, DROP, FFALSE, EXIT

;----------------------------------------------------------------------
;	eforth	ok 
;
TWIG 5, "THROW"
THROW: 
.word   HANDLER, AT, PSTO, RGT, HANDLER, TO, RGT, SWAP, RGT, SPTO, DROP, RGT, EXIT

;----------------------------------------------------------------------
;	eforth	ok 
;
TWIG 1, "'"
TICK: 
.word   TOKEN, NAMEQ, QMBRANCH, EXIT, THROW, EXIT

;----------------------------------------------------------------------
;	eforth	ok 
;
TWIG 4, "[COMPILE]"
COMPILEMD: 
.word   RGT, DUP, AT, COMMA, CELLPLUS, RGT, PLUSTO , EXIT

;----------------------------------------------------------------------
;	
;	create a word in dictionary, uses next word in TIB pointed by
;
TWIG 4, "CREATE"
.word EXIT

;----------------------------------------------------------------------
;	
;	create a word in dictionary, uses next word in TIB pointed by
;
TWIG 4, "DOES>"
.word EXIT

;----------------------------------------------------------------------
;
TWIG 4, "CONSTANT"
.word CREATE, COMMA, DOES, AT, EXIT

;----------------------------------------------------------------------
;
TWIG 4, "VARIABLE"
.word CREATE, LITERAL, 0x0000, COMMA, EXIT

;-----------------------------------------------------------------
; eforth
;
TWIG 4, "doVAR"
doVAR: 
.word   EXIT

;----------------------------------------------------------------------
; eforth
;
TWIG 4, "doVOC"
doVOC: 
.word   EXIT

;----------------------------------------------------------------------
; eforth
;
TWIG 4, "doUSER"
doUSER: 
.word   EXIT

;----------------------------------------------------------------------
; eforth
;
TWIG 4, "FORTH"
FORTH: 
.word   EXIT



