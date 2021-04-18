
;----------------------------------------------------------------------
;
; ok init usart, from avr-gcc public code, io ports as constants
;
;    defaults to 9600, 8N1, no control
;
LEAF 3, "IO!"
IOYO:
    eor wrk_low, wrk_low
    out 0x20, wrk_low
    ldi wrk_low,lo8(52)
    out 0x9,wrk_low
    in wrk_low,0xa
    ori wrk_low,lo8(24)
    out 0xa,wrk_low
    ldi wrk_low,lo8(-114)
    out 0x20,wrk_low
    in wrk_low,0x20
    ori wrk_low,lo8(64)
    out 0x20,wrk_low
    rjmp CORE

;----------------------------------------------------------------------
;
; ok non block, test if can receive a char ( -- 0x00 | ch 0xFF )
;
LEAF 4, "KEY?"
KEYQM:
RXAT:
    sbis 0xb, 7
    rjmp FFALSE
    in wrk_low, 0xc
    pspush nds_low, nds_high
    movw nds_low, tos_low
    rjmp FTRUE

;----------------------------------------------------------------------
;
; ok non block, test if can send a char ( ch -- ch 0x00 | 0xFF )
;
LEAF 5, "EMIT?"
EMITQM:
TXTO:
    sbis 0xb, 5
    rjmp FFALSE
    out 0xc, tos_low
    movw wrk_low, nds_low
    pspull nds_low, nds_high
    rjmp FTRUE

