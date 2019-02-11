    #include p18f87k22.inc
    
    global  PWM_long, PWM_Setup, PWM_dc
    
acs0    udata_acs   ; named variables in access ram
PWM_cnt_l   res 1   ; reserve 1 byte for variable PWM_cnt_l
PWM_cnt_h   res 1   ; reserve 1 byte for variable PWM_cnt_h
PWM_cnt_ms  res 1   ; reserve 1 byte for ms counter
PWM_pr	    res 4   ; reserve 4 bytes for pwm period
PWM_dc	    res 4   ; reserve 4 bytes for pwm duty cycle	    

  

PWM	code
 
PWM_Setup
	clrf TRISE	    
	clrf PORTE
	clrf LATE	    ; PORTE as PWM motor cycle
	movlw	0x14
	movwf	PWM_pr	    ;setting PWM period to 20 ms
	return
PWM_long
	movlw	0x01
	movwf	PORTE
	movf	PWM_dc, W
	call PWM_delay_ms
	movlw	0x00
	movwf	PORTE
	movf	PWM_dc, W
	subwf	PWM_pr, 0
	call	PWM_delay_ms
	bra PWM_long

	
	
	
PWM_delay_ms		    ; delay given in ms in W
	movwf	PWM_cnt_ms
pwmlp2	movlw	.250	    ; 1 ms delay
	call	PWM_delay_x4us	
	decfsz	PWM_cnt_ms
	bra	pwmlp2
	return
    
PWM_delay_x4us		    ; delay given in chunks of 4 microsecond in W
	movwf	PWM_cnt_l   ; now need to multiply by 16
	swapf   PWM_cnt_l,F ; swap nibbles
	movlw	0x0f	    
	andwf	PWM_cnt_l,W ; move low nibble to W
	movwf	PWM_cnt_h   ; then to PWM_cnt_h
	movlw	0xf0	    
	andwf	PWM_cnt_l,F ; keep high nibble in PWM_cnt_l
	call	PWM_delay
	return

PWM_delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
pwmlp1	decf 	PWM_cnt_l,F	; no carry when 0x00 -> 0xff
	subwfb 	PWM_cnt_h,F	; no carry when 0x00 -> 0xff
	bc 	pwmlp1		; carry, then loop again
	return			; carry reset so return

	end


