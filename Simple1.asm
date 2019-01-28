	#include p18f87k22.inc

	extern  Keypad_Setup, Column, Row, Read_Keypad   ;external Keypad subroutines

rst	code	0    ; reset vector
	goto	setup


main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	call    Keypad_Setup	; setupp Keypad
	goto	start
	
	; ******* Main programme ****************************************
start 	;movlw 0x10
	;movwf PORTE
	;call Row
	call Read_Keypad
	
	goto	$		; goto current line in code (stay at this line forever)
	
	end