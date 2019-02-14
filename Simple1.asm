	#include p18f87k22.inc
	
	extern	PWM_long, PWM_Setup, PWM_dc
	extern  ADC_Setup, ADC_Read
	extern LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear, LCD_delay_ms
	
main	code
	org 0x0
	goto	setup
	
	org 0x100			 ;Main code starts here at address 0x100



	
;main	code
	
setup	
	
	call PWM_Setup
	call ADC_Setup
	call	LCD_Setup	; setup LCD
	
	movlw	0x01
	movwf	PWM_dc	    ;setting PWM duty cycle to 2 ms
	clrf	TRISD
	clrf	PORTD
	

	;call    PWM_long

;measure_loop
	;call	ADC_Read
	;movff	ADRESH, 0x15
	;movf	ADRESL, W
	;addwf	0x15, W
	;movwf	PORTD
	;bra	measure_loop
	
	
loop	
	call	ADC_Read
	movff ADRESH, 0x023
	movf 0x023, W
	cpfsgt	0x021
	bra loop
	call delay
	movff PORTE, 0x025
	movf 0x025, W
	cpfseq	0x023
	bra loop
	cpfsgt	0x021
	bra loop
	goto measure_loop
	call LCD_delay_ms
	

measure_loop
	call	LCD_delay_ms
	call	LCD_clear
	movf	ADRESH,W
	call	LCD_Write_Hex
	movf	ADRESL,W
	call	LCD_Write_Hex
	goto	measure_loop		; goto current line in code
	
	goto $
	end
