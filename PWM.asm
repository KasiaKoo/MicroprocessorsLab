    #include p18f87k22.inc
    
    global  PWM_Setup
    
 

PWM	code
 

	
PWM_Setup
    movlw	0xF0
    movwf	PR2		    ;Set the PWM period by writing to yhe PR2 register
    movlw	0x79
    movwf	CCPR4L		    ;Set the Duty Cycle 
    clrf	TRISE
    ;movlw	b'01'
    ;movwf	TMR2		    ;Seting the Time PreScale
    ;bsf		T2CON,0
    bsf		T2CON,2
    movlw	b'001100'
    movwf	CCP4CON		    ;Configuring CCP4 to PWM Mode
    return
    
    end
