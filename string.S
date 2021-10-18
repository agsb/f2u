;----------------------------------------------------------------------
;
; CMOVE copy bytes from source++ to destination++, decrease count--
HEADER "CMOVE", "MOVE"
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull origin
	pspull tos_low, tos_high
	
	; pull destination
	pspull zpm_low, zpm_high

    ; pull counter
	pspull wrk_low, wrk_high

	; test if zero
	cp wrk_low, wrk_high
	brbs BIT_ZERO, 2f

	; push psp
	rspush psp_low, psp_high

	; copy orign
	movw psp_low, tos_low

    ; no offset

  	; move a byte
1:  
	ld _work_, X+
    st Z+, _work_
    
    ; decrease counter
	sbiw wrk_low, 1

    ; again
	brbc BIT_ZERO, 1b

    ; pull psp
2:	
	rspull psp_low, psp_high
	POON

;----------------------------------------------------------------------
;
; CMOVE> copy bytes from source+count-- to destination--, decrease count--
HEADER "CMOVE>", "CMOVEGT"
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull origin
	pspull tos_low, tos_high
	
	; pull destination
	pspull zpm_low, zpm_high

    ; pull counter
	pspull wrk_low, wrk_high

	; test if zero
	cp wrk_low, wrk_high
	brbs BIT_ZERO, 2f

	; push psp
	rspush psp_low, psp_high

	; copy orign
	movw psp_low, tos_low

    ; do offset
	add zpm_low, wrk_low
	adc zpm_high, wrk_high
	add psp_low, wrk_low
	adc psp_high, wrk_high

    ; move a byte
1:  
	ld _work_, -X
    st -Z, _work_
    
    ; decrease counter
	sbiw wrk_low, 1
	brbc BIT_ZERO, 1b

	; pull psp
2:	
	rspull psp_low, psp_high
	POON

