;----------------------------------------------------------------------
; ok
LEAF 3, "D2/"
DSHR:
	NOOP
	pspull tos_low, tos_high
    lsr tos_low
    ror tos_high
	pspull wrk_low, wrk_high
    ror wrk_low
    ror wrk_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
    POON

;----------------------------------------------------------------------
; ok
LEAF 3, "D2*"
DSHL:
	NOOP
	pspull tos_low, tos_high
    lsl tos_low
    rol tos_high
	pspull wrk_low, wrk_high
    rol wrk_low
    rol wrk_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
    POON

;----------------------------------------------------------------------
; ok
LEAF 3, "2DUP"
TWODUP:
	NOOP
	pspull tos_low, tos_high
	pspull wrk_low, wrk_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
	POON
	
;----------------------------------------------------------------------
; ok
LEAF 3, "2DROP"
TWODUP:
	NOOP
	pspull tos_low, tos_high
	pspull wrk_low, wrk_high
	POON
	
