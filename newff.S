;---------------------------------------------------------------------
;	for easy do_spm at optiboot 
;
;	spm instruction uses r31:r30 for address and r1:r0 for data
;
;   when using optiboot do spm, it uses gcc standart function layout that
;   r24:r25 (W) for address, as r30:r31
;	r22:r23 (T) for code operation erase/fill/write, r23 not used
;	r20:r21 (N) for data, as r0:r1
;	 
;	when erase or write, r0:r1 is ignored, ATmega8L datasheet, pg 209
;
;   re-enable the RWW section already done by do_spm
;
;	do not expeculate, only one page to "flash flush"
;---------------------------------------------------------------------
;    
; ok start flash line buffer with a flash page  
;
HEADER "(flash)", "flash"

    ; preserve stack
    rspush psp_low, psp_high

    ; where it is ?    
    lds zpm_low, (HERE+0)
    lds zpm_high, (HERE+1)

    ; make round down pagesize, pagemask is ~pagesize
    andi zpm_low, lo8(pagemask)
    andi zpm_high, hi8(pagemask) ; not need if pagesize < 256
    
    ; prepare loop
    ldi psp_low, lo8(FIB)
    ldi psp_high, hi8(FIB)

	; how many bytes
	lds wrk_low, SPM_PAGESIZE

    ; adjust address for lpm
    lsr zpm_low
    rol zpm_high

2:
    lpm _work_, Z+
    st X+, _work_
    dec wrk_low
    brne 2b

4:    
    ; update where
    sts THIS+0, psp_low
    sts THIS+1, psp_high

    ; restore data stack
    rspull psp_low, psp_high
    POON
    
;----------------------------------------------------------------------
;
;
;   ok flush sram buffer to flash, 
;
;
HEADER "(flush)", "flush"
    NOOP

	; save psp for index
    rspush psp_low, psp_high

    ; into flash page
    lds r24, HERE+0
    lds r25, HERE+1

	; mask to match correct address
    andi r24, lo8(pagemask)
    andi r25, hi8(pagemask) ; not need if pagesize < 256

	; save address
	rspush r24, r25

    ; erase page
	; r0:r1 is ignored, ATmega8L datasheet, pg 209
    ldi r22, (1<<PGERS) | (1<<SPMEN)
    rcall _does_spm

    ; from sram buffer
    ldi psp_low, lo8(FIB)
    ldi psp_high, hi8(FIB)

	; how many bytes
    ldi r23, SPM_PAGESIZE

    ; copy page
20:
    ; fill page flash from sram
    ld r20, X+
    ld r21, X+
    ldi r22, (1<<SPMEN)
    rcall _does_spm
    adiw zpm_low, 2
	
	; count down
    dec r23
    dec r23
    brne 20b

	; load address
	rspull r24, r25

    ; write page
    ldi r22, (1<<PGWRT) | (1<<SPMEN)
    rcall _does_spm

    ; clean house
    rspull psp_low, psp_high
    POON

;----------------------------------------------------------------------
;
; wrapper around optiboot code
;

#define OPTI_DO_SPM 0x1fb0

_does_spm:
	in _sreg_, __SREG__
	cli
	rcall OPTI_DO_SPM 
	out __SREG__, _sreg_
	sei
	ret

;----------------------------------------------------------------------
/* from optiboot version 8.2 listing, extra comments added 
	;
	; the code for spm must reside in the NRWW flash
	;
	; make TARGET=Atmega8 AVR_FREQ=8000000L BAUD_RATE=9600 LED_START_FLASHES=5 TIMEOUT=2
	;
	; static void do_spm(uint16_t address, uint8_t command, uint16_t data)
	; r24:r25, r22:r23, r20:r21
    ;
	; Do spm stuff
	;
	; do_spm is 1fb0
	;
	1fb0:       fc 01           movw    r30, r24
    1fb2:       0a 01           movw    r0, r20
    1fb4:       67 bf           out     0x37, r22       ; 55
    1fb6:       e8 95           spm
	;
	;	keep r1 as zero
	;
    1fb8:       11 24           eor     r1, r1			
	;
  	; static void boot_spm_busy_wait()
	;
	; 	loop while not done
    1fba:       07 b6           in      r0, 0x37        ; 55
    1fbc:       00 fc           sbrc    r0, 0
    1fbe:       fd cf           rjmp    .-6             ; 0x1fba <do_spm+0xa>
	;
	;	if ( (command & (_BV(PGWRT)|_BV(PGERS))) && (data == 0) )
	;
    1fc0:       66 70           andi    r22, 0x06       ; 6 
    1fc2:       29 f0           breq    .+10            ; 0x1fce <do_spm+0x1e>
    1fc4:       45 2b           or      r20, r21
    1fc6:       19 f4           brne    .+6             ; 0x1fce <do_spm+0x1e>
    ;
	; 	static void boot_rww_enable_short()
	;
    1fc8:       81 e1           ldi     r24, 0x11       ; 17
    1fca:       87 bf           out     0x37, r24       ; 55
    1fcc:       e8 95           spm
	;
	; 	return
	;
    1fce:       08 95           ret
*/

