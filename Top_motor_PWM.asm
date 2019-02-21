    #include p18f87k22.inc
    
    global PWM_Setup_T, PWM_dc_T, PWM_rotate_T, PWM_delay_T
    
bnk0    udata	0x100   ; named variables in access ram
;~~~~~~~ Counters used in the delay
PWM_cnt_b   res	4   ; reserve 4 bytes for big PWM cycle
PWM_cnt_m   res	4   ; reserve 4 bytes for mid PWM cycle
PWM_cnt_s   res	4   ; reserve 4 bytes for small PWM cycle
PWM_cnt_b2   res	4   ; reserve 4 bytes for big PWM cycle
PWM_cnt_m2   res	4   ; reserve 4 bytes for mid PWM cycle
PWM_cnt_s2   res	4   ; reserve 4 bytes for small PWM cycle

;~~~~~~~ PWM period and duty cycle values
PWM_pr	    res 4   ; reserve 4 bytes for PWM period
PWM_dc_T    res 4   ; reserve 4 bytes for PWM duty cycle
counter	    res	4   ; reserve 4 bytes for test routine
PWM_counter res 2   ; reserve 2 bytes
PWM_dc_con  res 4
PWM_pr_con  res 4
  

PWM	code
 
PWM_Setup_T
	movlw	0xAA
	movwf	PWM_pr_con	    ; setting PWM period length to 20 ms
	movlw   0x05
	movwf   PWM_dc_con
	movlw	0x58
	movwf	PWM_pr, BANKED
	movlw   0x05
	movwf   PWM_counter, BANKED
	movlw	0x04
	movwf	PWM_dc_T, BANKED      ; setting minimum duty cycle length to 1 ms
	movff	PWM_dc_T, PORTH
	movlw	0x20
	movwf	counter, BANKED    
	return                    

	
PWM_rotate_T
	movlw	0x00
	cpfsgt	counter, BANKED
	call	counter_reset
	decf	counter, BANKED
	bsf	PORTE, 4
	movf    PWM_dc_con, W, BANKED
	call    PWM_cycle_big
	movf	PWM_dc_T, W, BANKED
	call	PWM_delay_T, BANKED
	bcf	PORTE, 4
	movf	PWM_dc_T, W, BANKED
	subwf	PWM_pr, W, BANKED
	call	PWM_delay_T
	movf	PWM_pr_con, W, BANKED
	call	PWM_cycle_big
	movlw	0x00
	cpfsgt	counter, BANKED
	return
	incf	PWM_dc_T
	movlw	0x57
	cpfseq	PWM_dc_T, BANKED
	return
	return
	;bra	PWM_rotate_T

reset_dc    
	movlw	0x04
	movwf	PWM_dc_T, BANKED
	bra	PWM_rotate_T
	
counter_reset
	movlw	0x20
	movwf	counter, BANKED
	return
	
	
;~~~~~~~~The delay used for the duty cycle of the motor~~~~~~~~~~~~~~~~~~~
PWM_delay_T
	movwf	PWM_cnt_b2, BANKED   ; counting down from number specified in test routine depending on duty cycle length
big2	movlw	0x00
	cpfseq	PWM_cnt_b2, BANKED   ; skip next instruction and return if counter has reached 0
	goto	PWM_mid2   ; delay of 0.1 ms 
	return
	
	
PWM_mid2
	movlw	0x05
	movwf	PWM_cnt_m2, BANKED
mid2	decf	PWM_cnt_m2, BANKED   ; counting down from 9
	movlw	0x00
	cpfseq	PWM_cnt_m2, BANKED   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	PWM_small2
	decf	PWM_cnt_b2, BANKED
	bra	big2
	
PWM_small2	
	movlw	0x10
	movwf	PWM_cnt_s2, BANKED
small2	decf	PWM_cnt_s2, BANKED   ; counting down from 39
	movlw	0x00
	cpfseq	PWM_cnt_s2, BANKED   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	small2
	bra	mid2

	
;~~~~~~~~The delay used for 17 ms of the period for the motor~~~~~~~~~~~~~~~~~~~	
PWM_cycle_big
	movwf	PWM_cnt_b , BANKED  ; counting down from number specified in test routine depending on duty cycle length
big	movlw	0x00
	cpfseq	PWM_cnt_b, BANKED   ; skip next instruction and return if counter has reached 0
	goto	PWM_mid  ; delay of 0.1 ms 
	return
	
	
PWM_mid
	movlw	0x09
	movwf	PWM_cnt_m, BANKED
mid	decf	PWM_cnt_m, BANKED   ; counting down from 9
	movlw	0x00
	cpfseq	PWM_cnt_m, BANKED   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	PWM_small
	decf	PWM_cnt_b, BANKED
	bra	big
	
PWM_small	
	movlw	0x27
	movwf	PWM_cnt_s, BANKED
small	decf	PWM_cnt_s, BANKED   ; counting down from 39
	movlw	0x00
	cpfseq	PWM_cnt_s, BANKED   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	small
	bra	mid
	
	end





