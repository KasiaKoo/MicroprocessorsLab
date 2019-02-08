	#include p18f87k22.inc
	
	extern	PWM_Setup		
main	code
	org 0x0
	goto	setup
	
	org 0x100			 ;Main code starts here at address 0x100



	
;main	code
	
setup	
	call PWM_Setup
	nop
	goto $
	end
