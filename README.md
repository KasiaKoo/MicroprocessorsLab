# Microprocessors

Files used: Simple1, ADC, Top_Motor_PWM, Bottom_Motor_PWM

Pulse width modification modules were developed for top and bottom motors separately in order to create the correctly shaped pulses to send the MG90S motors to the correct angles

Top and bottom motors have the same logic and only vary in terms of the values used in setup

Analogue inputs from LDR potential divider circuits were converted to digital using code sourced from original master branch

Main code compares voltages from LDR potential dividers in order to move the top motor towards the LDR with higher light intensity incident on it

Bottom motor movement is on timer interrupt


