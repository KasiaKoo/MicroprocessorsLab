    #include p18f87k22.inc
    
    global  PWM_Setup, PWM_dc, PWM_test_routine
    
acs0    udata_acs   ; named variables in access ram
PWM_cnt_l   res 1   ; reserve 1 byte for variable PWM_cnt_l
PWM_cnt_h   res 1   ; reserve 1 byte for variable PWM_cnt_h
   
PWM_cnt_b   res	4   ; reserve 4 bytes for big PWM cycle
PWM_cnt_m   res	4   ; reserve 4 bytes for mid PWM cycle
PWM_cnt_s   res	4   ; reserve 4 bytes for small PWM cycle
PWM_cnt_ms  res 1   ; reserve 1 byte for ms counter
PWM_pr	    res 4   ; reserve 4 bytes for PWM period
PWM_dc	    res 4   ; reserve 4 bytes for PWM duty cycle
counter	    res	4   ; reserve 4 bytes for test routine

PWM_counter res 2   ; reserve 2 bytes
  

PWM	code
 
PWM_Setup
	clrf TRISE	    
	clrf PORTE
	clrf LATE	    ; PORTE as PWM motor cycle
	movlw	0xC5
	movwf	PWM_pr	    ; setting PWM period length to 20 ms
	movlw   0x05
	movwf   PWM_counter
	movlw	0x0A
	movwf	PWM_dc      ; setting minimum duty cycle length to 1 ms
	movlw	0x02
	movwf	counter    
	return
	
;PWM_long
	;movlw	0x01
	;movwf	PORTE
	;movf	PWM_dc, W
	;call PWM_delay_ms
	;movlw	0x00
	;movwf	PORTE
	;movf	PWM_dc, W
	;subwf	PWM_pr, 0
	;call	PWM_delay_ms
	;decf    PWM_counter
	;movlw   0x05
	;cpfslt  PWM_dc
	;bra     restart
	;incf    PWM_dc
;loop2	;movlw   0x00
	;cpfseq  PWM_counter
	;bra     PWM_long
	;return
	
;restart movlw 0x01
	;movwf PWM_dc
	;goto loop2
	
PWM_test_routine
	decf	counter
	movlw	0xFF
	movwf	PORTE
	movf	PWM_dc, W
	call	PWM_cycle_big
	movlw	0x00
	movwf	PORTE
	movf	PWM_dc, W
	subwf	PWM_pr, W
	call	PWM_cycle_big
	movlw	0x00
	cpfsgt	counter
	incf	PWM_dc
	movlw	0x11
	cpfseq	PWM_dc
	bra	PWM_test_routine
reset_dc    
	movlw	0x0A
	movwf	PWM_dc
	bra	PWM_test_routine
	
	
;PWM_delay_ms		    ; delay given in ms in W
	;movwf	PWM_cnt_ms
;pwmlp2	;movlw	.125	    ; 1 ms delay
	;call	PWM_delay_x4us	
	;decfsz	PWM_cnt_ms
	;bra	pwmlp2
	;return
    
;PWM_delay_x4us		    ; delay given in chunks of 4 microsecond in W
	;movwf	PWM_cnt_l   ; now need to multiply by 16
	;swapf   PWM_cnt_l,F ; swap nibbles
	;movlw	0x0f	    
	;andwf	PWM_cnt_l,W ; move low nibble to W
	;movwf	PWM_cnt_h   ; then to PWM_cnt_h
	;movlw	0xf0	    
	;andwf	PWM_cnt_l,F ; keep high nibble in PWM_cnt_l
	;call	PWM_delay
	;return

;PWM_delay			; delay routine	4 instruction loop == 250ns	    
	;movlw 	0x00		; W=0
;pwmlp1	decf 	PWM_cnt_l,F	; no carry when 0x00 -> 0xff
	;subwfb 	PWM_cnt_h,F	; no carry when 0x00 -> 0xff
	;bc 	pwmlp1		; carry, then loop again
	;return			; carry reset so return

	
PWM_cycle_big
	movwf	PWM_cnt_b   ; counting down from number specified in test routine depending on duty cycle length
big	movlw	0x00
	cpfseq	PWM_cnt_b   ; skip next instruction and return if counter has reached 0
	goto	PWM_mid   ; delay of 0.1 ms 
	return
	
	
PWM_mid
	movlw	0x09
	movwf	PWM_cnt_m
mid	decf	PWM_cnt_m   ; counting down from 9
	movlw	0x00
	cpfseq	PWM_cnt_m   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	PWM_small
	decf	PWM_cnt_b
	bra	big
	
PWM_small	
	movlw	0x27
	movwf	PWM_cnt_s
small	decf	PWM_cnt_s   ; counting down from 39
	movlw	0x00
	cpfseq	PWM_cnt_s   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	small
	bra	mid
	
	end


