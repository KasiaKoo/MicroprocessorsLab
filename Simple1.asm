#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100			 ;Main code starts here at address 0x100

		

	
start	movlw	0x5F			;choosing the four pins from previous and RD4 and RD6 on high
	movwf	PORTD, ACCESS
	movlw	0x00			
	movwf	TRISD, ACCESS		;setting PORTD as an output only
	
	
	call SPI_MasterInit
	
	movlw	0xA0			;8 bit data sequence 
	call SPI_MasterTransmit
loop
	goto	loop
	
SPI_MasterInit				; Set clock edge to negative
	bcf SSP2STAT, CKE
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw (1<<SSPEN)|(1<<CKP)|(0x02)
	movwf SSP2CON1
	; SDO2 output; SCK2 output
	bcf TRISD, SDO2
	bcf TRISD, SCK2
	return
	
SPI_MasterTransmit			; Start transmission of data (held in W)
	movwf SSP2BUF

Wait_Transmit				; Wait for transmission to complete
	btfss PIR2, SSP2IF
	bra Wait_Transmit
	bcf PIR2, SSP2IF		; clear interrupt flag
	return
	
	end
