
;----------------------------------------------------------------------
;
;    SRAM for user start at 0x060, 
;    forth reserves 0x060 to 0x0BF, about 48 words
;    user  variables starts at 0x0C0
;
;    Better Save Space.' Since the BSS segment only holds variables that don't have any value yet,
;
;----------------------------------------------------------------------
;
;    puts literal (word) into parameter stack
;
;----------------------------------------------------------------------
;
;    creates forth variables, pushes the address
;
HEADER "RSP0", "RSP0"
.word DOLIT, _wRSP0, _LAST

HEADER "PSP0", "PSP0"
.word DOLIT, _wPSP0, _LAST

HEADER "BASE", "BASE"
.word DOLIT, _wBASE, _LAST

HEADER "TIB", "TIB"
.word DOLIT, _wTIB, _LAST

HEADER ">IN", "TOIN"
.word DOLIT, _wTIN, _LAST

HEADER "CONTEXT", "CONTEXT"
.word DOLIT, _wCONTEXT, _LAST

HEADER "CURRENT", "CURRENT"
.word DOLIT, _wCURRENT, _LAST

HEADER "HLD", "HLD"
.word DOLIT, _wHLD, _LAST

HEADER "UP", "UP"
.word DOLIT, _wUP, _LAST

HEADER "CP", "CP"
.word DOLIT, _wCP, _LAST

HEADER "STATE", "STATE"
.word DOLIT, _wSTATE, _LAST

HEADER "LAST", "LAST"
.word DOLIT, _wLAST, _LAST

