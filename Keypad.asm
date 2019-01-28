#include p18f87k22.inc

    global  Keypad_Setup, Con1, Con2, Read_Keypad

Keypad code
    
Keypad_Setup 
	bsf PADCFG1, REPU, BANKED	;set pull ups to on for PORTE
	clrf LATE			;writing 0s to the LATE register
	movlw 0xFF
	movwf PORTH			;setting PORTH to input
	return
	
Con1
	movlw 0x0F
	movwf TRISE, ACCESS			;setting 4-7 as outputs and 0-3 as inputs
	;may need to add delay here
	return
	
Con2
	movlw 0xF0
	movwf TRISE, ACCESS			;reversing inputs and outputs
	;may need to add delay here
	return
	
Read_Keypad
	movff PORTE, PORTH
	return

	end