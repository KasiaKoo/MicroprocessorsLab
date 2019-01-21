	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

		

	
start	movlw	0x00		    ; setting PORTD as only an output
	movwf	TRISD, ACCESS
	
	movwf	TRISE, ACCESS		;setting PORTE as only an output

	
	movlw	0x55		    ;choosing the four pins to be high 0,2,4,6
	movwf	PORTD, ACCESS
	
	movlw 0x0A			;choosing data that we want to put onto memory 1	
	movwf	0x05			;adress for data in memory 1
	
	movlw	0x0B			;choosing data that we want to put on memory 2
	movwf	0x06			;choosing adress for data for memor 2
	
	call write
	call read
	goto	0x0
	
	
	
write	
	;writing to first chip
	clrf	TRISE			;port E on output
		
	movff	0x05, LATE, ACCESS		;put the data on the bus for mem
	
	;movff	0x05, PORTE			;do we need to set it here after we put it on the bus?
	
	movlw	0x51			;only cp1 pin off
	
	movwf	PORTD, ACCESS		;clock off for 250 ns
	nop				
	nop
	nop
	nop
	nop
	nop
	movlw	0x55			
	movwf	PORTD, ACCESS		;clock on
	
	;setf TRISE		;so how is the OE off helping to write things?	
	
	;writing to second chip
	
	clrf	TRISE			;port E on output
	movff	0x06, LATE, ACCESS		;put the data on the bus for mem
	;movff	0x06, PORTE			;do we need to set it here after we put it on the bus?
	movlw	0x15			;only cp1 pin off
	movwf	PORTD, ACCESS		;clock off for 250 ns
	nop				
	nop
	nop
	nop
	nop
	nop
	movlw	0x55			
	movwf	PORTD, ACCESS		;clock on
	
	;setf TRISE		;so how is the OE off helping to write things?		
	
	return
	
read	
	;reading from first chip
	movlw 0xFF		    ; Enable Port E input
	movwf TRISE, ACCESS	
	
	movlw  0x54		    ; OE1 Low
	movwf PORTD
	
	movff PORTE,PORTC	    ; read data from port E display on port C
	
	movlw  0x55		    ; OE1 High
	movwf PORTD

	
	;reading from second chip
	
	movlw  0x45		    ; OE2 Low
	movwf PORTD
	
	movff PORTE,PORTJ	    ; Show read data
	
	movlw  0x0F		    ; OE2 high
	movwf PORT
	movff PORTE,PORTF	    ; read data from port E display on port C
	

	end
