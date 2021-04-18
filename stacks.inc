;----------------------------------------------------------------------
; ok R@
LEAF 2, "R@"
RAT:
	NOOP
    pspush nds_low, nds_high
    movw nds_low, tos_low
	movw tos_low, rsp_low
    POON

;----------------------------------------------------------------------
; ok R>
LEAF 2, "R>"
RGT:
	NOOP
    pspush nds_low, nds_high
    movw nds_low, tos_low
    rspull tos_low, tos_high
    POON

;----------------------------------------------------------------------
; ok >R
LEAF 2, ">R"
GTR:
	NOOP
    rspush tos_low, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok S@
LEAF 3, "RS@"
RSAT:
	NOOP
    movw wrk_low, psp_low
    rjmp PUSHW

;----------------------------------------------------------------------
; ok RS!
LEAF 3, "RS!"
RSTO:
	NOOP
    movw rsp_low, tos_low
    rjmp DROP

;----------------------------------------------------------------------
; PS@
LEAF 4, "PS@"
PSAT:
	NOOP
    movw wrk_low, psp_low
    rjmp PUSHW

;----------------------------------------------------------------------
; PS!
LEAF 4, "PS!"
PSTO:
	NOOP
    movw psp_low, tos_low
    rjmp DROP

;----------------------------------------------------------------------
; ok ?DUP (a -- 0 | a a)
LEAF 3, "?DUP"
QMDUP:
	NOOP
    mov _work_, tos_low
    or _work_, tos_high
    breq _QMDUP1
    rjmp DUP
_QMDUP1:
    POON

;----------------------------------------------------------------------
; ok DUP (a -- a a)
LEAF 3, "DUP"
DUP:
	NOOP
    pspush nds_low, nds_high
    movw nds_low, tos_low
    POON

;----------------------------------------------------------------------
; ok SWAP (a b -- b a)
LEAF 4, "SWAP"
SWAP:
	NOOP
    movw wrk_low, nds_low
    movw nds_low, tos_low
    movw tos_low, wrk_low
    POON
 
;----------------------------------------------------------------------
;
; ok DROP (a b -- a)
;
LEAF 4, "DROP"
DROP:
	NOOP
    movw tos_low, nds_low
    pspull nds_low, nds_high
    POON

;----------------------------------------------------------------------
;
; ok (a b c -- w a b c )
; push a value or a flag, to tos
;
LEAF 5, "PUSH"
PUSH:
	NOOP
    pspush nds_low, nds_high
    movw nds_low, tos_low
    movw tos_low, wrk_low
    POON

;----------------------------------------------------------------------
;
; ok (w a b c -- a b c )
; push a value or a flag, to tos
;
LEAF 5, "PULL"
PULL:
	NOOP
    movw wrk_low, tos_low
    movw tds_low, nds_low
    pspull nds_low, nds_high
    POON

;----------------------------------------------------------------------
; ok ROT (a b c -- b c a)
;
LEAF 3, "ROT"
ROT:
	NOOP
    pspull wrk_low, wrk_high
    rjmp PUSH

;----------------------------------------------------------------------
; ok OVER (a b -- a b a)
;
LEAF 4, "OVER"
OVER:
	NOOP
    movw wrk_low, nds_low
    rjmp PUSH

;----------------------------------------------------------------------
;
; ok push a false 0x0000
;
LEAF 5, "FALSE"
ZERO:
	NOOP
FFALSE:
    clr wrk_low
    clr wrk_high
    rjmp PUSH

;----------------------------------------------------------------------
;
; ok push a true 0xFFFF
;
LEAF 4, "TRUE"
ONENEG:
	NOOP
FTRUE:
    ser wrk_low
    ser wrk_high
    rjmp PUSH

;----------------------------------------------------------------------
; ok 2drop
LEAF 5, "2DROP"
TWODROP:
	NOOP
    pspull tos_low, tos_high
    pspull nds_low, nds_high
    POON

;----------------------------------------------------------------------
; ok 2dup
LEAF 4, "2DUP"
TWODUP:
	NOOP
    pspush nds_low, nds_high
    pspush tos_low, tos_high
    POON

; ZZZZZZZZZZZZ 

;----------------------------------------------------------------------
; ok 2swap ( a b c d -- c d a b )
LEAF 4, "2SWAP"
TWOSWAP:
	NOOP
; get b
    pspull wrk_low, wrk_high
    rspush wrk_low, wrk_high
; get a
    pspull wrk_low, wrk_high
    rspush wrk_low, wrk_high
; put c
    pspush nds_low, nds_high
; put d 
    pspush tos_low, tos_high
; get a 
    rspull nds_low, nds_high
; get b
    rspull tos_low, tos_high
    POON





