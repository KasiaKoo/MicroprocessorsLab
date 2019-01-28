#include p18f87k22.inc

    global  Keypad_Setup, Column, Row, Read_Keypad

Keypad code
    
Keypad_Setup
	banksel PADCFG1
	bsf PADCFG1, REPU, BANKED	;set pull ups to on for PORTE
	movlb 0x00
	clrf LATE			;writing 0s to the LATE register
	movlw 0x00
	movwf TRISH			;setting PORTH to output
	movwf PORTH
	return
	
Column
	movlw 0x0F
	movwf TRISE, ACCESS			;setting 4-7 as outputs and 0-3 as inputs
	movlw 0x0A
	movwf 0x30
	call delay
	return
	
Row
	movlw 0xF0
	movwf TRISE, ACCESS			;reversing inputs and outputs
	movlw 0x0A
	movwf 0x30
	call delay
	;cpfseq 
	return
	
Read_Keypad
	call Column
	movff PORTE, 0x05
	call Row
	movff PORTE, 0x07
	movf 0x07, W
	addwf 0x05, W
	movwf  0x11
	movff 0x11, PORTH
	call Column
	return

delay	decfsz	0x30	; decrement until zero
	bra delay
	return

	end
