	#include p18f87k22.inc
	
	extern	PWM_long, PWM_Setup, PWM_dc	
main	code
	org 0x0
	goto	setup
	
	org 0x100			 ;Main code starts here at address 0x100



	
;main	code
	
setup	
	
	call PWM_Setup
	
	movlw	0x02
	movwf	PWM_dc	    ;setting PWM duty cycle to 2 ms

	call PWM_long

	goto $
	end