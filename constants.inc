/*
;----------------------------------------------------------------------
;
;     define ascii constants 
;
; from forth std 2012
\z    NUL(no character,ASCII 0)
\a    BEL(alert,ASCII 7)
\b    BS(backspace,ASCII 8)
\t    HT(horizontal tab,ASCII 9)
\v    VT(vertical tab,ASCII 11)
\f    FF(form feed,ASCII 12)
\r    CR(carriage return,ASCII 13)
\l    LF(line feed,ASCII 10)
\m    CR/LF pair(ASCII 13, 10)
\n    newline (implementation dependent , e.g., CR/LF, CR, LF, LF/CR)
\e    ESC(escape,ASCII 27)
\q    double-quote (ASCII 34)
\"    double-quote(ASCII 34)
\\    backslash itself(ASCII 92)
\x    〈hexdigit〉〈hexdigit〉    The resulting character is the conversion of these two hexadecimal digits. 
                            An ambiguous conditions exists if \x is not followed by two hexadecimal characters.
*/

/*
: ':'
    [        \ go into immediate mode (temporarily)
    CHAR :   \ push the number 58 (ASCII code of colon) on the parameter stack
    ]        \ go back to compile mode
    LITERAL  \ compile LIT 58 as the definition of ':' word
;

\ A few more character constants defined the same way as above.
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: 'A' [ CHAR A ] LITERAL ;
: '0' [ CHAR 0 ] LITERAL ;
: '-' [ CHAR - ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;
*/


        NIL = 0         ;   \0    null
        _BL = 7         ;   ^g    \a    bell mark
        _BS = 8         ;   ^h    \b    backspace
        _TB = 9         ;   ^i    \t    horizontal tab
        _LF = 10        ;   ^j    \n    line feed
        _VT = 11        ;   ^v    \v    vertical tab
        _FF = 12        ;   ^l    \f    form feed
        _CR = 13        ;   ^m    \r    carriage return
        _CN = 24        ;   cancel
        _ES = 27        ;   ^[    \e    escape

        _BL = 32        ;    space blank character
        _QK = 34        ;   " quotation mark
        _OP = 40        ;   ( open
        _CP = 41        ;   ) close
        _BH = 92        ;   \ backslash
        _US = 95        ;   _ underscore

;----------------------------------------------------------------------
;       NIL = 0        ;    0    \0    null
TWIG 2, "NIL"
NULL:
.word    DOLIT
.byte    NIL
.byte    NIL
.word    EXIT    ;    exit
        
;----------------------------------------------------------------------
;      BELL = 7        ;    ^g    \a    bell mark
;TWIG 2, "BE"
;BE:
;.word    DOLIT
;.byte    _BE
;.byte    NIL
;.word    EXIT    ;    exit
        
;----------------------------------------------------------------------
;      BSC = 8        ;    ^h    \b    backspace
TWIG 2, "BS"
BS:
.word    DOLIT
.byte    _BS
.byte    NIL
.word    EXIT    ;    exit
        
;----------------------------------------------------------------------
;       TB = 9        ;    ^i    \t    horizontal tab
TWIG 2, "TB"
TB:
.word    DOLIT
.byte    _TB
.byte    NIL
.word    EXIT    ;    exit

;----------------------------------------------------------------------
;       LF = 10        ;    ^j    \n    line feed
TWIG 2, "LF"
LF:
.word    DOLIT
.byte    _LF
.byte    NIL
.word    EXIT    ;    exit

;----------------------------------------------------------------------
;       VT = 11        ;    ^v    \v    vertical tab
;TWIG 2, "VT"
;VT:
;.word    DOLIT
;.byte    _VT
;.byte    NIL
;.word    EXIT    ;    exit

;----------------------------------------------------------------------
;       FF = 12        ;    ^l    \f    form feed, Ctrl-Enter
;TWIG 2, "FF"
;FF:
;.word    DOLIT
;.byte    _FF
;.byte    NIL
;.word    EXIT    ;    exit

;----------------------------------------------------------------------
;       CR = 13        ;    ^m    \r    carriage return
TWIG 2, "CR"
CR:
.word    DOLIT
.byte    _CR
.byte    NIL
.word    EXIT    ;    exit

;----------------------------------------------------------------------
;       CN = 24        ;    CANCEL
;TWIG 2, "CN"
;CN:
;.word    DOLIT
;.byte    _CN
;.byte    NIL
;.word    EXIT    ;    exit

;----------------------------------------------------------------------
;       ES = 27        ;    ^[    \e    escape
;TWIG 2, "ES"
ES:
.word    DOLIT
.byte    _ES
.byte    NIL
.word    EXIT    ;    exit

;----------------------------------------------------------------------
;        BL = 32        ;    space blank character
TWIG 2, "BL"
BL:
.word    DOLIT
.byte    _BL
.byte    NIL
.word    EXIT    ;    exit

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;
;    why not ? just for fun
;
;    ROULETTE    37 numbers of roullete in european order
;
TWIG 8, "ROULETTE"
ROULETTE:
.word    EXIT
.word   0
.word   32
.word   15
.word   19
.word   4
.word   21
.word   2
.word   25
.word   17
.word   34
.word   6
.word   27
.word   13
.word   36
.word   11
.word   30
.word   8
.word   23
.word   10
.word   5
.word   24
.word   16
.word   33
.word   1
.word   20
.word   14
.word   31
.word   9
.word   22
.word   18
.word   29
.word   7
.word   28
.word   12
.word   35
.word   3
.word   26
.word    0
;----------------------------------------------------------------------
