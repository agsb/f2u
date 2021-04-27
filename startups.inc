;----------------------------------------------------------------------
; init instruction pointer and etc
;
LEAF 3, "BYE"
BYE:
	NOOP
; in a uC better sleep or reset ?
	rjmp RESET
	POON

;----------------------------------------------------------------------
;
; init return stack
;
LEAF 5, "ABORT"
ABORT:
	NOOP
;	init registers
    eor _work_, _work_
    eor _zero_, _zero_
    eor tos_high, tos_high
    eor tos_low, tos_low
    eor nds_high, nds_high
    eor nds_low, nds_low
    eor wrk_high, wrk_high
    eor wrk_low, wrk_low
    ldi zh, hi8(_INIT)
    ldi zl, lo8(_INIT)
; init return stack
    ldi rsp_high, hi8(RSP_TOP)
    ldi rsp_low, lo8(RSP_TOP)
	rjmp QUIT

;----------------------------------------------------------------------
;
; init parameter stack
;
LEAF 4, "QUIT"
QUIT:
	NOOP
; init parameter stack
    ldi psp_high, hi8(PSP_TOP)
    ldi psp_low, lo8(PSP_TOP)
	POON

;----------------------------------------------------------------------
#include "constants.inc" 

;----------------------------------------------------------------------
#include "variables.inc" 

;----------------------------------------------------------------------
#include "twigs.inc" 

;----------------------------------------------------------------------

;----------------------------------------------------------------------
;
; init registers 
;

;----------------------------------------------------------------------
#include "uart.inc"

;----------------------------------------------------------------------
; ok load a value from flash and push into parameter stack
;
LEAF 7, "doLIT"
DOLIT:
	NOOP
    POON

;----------------------------------------------------------------------
; get address of a variable ????
;
LEAF 4, "doVAR"
DOVAR:
	NOOP
    POON

;----------------------------------------------------------------------
; get address of a constant ????
;
LEAF 4, "doCON"
DOCON:
	NOOP
    POON

