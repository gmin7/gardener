/*Taken and modified from http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/dev_newlegocontroller2.html*/
/*"Assembly Example: Assuming Lego controller is plugged into JP2, Trigger interrupt when the
Sensor3 value becomes greater than a threshold value of 0x5 (using state mode)"*/

/*********DECLARE CONSTANTS***********/


##JP2##
.equ ADDR_JP2, 0xFF200070      # address GPIO JP2
.equ ADDR_JP2_IRQ, 0x1000      # IRQ line for GPIO JP2 (IRQ12)
.equ ADDR_JP2_EDGE, 0xFF20007C      # address Edge Capture register GPIO JP2


##SEGS##
 .equ ADDR_7SEG1, 0xFF200020
 .equ ADDR_7SEG2, 0xFF200030


##PUSHBUTTONS##

.equ PUSHBUTTONS,    0xFF200050


##MOTOR##

.equ LEGOCONTROLLER, 0xFF200060

.equ JP2, 		 	0xFF200070
.equ TIMER,   		0xFF202000
.equ outputConfigure,  0x07F557FF

.equ motorForward,  0xFFFFFFFC
.equ motorBackward, 0xFFFFFFFE
.equ motorOff,   	0xFFFFFFFF

.equ gostraight,    0xFFFFFFFC
.equ goback,    	0xFFFFFFFA
.equ reset,         0xFFFFFFFF

.equ senser0On, 	0xFFFFFBFF
# .equ sensor1On,		0xFFFFEFFF
# .equ sensor2On,		0xFFFFBFFF




#------------------------------------------------------------------------#



.text
.global _start
_start:


/*********************LOAD TITLE CARD 1************************/







call audio


/******************POLL KEY 0 TO BEGIN********************/

















/*********************LOAD TITLE CARD 2************************/











/************** DEBUG SEG ENABLE ******************/
movi r16, 1
movi r17, 2
movi r18, 3

  movia r2, ADDR_7SEG1
  movia r3, 0x0000003f   # bits 0000110 will activate segments 1 and 2
  stwio r3,0(r2)        # Write to 7-seg display
  movia r2,ADDR_7SEG2
  stwio r0, 0(r2)

/*********ENABLE LIGHT SENSOR STATE MODE************/


   movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
   movia  r9, 0x07f557ff       # set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs
   stwio  r9, 4(r8)

# load sensor3 threshold value 5 and enable sensor3

   movia  r9,  0xf93effff       # set motors off enable threshold load sensor 3 ffff 1010
   stwio  r9,  0(r8)            # store value into threshold register

# disable threshold register and enable state mode

   movia  r9,  0xf95fffff      # keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)

# enable interrupts

    movia  r12, 0x40000000       # enable interrupts on sensor 3
    stwio  r12, 8(r8)

    movia  r8, ADDR_JP2_IRQ    # enable interrupt for GPIO JP2 (IRQ12)
    wrctl  ctl3, r8

    movia  r8, 1
    wrctl  ctl0, r8            # enable global interrupts

    LOOP:

       br  LOOP



/******************POLL KEY 1 TO ENABLE MOTOR********************/


#---------------------register purpose-----------------------#
#r9  setting reg
#r10 counter reg
#r11 temp reg
#r12 stores senser0 value
#r15 state register
#r16 threshold register
#r17 comparator next move reg



#----------------------------------------------------------------#

motor_enable:

# set the direction reg
	movia r8, JP2
	movia r9, outputConfigure
	stwio r9, 4(r8)#store 07f557ff at JP2 location

	movi r16, 9#set the threshold



/*-----control path------*/
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





/***************************** END MOTORS *****************************/





/***********************POLL RESET (KEY0)*************************/




/******************ISR FOR LIGHT SENSOR*******************/
.section .exceptions, "ax"
ISR:
   addi r16, r16, 1
  movia r2,ADDR_7SEG1
  movia r3,0x000000006   # bits 0000110 will activate segments 1 and 2
  stwio r3,0(r2)        # Write to 7-seg display
  movia r2,ADDR_7SEG2
  stwio r0, 0(r2)



  rdctl et, ctl4                    # check the interrupt pending register (ctl4)
  movia r2, ADDR_JP2_IRQ
  and	r2, r2, et                  # check if the pending interrupt is from GPIO JP2
  beq   r2, r0, EXIT

  movia r2, ADDR_JP2_EDGE           # check edge capture register from GPIO JP2
  ldwio et, 0(r2)
  andhi r2, et, 0x4000              # mask bit 29 (sensor 3)
  beq   r2, r0, EXIT        # exit if sensor 3 did not interrupt

  addi r17, r17, 1

EXIT:

  addi r18, r18, 1

  movia et, ADDR_JP2_EDGE
  movia r5, 0xffffffff
  stwio r5, 0(et)


	subi ea, ea, 4#restore the address of next instruction
	eret
