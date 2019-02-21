	#include p18f87k22.inc
	
	extern PWM_Setup_B, PWM_dc_B, PWM_rotate_B, PWM_delay_B
	extern PWM_Setup_T, PWM_dc_T, PWM_rotate_T, PWM_delay_T
	extern  ADC_Setup, ADC_Read
	extern LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear, LCD_delay_ms
	
acs0    udata_acs   ; named variables in access ram
delay_count res 1   ; reserve one byte for counter in the delay routine
temp_work   res 4
Y_ADC_h	    res 4
Y_ADC_l	    res 4
G_ADC_h	    res 4
G_ADC_l	    res 4
diff_l	    res 4
	
	
main	code
	org 0x0
	goto	setup
	
	org 0x100			 ;Main code starts here at address 0x100

	
int_hi	code	0x0008	; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	incf	PWM_dc_B        ; decrementing counter from 256
	call    PWM_rotate_B
	bcf	INTCON,TMR0IF	; clear interrupt flag	
	movlw   0x57
	cpfseq  PWM_dc_B
	retfie	FAST		; fast return from interrupt
	
	
setup	
	clrf TRISH
	clrf PORTH  ;setting port G as output for int_cnt testing
	call PWM_Setup_B
	call PWM_Setup_T
	call ADC_Setup
	call LCD_Setup	; setup LCD
	;clrf TRISH
	;clrf PORTH  ;setting port G as output for int_cnt testing
	

	
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts


measure_green
	movf	PWM_dc_T, W
	movwf	PORTH
	movlw	0x00
	movwf	diff_l
	;call	LCD_delay_ms
	movlw   0x05	    ; select AN1 for measurement
	movwf   ADCON0	    ; and turn ADC on
	call	ADC_Read
	movff	ADRESH,G_ADC_h
	movff	ADRESL,G_ADC_l
measure_yellow	
	movlw   0x09	    ; select AN1 for measurement
	movwf   ADCON0	    ; and turn ADC on
	call	ADC_Read
	movff	ADRESH,Y_ADC_h
	movff	ADRESL,Y_ADC_l
			
	
	movff	Y_ADC_h,0x15
	movff	Y_ADC_l,0x17
	movff	G_ADC_h,0x19
	movff	G_ADC_l,0x1B


	
check_h
	movf	G_ADC_h, W
	cpfseq	Y_ADC_h
	bra	change_h
check_l
	movf	G_ADC_l, W
	cpfsgt	Y_ADC_l
	call	sub_Y
	movf	G_ADC_l, W
	cpfslt	Y_ADC_l
	call	sub_G
	movlw	0x00
	cpfseq	diff_l
	call	change_l
	goto	measure_green


	goto $


change_h
	movf	G_ADC_h, W
	cpfsgt	Y_ADC_h
	call	dec_dc
	cpfslt	Y_ADC_h
	call	inc_dc
	goto	measure_green

change_l
	movf	G_ADC_l, W
	cpfsgt	Y_ADC_l
	call	dec_dc
	cpfslt	Y_ADC_l
	call	inc_dc
	return
	
sub_Y	movf	G_ADC_l, W
	subwf	Y_ADC_l, W
	movf	diff_l, W	
	return

sub_G	movf	Y_ADC_l, W
	subwf	G_ADC_l, W
	movf	diff_l, W	
	return
	
dec_dc	
	decf	PWM_dc_T
	return

inc_dc	
	incf	PWM_dc_T
	return
	
	

delay	decfsz	delay_count	; decrement until zero
	bra delay
	return
	
	end
