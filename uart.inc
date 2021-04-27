
;----------------------------------------------------------------------
;
; ok init usart, from avr-gcc public code, io ports as constants
;
;    defaults to 9600, 8N1, no control
;
LEAF 3, "IO!"
IOYO:
    NOOP
    eor wrk_low, wrk_low
    out 0x20, wrk_low
    ldi wrk_low, lo8(52)
    out 0x9, wrk_low
    in wrk_low, 0xa
    ori wrk_low, lo8(24)
    out 0xa, wrk_low
    ldi wrk_low, lo8(-114)
    out 0x20, wrk_low
    in wrk_low, 0x20
    ori wrk_low,lo8(64)
    out 0x20, wrk_low
    POON

;----------------------------------------------------------------------
;
; ok non block, test if can receive a char ( -- 0x00 | ch 0xFF )
;
LEAF 4, "KEY?"
KEYQM:
RXAT:
    NOOP
    sbis 0xb, 7
    rjmp FFALSE
    in wrk_low, 0xc
    eor wrk_high, wrk_high
    pspush wrk_low, wrk_high 
    rjmp FTRUE

;----------------------------------------------------------------------
;
; ok non block, test if can send a char ( ch -- ch 0x00 | 0xFF )
;
LEAF 5, "EMIT?"
EMITQM:
TXTO:
    NOOP
    sbis 0xb, 5
    rjmp FFALSE
    pspull wrk_low, wrk_high
    out 0xc, wrk_low
    rjmp FTRUE

