#include p18f87k22.inc

    global  ADC_Setup, ADC_Read
    
ADC    code
    
ADC_Setup
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    bsf	    TRISA,RA1	    ; use pin A1(==AN1) for input
    bsf	    ANCON1,ANSEL8   ; set A1 to analog
    bsf	    TRISA,RA2	    ; use pin A2(==AN2) for input
    bsf	    ANCON2,ANSEL16   ; set A2 to analog
    
    movlw   0x01	    ; select AN1 for measurement
    movwf   ADCON0	    ; and turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    movlw   0x0B
    movwf   0x050, ACCESS   ;cut-off value of H
    movlw   0x33
    movwf   0x052, ACCESS   ;cut-off value of L
    
    return

ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    return
    


    end