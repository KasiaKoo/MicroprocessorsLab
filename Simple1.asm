	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start	movlw	0x00
	movwf	TRISD, ACCESS

	
loop	movlw	0x55
	movwf	PORTD, ACCESS
	
	bra	loop
	
	goto	0x0
	

	end
