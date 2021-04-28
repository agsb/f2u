; hash = (hash << 5) + str[i]
; for ascii chars in sram, in bytes not cells
; ( u a -- w ) djb hash
.equ djbHASH, 5381
LEAF 4, "HASH"
HASH:
	NOOP
	ldi nds_low, lo8(djbHASH)
	ldi nds_high, hi8(djbHASH)
	pspull ips_low, ips_high
	pspull wrk_low, wrk_high

_HASH1:
    ; decrease counter
    sbiw wrk_low, 1
    brlt _HASH2
	; get a char
	srload tos_low
	add nds_low, tos_low
	adc nds_high, _zero_
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
	rjmp _HASH1

_HASH2:
	pspush nds_low, nds_high
	POON
