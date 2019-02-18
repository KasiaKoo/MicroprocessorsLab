	#include p18f87k22.inc
	
	extern PWM_Setup, PWM_dc, PWM_test_routine, PWM_cycle_big2
	extern  ADC_Setup, ADC_Read
	extern LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear, LCD_delay_ms
	
acs0    udata_acs   ; named variables in access ram
int_cnt	res 4

	
	
main	code
	org 0x0
	goto	setup
	
	org 0x100			 ;Main code starts here at address 0x100

	
;int_hi	code	0x0008	; high vector, no low vector
	;btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	;retfie	FAST		; if not then return
	;decf	int_cnt         ; decrementing counter from 256
	;movff   int_cnt, PORTH
	;bcf	INTCON,TMR0IF	; clear interrupt flag	
	;movlw   0x00
	;cpfseq  int_cnt
	;retfie	FAST		; fast return from interrupt
	;call    PWM_long
	

	
;main	code
	
setup	
	
	call PWM_Setup
	;call ADC_Setup
	;call	LCD_Setup	; setup LCD
	
	;movlw	0x01
	;movwf	PWM_dc	    ;setting PWM duty cycle to 2 ms
	clrf	TRISD
	clrf	PORTD
	;movlw	0x0F
	;movwf	int_cnt
	
	clrf TRISH
	clrf PORTH  ;setting port G as output for int_cnt testing
	
	;movlw 0x01
	;movwf PORTH
	;movlw 0x01
	;call PWM_cycle_big2
	;movlw 0xFF
	;movwf PORTH
	call PWM_test_routine
	
	;movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	;movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	;bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	;bsf	INTCON,GIE	; Enable all interrupts

	;call    PWM_long
	
	
	

;measure_loop
	;call	ADC_Read
	;movff	ADRESH, 0x15
	;movf	ADRESL, W
	;addwf	0x15, W
	;movwf	PORTD
	;bra	measure_loop
	
	
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
	goto $
	end
