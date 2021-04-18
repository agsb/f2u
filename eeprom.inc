;----------------------------------------------------------------------
;792486AA–AVR–02/2013ATmega8(L)Note:1.   See “About Code Examples” on page 8
;
; from atmeg8 datasheet
;
#define EEWE	1
#define EEMWE	2
#define EERE	0

;----------------------------------------------------------------------
EEPROM_write:
; Wait for completion of previous write
sbic EECR, EEWE
rjmp EEPROM_write    	
;? Set Programming mode
;?ldi r17, (0<<EEPM1)|(0<<EEPM0)
;?out EECR, r17
; Set up address (r18:r19) in address register
out EEARH, r18
out EEARL, r19		
; Write data (r16) to data register
out EEDR, r16						
; Write logical one to EEMWE
sbi EECR, EEMWE						
; Start eeprom write by setting EEWE
sbi EECR, EEWE
ret
;----------------------------------------------------------------------
EEPROM_read:
; Wait for completion of previous write
sbic EECR, EEWE
rjmp EEPROM_read
; Set up address (r18:r19) in address register
out EEARH, r18
out EEARL, r19
; Start eeprom read by writing EERE
sbi EECR, EERE 
; Read data from data register
in r16, EEDR
ret

