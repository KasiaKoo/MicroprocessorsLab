	#include p18f87k22.inc
	
	extern PWM_Setup, PWM_dc, PWM_test_routine, PWM_cycle_big2
	extern  ADC_Setup, ADC_Read
	extern LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear, LCD_delay_ms
	
acs0    udata_acs   ; named variables in access ram
delay_count res 1   ; reserve one byte for counter in the delay routine
	
	
main	code
	org 0x0
	goto	setup
	
	org 0x100			 ;Main code starts here at address 0x100

	
int_hi	code	0x0008	; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	incf	PWM_dc        ; decrementing counter from 256
	movff   PWM_dc, PORTH
	call    PWM_test_routine
	bcf	INTCON,TMR0IF	; clear interrupt flag	
	movlw   0x57
	cpfseq  PWM_dc
	retfie	FAST		; fast return from interrupt
	

	
;main	code
	
setup	
	
	call PWM_Setup
	call ADC_Setup
	call	LCD_Setup	; setup LCD

	
	clrf TRISH
	clrf PORTH  ;setting port G as output for int_cnt testing
	

	
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts


	
	clrf	TRISD
	clrf	PORTD	
	

measure_loop
	call	ADC_Read
	movff	ADRESH, 0x15
	movf	ADRESL, W
	addwf	0x15, W
	movwf	PORTD
	bra	measure_loop
	
	
;loop	
	;call	ADC_Read
	;movff ADRESH, 0x023
	;movf 0x023, W
	;cpfsgt	0x021
	;bra loop
	;call delay
	;movff PORTE, 0x025
	;movf 0x025, W
	;cpfseq	0x023
	;bra loop
	;cpfsgt	0x021
	;bra loop
	;goto measure_loop
	;call LCD_delay_ms
	

;measure_loop
	;call	LCD_delay_ms
	;call	LCD_clear
	;movf	ADRESH,W
	;call	LCD_Write_Hex
	;movf	ADRESL,W
	;call	LCD_Write_Hex
	;goto	measure_loop		; goto current line in code
	;goto $
	
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return
	
	end
