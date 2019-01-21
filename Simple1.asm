#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100			 ;Main code starts here at address 0x100

		

	
start	movlw	0x0F			;choosing the four pins to be high 0,2,4,6
	movwf	PORTD, ACCESS
	movlw	0x00			
	movwf	TRISD, ACCESS		;setting PORTD as an output only
	movwf	TRISE, ACCESS		;setting PORTE as an output only
	movwf	TRISC, ACCESS		;we set them as output only here cause that is their only function
	movwf	TRISH, ACCESS

	movlw	0x0B			;choosing data that we want to put into memory 1	
	movwf	0x05			;choosing address for data in memory 1
	movlw	0xAA			;choosing data that we want to put into memory 2
	movwf	0x06			;choosing address for data for memory 2
	call write
	call read
loop	goto	loop

	
write	;writing to first chip
	clrf	TRISE			;setting PORTE to the tri state	
	movff	0x05, LATE		;putting the data on the bus 
	movlw	0x0D			;only cp1 pin off
	movwf	PORTD, ACCESS		;clock off for 250 ns
	nop				
	nop
	nop
	nop
	nop
	nop
	movlw	0x0F			
	movwf	PORTD, ACCESS		;clock on
	setf TRISE			
	
	;writing to second chip
	clrf	TRISE			;setting PORTE to the tri state
	movff	0x06, LATE		;put the data on the bus for mem
	movlw	0x07			;only cp1 pin off
	movwf	PORTD, ACCESS		;clock off for 250 ns
	nop				
	nop
	nop
	nop
	nop
	nop
	movlw	0x0F			
	movwf	PORTD, ACCESS		;clock on
	setf TRISE		    ;so how is the OE off helping to write things?		
	
	return
	
read	;reading from first chip
	movlw 0xFF		    ;setting PORTE input
	movwf TRISE, ACCESS	
	movlw  0x0E		    ;OE1 Low
	movwf PORTD
	movff PORTE,PORTC	    ; read data from port E display on port C
	movlw  0x0F		    ; OE1 High
	movwf PORTD
	
	;reading from second chip
	movlw  0x0B		    ; OE2 Low
	movwf PORTD
	movff PORTE,PORTH	    ; Show read data
	movlw  0x0F		    ; OE2 high
	movwf PORTD
	
	return
	
finish	nop
	end
	
