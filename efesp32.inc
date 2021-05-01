;-----------------------------------------------------------------
;
; 2020, from esp32Forth_62.pdf, Chen-Hanson Ting
;
;-----------------------------------------------------------------
; flags for words
;
	F_IMMED=0x80
	F_COMPO=0x40
	F_COMPILE=0x00
	F_INTERPRET=0x01
;-----------------------------------------------------------------
;
; KEY ( -- c )
HEADER "KEY", "KEY"
 .word QKEY
 .word QBRANCH
 .word KEY
 .word _LAST

;-----------------------------------------------------------------
;
; WITHIN ( u ul uh -- t )
HEADER "WITHIN", "WITHI"
 .word OVER
 .word SUBBB
 .word TOR
 .word SUBBB
 .word RFROM
 .word ULESS
 .word _LAST

;-----------------------------------------------------------------
;
; >CHAR ( c -- c )
HEADER ">CHAR", "TCHAR"
 .word DOLIT
 .word 0x7F
 .word ANDD
 .word DUPP
 .word DOLIT
 .word 0x7F
 .word BLANK
 .word WITHI
 .word QBRANCH
 .word TCHAR_0
 .word DROP
 .word DOLIT
 .word 0X5F
TCHAR_0:
 .word _LAST

;-----------------------------------------------------------------
;
; ALIGNED ( b -- a ) \ cell is 2
HEADER "ALIGNED", "ALIGN"
 .word DOLIT
 .word 0x0100
 .word PLUS
 .word DOLIT
 .word 0XFEFF
 .word ANDD
 .word _LAST

;-----------------------------------------------------------------
;
; HERE ( -- a )
HEADER "HERE", "HERE"
 .word CP
 .word AT
 .word _LAST

;-----------------------------------------------------------------
;
; PAD ( -- a )
HEADER "PAD", "PAD"
 .word PADD
 .word AT
 .word _LAST

;-----------------------------------------------------------------
;
; TIB ( -- a )
HEADER "TIB", "TIB"
 .word TTIB
 .word AT
 .word _LAST

;-----------------------------------------------------------------
;
; @EXECUTE ( a -- )
HEADER "@EXECUTE", "ATEXE"
 .word AT
 .word QDUP
 .word QBRANCH
 .word ATEXE_0
 .word EXECU
ATEXE_0:
 .word _LAST

