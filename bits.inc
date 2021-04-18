
;----------------------------------------------------------------------
; ????
LEAF 8, "BITSCLEAR"
BITSCLEAR:
    com nds_low
    com nds_high
    rjmp AND

;----------------------------------------------------------------------
; ????
LEAF 7, "BITSSET"
BITSSET:
    com nds_low
    com nds_high
    rjmp AND

;----------------------------------------------------------------------
; ????
LEAF 10, "BITSTOGGLE"
BITSTOGGLE:
    com nds_low
    com nds_high
    rjmp AND

