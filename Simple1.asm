	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

		

	
start	movlw	0x00		    ; setting PORTD as only an output
	movwf	TRISD, ACCESS

	
	movlw	0x55		    ;choosing the four pins to be high 0,2,4,6
	movwf	PORTD, ACCESS
	call write
	
	
	
	
	goto	0x0
	
	
	
write		
	movlw	0x0A
	
	clrf	TRISE
		
	movwf	LATE, ACCESS
	
	movlw	0x51
	
	movwf	PORTD, ACCESS
	nop
	nop
	nop
	nop
	nop
	nop
	movlw	0x55
	movwf	PORTD, ACCESS
	
	setf TRISE
	
	return
	
	

	

	end
