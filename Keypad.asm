#include p18f87k22.inc

    global  Keypad_Setup, Column, Row, Read_Keypad

Keypad code
    
Keypad_Setup
	banksel PADCFG1
	bsf PADCFG1, REPU, BANKED	;set pull ups to on for PORTE
	movlb 0x00
	clrf LATE			;writing 0s to the LATE register
	movlw 0xFF
	movwf TRISH			;setting PORTH to input
	return
	
Column
	movlw 0x0F
	movwf TRISE, ACCESS			;setting 4-7 as outputs and 0-3 as inputs
	;may need to add delay here
	return
	
Row
	movlw 0xF0
	movwf TRISE, ACCESS			;reversing inputs and outputs
	;may need to add delay here
	return
	
Read_Keypad
	call Column
	movff PORTE, 0x05
	call Row
	movff PORTE, 0x07
	movf 0x07, W
	addwf 0x05, W
	movwf  0x11
	movwf PORTH, ACCESS
	return

	end