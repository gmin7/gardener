#---------------------initial equ-----------------------#
.text 

.equ PUSHBUTTONS,    0xFF200050
.equ LEGOCONTROLLER, 0xFF200060

.equ JP1, 		 	0xFF200070
.equ TIMER,   		0xFF202000
.equ directionSet,  0x07F557FF

.equ motorForward,  0xFFFFFFFC
.equ motorBackward, 0xFFFFFFFE
.equ motorOff,   	0xFFFFFFFF

.equ gostraight,    0xFFFFFFFC
.equ goback,    	0xFFFFFFFA
.equ reset,         0xFFFFFFFF

.equ senser0On, 	0xFFFFFBFF
# .equ sensor1On,		0xFFFFEFFF
# .equ sensor2On,		0xFFFFBFFF

#---------------------register purpose-----------------------#
#r9  setting reg
#r10 counter reg
#r11 temp reg
#r12 stores senser0 value
#r15 state register 
#r16 threshold register 
#r17 comparator next move reg


#we use the motor 0 and senser0 and senser1
.global _start
_start:

#----------------------------------------------------------------#    
# set the direction reg    
	movia r8, JP1
	movia r9, directionSet
	stwio r9, 4(r8)#store 07f557ff at JP1 location

	movi r16, 9#set the threshold 



/*******************************control path*********************************/
#---------------------senser 0 right read loop-----------------------#
LOOP:#stop gap between movement
	movia r9, reset
	stwio r9, 0(r8)
	movia r10, 20000000
	bne r10, zero, INITIALDELAY#just let the motor move for a small period

    
LOOP0:#read sensor 0
	movia r11, senser0On   #turn on the sensor 0
	stwio r11, 0(r8)

	ldwio r10, 0(r8)   #checking if the data is valid
	srli r10, r10, 11  
	andi r10, r10, 0x1
	bne  r10, zero, LOOP0  #check again if is not 0(if is 1)

	ldwio r12, 0(r8)   #store sensor0's value into r12
	srli r12, r12, 27  
	andi r12, r12, 0x0F  #make sure the r12 only store the sensor0 value



BIT1:

	movi  r15, 0#clear the state register
	blt r12, r16, BIT1ADD1#< 
	beq r12, r16, BIT1ADD1#=
	bgt r12, r16, BIT1ADD0#> 

BIT1ADD0:
	addi r15, r15, 0
	br NEXTMOVE

BIT1ADD1:
	addi r15, r15, 1
	br NEXTMOVE





NEXTMOVE:
	movi r17, 0
	beq  r15, r17, FORWARD
	movi r17, 1
	beq  r15, r17, STOP


/*******************************data path*************************************/
#----------motor motion part--------------------#

#motor 0 moves forward
FORWARD:
	movia r9, gostraight
	stwio r9, 0(r8)
	movia r10, 200000
	bne r10, zero, DELAY#just let the motor move for a small period

STOP:
	movia r9, motorOff
	stwio r9, 0(r8)
	movia r10, 5000000
	bne r10, zero, DELAY#just let the motor move for a small period

#moter 0 moves backward
BACKWARD:
	movia r9, goback
	stwio r9, 0(r8)
	movia r10, 1000000
	bne r10, zero, DELAY#just let the motor move for a small period

/***sub direction control section*****/




DELAY:
	subi r10, r10, 1
	bne  r10, zero, DELAY
	br   LOOP
    
INITIALDELAY:
	subi r10, r10, 1
	bne  r10, zero, INITIALDELAY
	br   LOOP0
    




/***************************** END *****************************/

