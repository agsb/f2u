
;----------------------------------------------------------------------
;	eforth	ok 

#define	X_COMPILE = 0
#define X_INTERPRET = 1
;----------------------------------------------------------------------
;
HEADER "WARMi", "WARMi", "
.word doLIT, 0x0010, BASE, TO, doLIT, 0x0000, STATE, TO, _LAST

HEADER "["	
LBRACKET:	.word doLIT, X_COMPILE, STATE, TO, _LAST
		
HEADER  "]"	
RBRACKET:	.word doLIT, X_INTERPRET, STATE, TO, _LAST
		
HEADER "HEX"	
HEX:	.word doLIT, 16, BASE, TO, _LAST

HEADER "DEC", "DEC:	.word doLIT, 10, BASE, TO, _LAST

;----------------------------------------------------------------------
;
HEADER "QUIT", "QUIT: 	.word HEX, LBRACKET, 
	  	.word RSP0, RP!, PSP0, SP!, 
		.word STATE, AT, ZEQUAL, ZBRANCH, QUIT2, 
		.word PPTREADY
QUIT2:	.word REFILL, PPTINPUT, ZBRANCH, QUIT3,
		.word DOLIT, INTERPRET, CATCH, ZDUP, ZBRANCH, QUIT3,
		.word DUP, DOLIT, -2, LESS, ZBRANCH, QUIT5,
		.word PPTERROR,
QUIT5:	.word BRANCH, QUIT,
QUIT3:	.word PPTOKEY,
		.word BRANCH, QUIT2,
	  	.word _LAST

;----------------------------------------------------------------------
;
HEADER ".ready", "PPTREADY:	.word CR, 
			.string "> ", "			.word TYPE, 
			.word _LAST

;----------------------------------------------------------------------
;
HEADER ".input", "PPTINPUT:	.word CR, 
			.word _LAST

;----------------------------------------------------------------------
;
HEADER ".error", "PPTERROR:	.word CR, 
			.string ", "??? " 			.word TYPE, BASE, AT, TOR, DEC, DOT, TOIN, AT, DOT, RTO, BASE, TO, _LAST

;----------------------------------------------------------------------
;
HEADER ".ok", "PPTOKEY:	.word STATE, AT, DROP,
			.word CR,
			.string ", "ok" 			.word TYPE, 
			.word _LAST

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;
HEADER "COMPILE", "COMPILE"
.word 	RTO, DUP, AT, COMMA, CELLPLUS, TOR, _LAST

;----------------------------------------------------------------------
;
HEADER "LITERAL", "LITERAL"
.word 	COMPILE, doLIT, COMMA, _LAST

;----------------------------------------------------------------------
;
HEADER ",", "COMMA"
.word   HERE, DUP, CELLPLUS, CP, TO, TO, _LAST

;----------------------------------------------------------------------
;
HEADER "TWOTOR", "TWOTOR: .word SWAP, TOR, TOR, _LAST

;----------------------------------------------------------------------
;
HEADER "TWORTO", "TWORTO: .word RTO, RTO, SWAP, _LAST

;----------------------------------------------------------------------
;
HEADER "VARIABLE", "VARIABLE: .word   CREATE, doLIT, 0x0000, COMMA, _LAST

;----------------------------------------------------------------------
;
HEADER "ALLOT", "ALLOT: .word   doLIT, CP, PLUSTO, _LAST

;----------------------------------------------------------------------
;
HEADER "HERE", "HERE: .word   doLIT, CP, AT, _LAST

;----------------------------------------------------------------------
;
HEADER "PAD", "PAD: .word   HERE, doLIT, BUFFER_SIZE, PLUS, _LAST

;----------------------------------------------------------------------
;
HEADER "COUNT", "COUNT: .word   DUP, ONEPLUS, SWAP, CAT, _LAST

;----------------------------------------------------------------------
HEADER "KEY", "KEY: .word   KEYQM, QMBRANCH, KEY, _LAST	

;----------------------------------------------------------------------
HEADER "EMIT", "EMIT: .word   EMITQM, QMBRANCH, EMIT, _LAST	