;-----------------------------------------------------------------
;
; CMOVE ( b b u -- )
HEADER "CMOVE", "CMOVEE"
 CMOVEE_1FOR(0);
 .word BRANCH
 .word
 .word OVER
 .word CAT
 .word OVER
 .word CSTOR
 .word TOR
 .word ONEP
 .word RFROM
 .word ONEP
 THEN(0);
 NEXT(2,
 .word DDROP
 .word _LAST

;-----------------------------------------------------------------
;
; MOVE ( b b u -- )
HEADER "MOVE", "MOVE"
 int MOVE=
 COLON(1
 .word CELLD);
 FOR(0);
 AFT(8
 .word OVER
 .word AT
 .word OVER
 .word STORE
 .word TOR
 .word CELLP
 .word RFROM
 .word CELLP);
 THEN(0);
 NEXT(2
 .word DDROP
 .word _LAST

;-----------------------------------------------------------------
;
; FILL ( b u c -- )
HEADER "FILL", "FILL"
 int FILL=
 COLON(1
 .word SWAP);
 FOR(1
 .word SWAP);
 AFT(3
 .word DDUP
 .word CSTOR
 .word ONEP);
 THEN(0);
 NEXT(2
 .word DDROP
 .word _LAST

\ Number Conversions

;-----------------------------------------------------------------
;
; DIGIT ( u -- c )
HEADER "DIGIT", "DIGIT"
 .word DOLIT
 .word 0x09
 .word OVER
 .word LESS
 .word DOLIT
 .word 0x07
 .word ANDD
 .word PLUS
 .word DOLIT
 .word 0X30
 .word PLUS
 .word _LAST

;-----------------------------------------------------------------
;
; EXTRACT ( n base -- n c )
HEADER "EXTRACT", "EXTRC"
 .word DOLIT
 .word 0x00
 .word SWAP
 .word UMMOD
 .word SWAP
 .word DIGIT
 .word _LAST

;-----------------------------------------------------------------
;
; <# ( -- )
HEADER "<#", "BDIGS"
 .word PAD
 .word HLD
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; HOLD ( c -- )
HEADER "HOLD", "HOLD"
 .word HLD
 .word AT
 .word ONEM
 .word DUPP
 .word HLD
 .word STORE
 .word CSTOR
 .word _LAST

;-----------------------------------------------------------------
;
; # (dig) ( u -- u )
HEADER "#", "DIG"
 .word BASE
 .word AT
 .word EXTRC
 .word HOLD
 .word _LAST

;-----------------------------------------------------------------
;
; #S (digs) ( u -- 0 )
HEADER "#S", "DIGS"
 int DIGS=
 COLON(0);
 BEGIN(2
 .word DIG
 .word DUPP);
 WHILE(0);
 REPEAT(1
 .word _LAST

;-----------------------------------------------------------------
;
; SIGN ( n -- )
HEADER "SIGN", "SIGN"
 int SIGN=
 COLON(1
 .word ZLESS);
 IF(3
 .word DOLIT
 .word 0X2D
 .word HOLD);
 THEN(1
 .word _LAST

;-----------------------------------------------------------------
;
; #> ( w -- b u )
HEADER "#>", "EDIGS"
 .word DROP
 .word HLD
 .word AT
 .word PAD
 .word OVER
 .word SUBBB
 .word _LAST

;-----------------------------------------------------------------
;
; str ( n -- b u )
HEADER "str", "STRR"
 .word DUPP
 .word TOR
 .word ABSS
 .word BDIGS
 .word DIGS
 .word RFROM
 .word SIGN
 .word EDIGS
 .word _LAST

;-----------------------------------------------------------------
;
; HEX ( -- )
HEADER "HEX", "HEXX"
 .word DOLIT
 .word 0x10
 .word BASE
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; DECIMAL ( -- )
HEADER "DECIMAL", "DECIM"
 .word DOLIT
 .word 0x0A
 .word BASE
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; wupper ( w -- w' )
; ???? what is it?
HEADER "wupper", "UPPER"
 .word DOLIT
 .word 0x5F5F5F5F
 .word ANDD
 .word _LAST

;-----------------------------------------------------------------
;
; >upper ( c -- UC )
HEADER ">upper", "TOUPP"
 .word DUPP
 .word DOLIT
 .word 0x61
 .word DOLIT
 .word 0x7B
 .word WITHI);
 IF(3
 .word DOLIT
 .word 0x5F
 .word ANDD);
 THEN(1
 .word _LAST

;-----------------------------------------------------------------
;
; DIGIT? ( c base -- u t )
HEADER "DIGIT?", "DIGTQ"
 int DIGTQ=
 COLON(9
 .word TOR
 .word TOUPP
 .word DOLIT
 .word 0X30
 .word SUBBB
 .word DOLIT
 .word 0x09
 .word OVER
 .word LESS);
 IF(8
 .word DOLIT
 .word 0x07
 .word SUBBB
 .word DUPP
 .word DOLIT
 .word 0x0A
 .word LESS
 .word ORR);
 THEN(4
 .word DUPP
 .word RFROM
 .word ULESS
 .word _LAST

;-----------------------------------------------------------------
;
; NUMBER? ( a -- n T | a F )
HEADER "NUMBER?", "NUMBQ"
 int NUMBQ=
 COLON(12
 .word BASE
 .word AT
 .word TOR
 .word DOLIT
 .word 0x00
 .word OVER
 .word COUNT
 .word OVER
 .word CAT
 .word DOLIT
 .word 0X24
 .word EQUAL);
 IF(5
 .word HEXX
 .word SWAP
 .word ONEP
 .word SWAP
 .word ONEM);
 THEN(13
 .word OVER
 .word CAT
 .word DOLIT
 .word 0X2D
 .word EQUAL
 .word TOR
 .word SWAP
 .word RAT
 .word SUBBB
 .word SWAP
 .word RAT
 .word PLUS
 .word QDUP);
 IF(1
 .word ONEM);
 FOR(6
 .word DUPP
 .word TOR
 .word CAT
 .word BASE
 .word AT
 .word DIGTQ);
 WHILE(7
 .word SWAP
 .word BASE
 .word AT
 .word STAR
 .word PLUS
 .word RFROM
 .word ONEP);
 NEXT(2
 .word DROP
 .word RAT);
 IF(1
 .word NEGAT);
 THEN(1
 .word SWAP);
 ELSE(6
 .word RFROM
 .word RFROM
 .word DDROP
 .word DDROP
 .word DOLIT
 .word 0x0);
 THEN(1
 .word DUPP);
 THEN(6
 .word RFROM
 .word DDROP
 .word RFROM
 .word BASE
 .word STORE
 .word _LAST

\ Text Output


;-----------------------------------------------------------------
;
; SPACE ( -- )
HEADER "SPACE", "SPACE"
 .word BLANK
 .word EMIT
 .word _LAST

;-----------------------------------------------------------------
;
; CHARS ( +n c -- )
HEADER "CHARS", "CHARS"
 int CHARS=
 COLON(4
 .word SWAP
 .word DOLIT
 .word 0x00
 .word MAX);
 FOR(0);
 AFT(2
 .word DUPP
 .word EMIT);
 THEN(0);
 NEXT(2
 .word DROP
 .word _LAST

;-----------------------------------------------------------------
;
; SPACES ( +n -- )
HEADER "SPACES", "SPACS"
 .word BLANK
 .word CHARS
 .word _LAST

;-----------------------------------------------------------------
;
; TYPE ( b u -- )
HEADER "TYPE", "TYPES"
 int TYPES=
 COLON(0);
 FOR(0);
 AFT(5
 .word DUPP
 .word CAT
 .word TCHAR
 .word EMIT
 .word ONEP);
 THEN(0);
 NEXT(2
 .word DROP
 .word _LAST

;-----------------------------------------------------------------
;
; CR ( -- )
HEADER "CR", "CR"
 .word DOLIT
 .word 0x0A
 .word DOLIT
 .word 0x0D
 .word EMIT
 .word EMIT
 .word _LAST

;-----------------------------------------------------------------
;
; do$ ( -- $adr )
HEADER "do$", "DOSTR"
 .word RFROM
 .word RAT
 .word RFROM
 .word COUNT
 .word PLUS
 .word ALIGN
 .word TOR
 .word SWAP
 .word TOR
 .word _LAST

;-----------------------------------------------------------------
;
; $”| ( -- a )
HEADER "$\"|", "STRQP"
 .word DOSTR
 .word _LAST

;-----------------------------------------------------------------
;
; ”| ( -- )
HEADER ".\"|", "DOTQP"
 .word DOSTR
 .word COUNT
 .word TYPES
 .word _LAST

;-----------------------------------------------------------------
;
; .R ( u +n -- )
HEADER ".R", "DOTR"
 .word TOR
 .word STRR
 .word RFROM
 .word OVER
 .word SUBBB
 .word SPACS
 .word TYPES
 .word _LAST

;-----------------------------------------------------------------
;
; U.R ( u +n -- )
HEADER "U.R", "UDOTR"
 .word TOR
 .word BDIGS
 .word DIGS
 .word EDIGS
 .word RFROM
 .word OVER
 .word SUBBB
 .word SPACS
 .word TYPES
 .word _LAST

;-----------------------------------------------------------------
;
; U. ( u -- )
HEADER "U.", "UDOT"
 .word BDIGS
 .word DIGS
 .word EDIGS
 .word SPACE
 .word TYPES
 .word _LAST

;-----------------------------------------------------------------
;
; . (dot) ( n -- )
HEADER ".", " DOT"
 int DOT=
 COLON(5
 .word BASE
 .word AT
 .word DOLIT
 .word 0x0A
 .word XORR);
 IF(3
 .word UDOT
 .word _LAST
 THEN(4
 .word STRR
 .word SPACE
 .word TYPES
 .word _LAST

;-----------------------------------------------------------------
;
; ? ( a -- )
HEADER "?", "QUEST"
 .word AT
 .word DOT
 .word _LAST

\ Dictionary Search


;-----------------------------------------------------------------
;
; (parse) ( b1 u1 c --b2 u2 n )
HEADER "(parse)", "PARS : \t int PARS=
 COLON(5
 .word TEMP
 .word CSTOR
 .word OVER
 .word TOR
 .word DUPP);
 IF(5
 .word ONEM
 .word TEMP
 .word CAT
 .word BLANK
 .word EQUAL);
 IF(0);
 FOR(6
 .word BLANK
 .word OVER
 .word CAT
 .word SUBBB
 .word ZLESS
 .word INVER);
 WHILE(1
 .word ONEP);
 NEXT(6
 .word RFROM
 .word DROP
 .word DOLIT
 .word 0x00
 .word DUPP
 .word _LAST
 THEN(1
 .word RFROM);
 THEN(2
 .word OVER
 .word SWAP);
 FOR(9
 .word TEMP
 .word CAT
 .word OVER
 .word CAT
 .word SUBBB
 .word TEMP
 .word CAT
 .word BLANK
 .word EQUAL);
 IF(1
 .word ZLESS);
 THEN(0);
 WHILE(1
 .word ONEP);
 NEXT(2
 .word DUPP
 .word TOR);
 ELSE(5
 .word RFROM
 .word DROP
 .word DUPP
 .word ONEP
 .word TOR);
 THEN(6
 .word OVER
 .word SUBBB
 .word RFROM
 .word RFROM
 .word SUBBB
 .word _LAST
 THEN(4
 .word OVER
 .word RFROM
 .word SUBBB
 .word _LAST

;-----------------------------------------------------------------
;
; PACK$ ( b u a -- a )
; ???? what is it?
HEADER "PACK$", "PACKS"
 .word DUPP
 .word TOR
 .word DDUP
 .word PLUS
 .word DOLIT
 .word 0xFFFFFFFC
 .word ANDD
 .word DOLIT
 .word 0x00
 .word SWAP
 .word STORE
 .word DDUP
 .word CSTOR
 .word ONEP
 .word SWAP
 .word CMOVEE
 .word RFROM
 .word _LAST

;-----------------------------------------------------------------
;
; PARSE ( c -- b u ; <string> )
HEADER "PARSE", "PARSE"
 .word TOR
 .word TIB
 .word INN
 .word AT
 .word PLUS
 .word NTIB
 .word AT
 .word INN
 .word AT
 .word SUBBB
 .word RFROM
 .word PARS
 .word INN
 .word PSTOR
 .word _LAST

;-----------------------------------------------------------------
;
; TOKEN ( -- a ;; <string> )
HEADER "TOKEN", "TOKEN"
 .word BLANK
 .word PARSE
 .word DOLIT
 .word 0x1F
 .word MIN
 .word HERE
 .word CELLP
 .word PACKS
 .word _LAST PACK$ ;;

;-----------------------------------------------------------------
;
; WORD ( c -- a ; <string> )
HEADER "WORD", "WORDD"
 .word PARSE
 .word HERE
 .word CELLP
 .word PACKS
 .word _LAST

;-----------------------------------------------------------------
;
; NAME> ( nfa – cfa)
HEADER "NAME>", "NAMET"
 .word COUNT
 .word DOLIT
 .word 0x1F
 .word ANDD
 .word PLUS
 .word ALIGN
 .word _LAST

;-----------------------------------------------------------------
;
; SAME? ( a1 a2 n – a1 a2 f)
HEADER "SAME?", "SAMEQ"
 int SAMEQ=
 COLON(4
 .word DOLIT
 .word 0x1F
 .word ANDD
 .word CELLD);
 FOR(0);
 AFT(18
 .word OVER
 .word RAT
 .word DOLIT
 .word 0x4
 .word STAR
 .word PLUS
 .word AT
 .word UPPER
 .word OVER
 .word RAT
 .word DOLIT
 .word 0x4
 .word STAR
 .word PLUS
 .word AT
 .word U PPER
 .word SUBBB
 .word QDUP);
 IF(3
 .word RFROM
 .word DROP
 .word _LAST
 THEN(0);
 THEN(0);
 NEXT(3
 .word DOLIT
 .word 0x00
 .word _LAST

;-----------------------------------------------------------------
;
; FIND ( a va --cfa nfa, a F)
; ???? what is it?
HEADER "FIND", "FIND"
 int FIND=
 COLON(10
 .word SWAP
 .word DUPP
 .word AT
 .word TEMP
 .word STORE
 .word DUPP
 .word AT
 .word TOR
 .word CELLP
 .word SWAP);
 BEGIN(2
 .word AT
 .word DUPP);
 IF(9
 .word DUPP
 .word AT
 .word DOLIT
 .word 0xFFFFFF3F
 .word ANDD
 .word UPPER
 .word RAT
 .word UPPER
 .word XORR);
 IF(3
 .word CELLP
 .word DOLIT
 .word 0XFFFFFFFF);
 ELSE(4
 .word CELLP
 .word TEMP
 .word AT
 .word SAMEQ);
 THEN(0);
 ELSE(6
 .word RFROM
 .word DROP
 .word SWAP
 .word CELLM
 .word SWAP
 .word _LAST
 THEN(0);
 WHILE(2
 .word CELLM
 .word CELLM);
 REPEAT(9
 .word RFROM
 .word DROP
 .word SWAP
 .word DROP
 .word CELLM
 .word DUPP
 .word NAMET
 .word SWAP
 .word _LAST

\Interpreter


;-----------------------------------------------------------------
;
; NAME? ( a -- cfa na | a 0 )
HEADER "NAME?", "NAMEQ"
 .word CNTXT
 .word FIND
 .word _LAST

;-----------------------------------------------------------------
;
; EXPECT ( b u1 -- )
HEADER "EXPECT", "EXPEC"
 .word ACCEP
 .word SPAN
 .word STORE
 .word DROP
 .word _LAST

;-----------------------------------------------------------------
;
; QUERY ( -- )
HEADER "QUERY", "QUERY"
 .word TIB
 .word DOLIT
 .word 0X100
 .word ACCEP
 .word NTIB
 .word STORE
 .word DROP
 .word DOLIT
 .word 0x00
 .word INN
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; ABORT ( -- )
HEADER "ABORT", "ABORT"
 .word NOP
 .word TABRT
 .word ATEXE
 .word _LAST

;-----------------------------------------------------------------
;
; abort”| ( f -- )
HEADER "abort\"", "ABORQP"
 ABORQP=
 COLON(0);
 IF(4
 .word DOSTR
 .word COUNT
 .word TYPES
 .word ABORT);
 THEN(3
 .word DOSTR
 .word DROP
 .word _LAST

;-----------------------------------------------------------------
;
; ERROR ( a -- )
HEADER "ERROR", "ERRORR"
 .word SPACE
 .word COUNT
 .word TYPES
 .word DOLIT
 .word 0x3F
 .word EMIT
 .word CR
 .word ABORT

;-----------------------------------------------------------------
;
; $INTERPRET ( a -- )
HEADER "$INTERPRET", "$INTER"
 int INTER=
 COLON(2
 .word NAMEQ
 .word QDUP);
 IF(4
 .word CAT
 .word DOLIT
 .word F_COMPO
 .word ANDD);
 .word ABORQ
 .ascii " compile only", "INTER0=LABEL(2
 .word EXECU
 .word _LAST
 THEN(1
 .word NUMBQ);
 IF(1
 .word _LAST
 THEN(1
 .word ERRORR);

;-----------------------------------------------------------------
;
; [ (left-paren) ( -- )
HEADER "[", "LBRAC"
 .word DOLIT
 .word F_INTERPRET
 .word TEVAL
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; .OK ( -- )
HEADER ".OK", "DOTOK"
 int DOTOK=
 COLON(6
 .word CR
 .word DOLIT
 .word F_INTERPRET
 .word TEVAL
 .word AT
 .word EQUAL);
 IF(14
 .word TOR
 .word TOR
 .word TOR
 .word DUPP
 .word DOT
 .word RFROM
 .word DUPP
 .word DOT
 .word RFROM
 .word DUPP
 .word DOT
 .word RFROM
 .word DUPP
 .word DOT
 .word DOTQ
 .ascii " ok>", " THEN(1
 .word _LAST

;-----------------------------------------------------------------
;
; EVAL ( -- )
HEADER "EVAL", "EVAL"
 int EVAL=
 COLON(1
 .word LBRAC);
 BEGIN(3
 .word TOKEN
 .word DUPP
 .word AT);
 WHILE(2
 .word TEVAL
 .word ATEXE);
 REPEAT(4
 .word DROP
 .word DOTOK
 .word NOP
 .word _LAST

;-----------------------------------------------------------------
;
; QUIT ( -- )
HEADER "QUIT", "QUITT"
 int QUITT=
 COLON(1
 .word LBRAC);
 BEGIN(2
 .word QUERY
 .word EVAL);
 AGAIN(0);

;-----------------------------------------------------------------
;
; LOAD ( a n-- )
HEADER "LOAD", "LOAD"
 .word NTIB
 .word STORE
 .word TTIB
 .word STORE
 .word DOLIT
 .word 0x00
 .word INN
 .word STORE
 .word EVAL
 .word _LAST

\ Compiler


;-----------------------------------------------------------------
;
; , (comma) ( w -- )
HEADER ", ", "COMMA"
 .word HERE
 .word DUPP
 .word CELLP
 .word CP
 .word STORE
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; LITERAL ( n -- )
HEADER "LITERAL", "LITERAL"
 .word DOLIT
 .word DOLIT
 .word COMMA
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; ALLOT ( n -- )
HEADER "ALLOT", "ALLOT"
 .word ALIGN
 .word CP
 .word PSTOR
 .word _LAST

;-----------------------------------------------------------------
;
; $, ” ( -- )
HEADER "$, \"", "STRCQ"
 .word DOLIT
 .word 0X22
 .word WORDD
 .word COUNT
 .word PLUS
 .word ALIGN
 .word CP
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; ?UNIQUE ( a -- a )
HEADER "?UNIQUE", "UNIQU"
 int UNIQU=
 COLON(3
 .word DUPP
 .word NAMEQ
 .word QDUP);
 IF(6
 .word COUNT
 .word DOLIT
 .word 0x1F
 .word ANDD
 .word SPACE
 .word TYPES); DOTQ(" reDef");
 THEN(2
 .word DROP
 .word _LAST

;-----------------------------------------------------------------
;
; $, n ( a -- )
HEADER "$, n", "SNAME"
 int SNAME=
 COLON(2
 .word DUPP
 .word AT);
 IF(14
 .word UNIQU
 .word DUPP
 .word NAMET
 .word CP
 .word STORE
 .word DUPP
 .word LAST
 .word STORE
 .word CELLM
 .word CNTXT
 .word AT
 .word SWAP
 .word STORE
 .word _LAST
 THEN(1
 .word ERRORR);

;-----------------------------------------------------------------
;
; ' (tick) ( -- cfa )
HEADER "'", " TICK"
 int TICK=
 COLON(2
 .word TOKEN
 .word NAMEQ);
 IF(1
 .word _LAST
 THEN(1
 .word ERRORR);

;-----------------------------------------------------------------
;
; [COMPILE] ( -- ; <string> )
HEADER "[COMPILE]", "BCOMP"
 .word TICK
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; COMPILE ( -- )
HEADER "COMPILE", "COMPI"
 .word RFROM
 .word DUPP
 .word AT
 .word COMMA
 .word CELLP
 .word TOR
 .word _LAST

;-----------------------------------------------------------------
;
; $COMPILE ( a -- )
HEADER "$COMPILE", "SCOMP"
 int SCOMP=
 COLON(2
 .word NAMEQ
 .word QDUP);
 IF(4
 .word AT
 .word DOLIT
 .word F_IMEDD
 .word ANDD);
 IF(1
 .word EXECU);
 ELSE(1
 .word COMMA);
 THEN(1
 .word _LAST
 THEN(1
 .word NUMBQ);
 IF(2
 .word LITER
 .word _LAST
 THEN(1
 .word ERRORR);

;-----------------------------------------------------------------
;
; OVERT ( -- )
HEADER "OVERT", "OVERT"
 .word LAST
 .word AT
 .word CNTXT
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; ] (right paren) ( -- )
HEADER "]", " RBRAC"
 .word DOLIT
 .word F_COMPILE
 .word TEVAL
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; : (colon) ( -- ; <string> )
HEADER ":", "COLN"
 .word TOKEN
 .word SNAME
 .word RBRAC
 .word DOLIT
 .word 0x6
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; ; (semi-colon) ( -- )
HEADER ";", "SEMIS"
 .word DOLIT
 .word _LAST
 .word COMMA
 .word LBRAC
 .word OVERT
 .word _LAST

\ Debugging Tools


;-----------------------------------------------------------------
;
; dm+ ( b u – b+u )
HEADER "dm+", "DMP"
 int DMP=
 COLON(4
 .word OVER
 .word DOLIT
 .word 0x06
 .word UDOTR);
 FOR(0);
 AFT(6
 .word DUPP
 .word AT
 .word DOLIT
 .word 0x09
 .word UDOTR
 .word CELLP);
 THEN(0);
 NEXT(1
 .word _LAST

;-----------------------------------------------------------------
;
; DUMP ( b u -- )
HEADER "DUMP", "DUMP"
 int DUMP=
 COLON(10
 .word BASE
 .word AT
 .word TOR
 .word HEXX
 .word DOLIT
 .word 0x1F
 .word PLUS
 .word DOLIT
 .word 0x20
 .word SLASH);
 FOR(0);
 AFT(10
 .word CR
 .word DOLIT
 .word 0x08
 .word DDUP
 .word DMP
 .word TOR
 .word SPACE
 .word CELLS
 .word TYPES
 .word RFROM);
 THEN(0);
 NEXT(5
 .word DROP
 .word RFROM
 .word BASE
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; >NAME ( cfa -- nfa | F )
HEADER ">NAME", "TNAME"
 int TNAME=
 COLON(1
 .word CNTXT);
 BEGIN(2
 .word AT
 .word DUPP);
 WHILE(3
 .word DDUP
 .word NAMET
 .word XORR);
 IF(1
 .word ONEM);
 ELSE(3
 .word SWAP
 .word DROP
 .word _LAST
 THEN(0);
 REPEAT(3
 .word SWAP
 .word DROP
 .word _LAST

;-----------------------------------------------------------------
;
; .ID ( a -- )
HEADER ".ID", "DOTID"
 .word COUNT
 .word DOLIT
 .word 0x1F
 .word ANDD
 .word TYPES
 .word SPACE
 .word _LAST

;-----------------------------------------------------------------
;
; WORDS ( -- )
HEADER "WORDS", "WORDS"
 int WORDS=
 COLON(6
 .word CR
 .word CNTXT
 .word DOLIT
 .word 0x00
 .word TEMP
 .word STORE);
 BEGIN(2
 .word AT
 .word QDUP);
 WHILE(9
 .word DUPP
 .word SPACE
 .word DOTID
 .word CELLM
 .word TEMP
 .word AT
 .word DOLIT
 .word 0x10
 .word LESS);
 IF(4
 .word DOLIT
 .word 0x01
 .word TEMP
 .word PSTOR);
 ELSE(5
 .word CR
 .word DOLIT
 .word 0x00
 .word TEMP
 .word STORE);
 THEN(0);
 REPEAT(1
 .word _LAST

;-----------------------------------------------------------------
;
; FORGET ( -- , <name>)
HEADER "FORGET", "FORGET"
 int FORGT=
 COLON(3
 .word TOKEN
 .word NAMEQ
 .word QDUP);
 IF(12
 .word CELLM
 .word DUPP
 .word CP
 .word STORE
 .word AT
 .word DUPP
 .word CNTXT
 .word STORE
 .word LAST
 .word STORE
 .word DROP
 .word _LAST
 THEN(1
 .word ERRORR);

;-----------------------------------------------------------------
;
; COLD ( -- )
HEADER "COLD", "COLD"
 .word CR
 .work DOTQ
 .ascii "esp32forth V5.4, 2019 ", " int DOTQ1=LABEL(2
 .word CR
 .word _LAST

\ Control Structures


;-----------------------------------------------------------------
;
; THEN ( A -- )
HEADER "THEN", "THENN"
 .word HERE
 .word SWAP
 .word STORE
 .word _LAST

;-----------------------------------------------------------------
;
; FOR ( -- a )
HEADER "FOR", "FOR"
 .word COMPI
 .word TOR
 .word HERE
 .word _LAST

;-----------------------------------------------------------------
;
; BEGIN ( -- a )
HEADER "BEGIN", "BEGIN"
 .word HERE
 .word _LAST

;-----------------------------------------------------------------
;
; NEXT ( a -- )
HEADER "NEXT", "NEXT"
 .word COMPI
 .word DONXT
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; UNTIL ( a -- )
HEADER "UNTIL", "UNTIL"
 .word COMPI
 .word QBRAN
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; AGAIN ( a -- )
HEADER "AGAIN", "AGAIN"
 .word COMPI
 .word BRAN
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; IF ( -- A )
HEADER "IF", "IFF"
 .word COMPI
 .word QBRAN
 .word HERE
 .word DOLIT
 .word 0x00
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; AHEAD ( -- A )
HEADER "AHEAD", "AHEAD"
 .word COMPI
 .word BRAN
 .word HERE
 .word DOLIT
 .word 0x00
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; REPEAT ( A a -- )
HEADER "REPEAT", "REPEAT"
 .word AGAIN
 .word THENN
 .word _LAST

;-----------------------------------------------------------------
;
; AFT ( a -- a A )
HEADER "AFT", "AFT"
 .word DROP
 .word AHEAD
 .word HERE
 .word SWAP
 .word _LAST

;-----------------------------------------------------------------
;
; ELSE ( A -- A )
HEADER "ELSE", "ELSE"
 .word AHEAD
 .word SWAP
 .word THENN
 .word _LAST

;-----------------------------------------------------------------
;
; WHILE ( a -- A a )
HEADER "WHILE", "WHILE"
 .word IFF
 .word SWAP
 .word _LAST

\ String Literals


;-----------------------------------------------------------------
;
; ABORT" ( -- ; <string> )
HEADER "ABORT\"", "ABORT""
 .word DOLIT
 .word ABORQP
 .word HERE
 .word STORE
 .word STRCQ
 .word _LAST

;-----------------------------------------------------------------
;
; $" ( -- ; <string> )
HEADER "$\"", "STRQ"
 .word DOLIT
 .word STRQP
 .word HERE
 .word STORE
 .word STRCQ
 .word _LAST

;-----------------------------------------------------------------
;
; ." (dot-quot) ( -- ; <string> )
HEADER ".\"", "DOTQQ"
 .word DOLIT
 .word DOTQP
 .word HERE
 .word STORE
 .word STRCQ
 .word _LAST

\ Defining words


;-----------------------------------------------------------------
;
; CODE ( -- ; <string> )
HEADER "CODE", "CODE"
 .word TOKEN
 .word SNAME
 .word OVERT
 .word ALIGN
 .word _LAST

;-----------------------------------------------------------------
;
; CREATE ( -- ; <string> )
; ???? what is it?
HEADER "CREATE", "CREAT"
 .word CODE
 .word DOLIT
 .word 0x203D
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; VARIABLE ( -- ; <string> )
HEADER "VARIABLE", "VARIA"
 .word CREAT
 .word DOLIT
 .word 0x00
 .word COMMA
 .word _LAST

;-----------------------------------------------------------------
;
; CONSTANT ( n -- ; <string> )
; ???? what is it?
HEADER "CONSTANT", "CONST"
 .word CODE
 .word DOLIT
 .word 0x2004
 .word COMMA
 .word COMMA
 .word _LAST

;\ Comments

;-----------------------------------------------------------------
;
; .( (dot-paren) ( -- ; <string> )
HEADER ".(", "DOTPR"
 .word DOLIT
 .word 0X29
 .word PARSE
 .word TYPES
 .word _LAST

;-----------------------------------------------------------------
;
; \ (back-slash) ( -- ; <string> )
HEADER "\\", "BKSLA"
 .word DOLIT
 .word 0xA
 .word WORDD
 .word DROP
 .word _LAST

;-----------------------------------------------------------------
;
; ( (paren) ( -- ; <string> )
HEADER "(", "PAREN"
 .word DOLIT
 .word 0X29
 .word PARSE
 .word DDROP
 .word _LAST

;\ Flags

;-----------------------------------------------------------------
;
; COMPILE-ONLY ( -- )
HEADER "COMPILE-ONLY", "CCONLY"
 .word DOLIT
 .word F_COMPILE
 .word LAST
 .word AT
 .word PSTOR
 .word _LAST

;-----------------------------------------------------------------
;
; IMMEDIATE ( -- )
HEADER "IMMEDIATE", "IMMED"
 .word DOLIT
 .word F_IMMED
 .word LAST
 .word AT
 .word PSTOR
 .word _LAST

;-----------------------------------------------------------------


