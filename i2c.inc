;;----------------------------I2C_INIT-----------------------------
;I2C_INIT:
;     LDI    R21, 0              
;     OUT    TWSR, R21           ;Set prescaler bits to 0
;     LDI    R21, 0x47           ;R21 = 0x47
;     OUT    TWBR, R21           ;Fclk = 50 KHz (8 MHz Xtal)
;     LDI    R21, (1<<TWEN)      ;R21 = 0x04
;     OUT    TWCR, R21           ;HEnable TWI (I2C)
;     RET
;
;;----------------------------I2C_START-----------------------------
;I2C_START: 
;     LDI    R21, (1<<TWINT)|1<<(TWSTA)|(1<<TWEN)
;     OUT    TWCR, R21           ;Transmit START condition
; WAIT1:  
;     IN     R21, TWCR           ;Read Control Register TWCR into R21
;     SBRS   R21, TWINT          ;Skip the next line if TWINT is 1
;     RJMP   WAIT1               ;Jump a WAIT1 if TWINT is 1
;     RET  
;
; ;----------------------------I2C_WRITE -----------------------------
; I2C_WRITE:
;     OUT    TWDR, R27           ;Move the byte into TWRD
;     LDI    R21,  (1<<TWINT)|(1<<TWEN)
;     OUT    TWCR, R21           ;Configure TWCR to send TWDR
;  WAIT3:
;     IN     R21, TWCR           ;Read Control Register TWCR into R21
;     SBRS   R21, TWINT          ;Skip the next line if TWINT is 1
;     RJMP   WAIT3               ;Jump a WAIT3 if TWINT is 1
;     RET
;
; ;----------------------------I2C_STOP------------------------------
; I2C_STOP:
;     LDI    R21, (1<<TWINT)|1<<(TWSTO)|(1<<TWEN)
;     OUT    TWCR, R21           ;Transmit STOP condition
;     RET
;
;;----------------------------I2C_READ------------------------------
;I2C_READ:
;     LDI    R21,  (1<<TWINT)|(1<<TWEN)
;     OUT    TWCR, R21   
;WAIT2:
;    IN      R21, TWCR           ;Read Control Register TWCR into R21
;    SBRS    R21, TWINT          ;Skip the next line if TWINT is 1
;    RJMP    WAIT2               ;Jump a WAIT2 if TWINT is 1
;    IN      R27, TWCR           ;Read received data into R21
;    RET
;