;----------------------------------------------------------------------
HEADER "CR", "CREMIT: .word   CR, EMIT, LF, EMIT, _LAST		

;----------------------------------------------------------------------
HEADER "BL", "BLEMIT: .word   BL, EMIT, _LAST		

;----------------------------------------------------------------------
HEADER "IMMEDIATE?", "IMMEDIATEQM: .word   doLIT, F_IMMEDIATE, ZEROEQ, QMBRANCH, FTRUE, FFALSE, _LAST		

;----------------------------------------------------------------------
;	COMPILE?
HEADER "COMPILE?", "COMPILEQM: .word   doLIT, F_COMPILE, ZEROEQ, QMBRANCH, FTRUE, FFALSE, _LAST		

;----------------------------------------------------------------------
;	HIDDEN?
HEADER "HIDDEN?", "HIDDEN: .word   doLIT, F_HIDDEN, ZEROEQ, QMBRANCH, FTRUE, FFALSE, _LAST


;----------------------------------------------------------------------
; forth2012
;	but only ASCII, not UTF-8 aka CHAR
;
HEADER "TYPE", "TYPE: .word   DUP, QMBRANCH, _TYPE1, OVER, CAT, EMIT, ONEMINUS, SWAP, ONEPLUS, SWAP, BRANCH, DUP	
_TYPE1: .word   TWODROP, _LAST		

;----------------------------------------------------------------------
; forth2012
;	but only ASCII, not UTF-8 aka CHAR
;
HEADER "EXPECT", "EXPECT: .word   DUP, QMBRANCH, _EXPECT1, OVER, CAT, EMIT, ONEMINUS, SWAP, ONEPLUS, SWAP, BRANCH, DUP	
_EXPECT1: .word   TWODROP, _LAST		

;----------------------------------------------------------------------
;	ok	[	state is execute
HEADER "["		
ISEXEC: .word   doLIT, FFALSE, STATE, TO, _LAST

;----------------------------------------------------------------------
;	ok	]	state is compile
HEADER "]", "ISCOMP: .word   doLIT, FTRUE, STATE, TO, _LAST

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
HEADER "OCT", ".word  doLIT, 0x0008, BASE, TO, _LAST

;----------------------------------------------------------------------
; DECIMAL		;	0	\0	null
HEADER "DEC", ".word  doLIT, 10, BASE, TO, _LAST

;----------------------------------------------------------------------
; HEXADECIMAL		;	0	\0	null
HEADER "HEX", ".word  doLIT, 16, BASE, TO, _LAST

;----------------------------------------------------------------------
HEADER "DIGIT", ".word doLIT, 0x0900, OVER, LTHAN, doLIT, 0x0700, AND, PLUS, doLIT, '0', PLUS, _LAST

;----------------------------------------------------------------------
HEADER "<#", "BDIGS: .word   PAD, HLD, TO, _LAST

;----------------------------------------------------------------------
HEADER "BEGIN", ".word HERE , _LAST

;----------------------------------------------------------------------
HEADER "DO", ".word POSTPONE, TWOTOR, HERE , _LAST

;----------------------------------------------------------------------
HEADER ":", "COLON"
.word   ISCOMP, BEGIN, BL, FIND, DUP, IF, FFALSE, EQUAL, IF, EXECUTE, STACKQ, ABORTQT
.ascii	", "stack empty \"" 
.word   ELSE, COMMA, THEN, ELSE, _LAST

;----------------------------------------------------------------------
HEADER ";", ".word POSTPONE, _LAST, REVEAL, POSTPONE, OPENCOL, _LAST

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
HEADER "CREATE", ".word _LAST

;----------------------------------------------------------------------
;	
;	create a word in dictionary, uses next word in TIB pointed by
;
HEADER "DOES>", ".word _LAST

;----------------------------------------------------------------------
;
HEADER "CONSTANT", ".word CREATE, COMMA, DOES, AT, _LAST

;----------------------------------------------------------------------
;
HEADER "VARIABLE", ".word CREATE, doLIT, 0x0000, COMMA, _LAST

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



