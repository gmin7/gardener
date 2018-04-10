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

.equ ADDR_PUSHBUTTONS,    0xFF200050
.global MINT
.global TITLE1
.global TITLE2
.global ROSE
.global DRAW_IMAGE
.global COUNTER
.global INSTRUCTION
.global PARSELY
.global UNKNOWN_PLANT


#vga
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
MINT:
.incbin "mint.bmp", 70
TITLE1:
.incbin "title1.bmp", 70
TITLE2:
.incbin "title2.bmp", 70
ROSE:
.incbin "rosemary.bmp", 70
PARSELY:
.incbin "parsely.bmp", 70
INSTRUCTION:
.incbin "instructions.bmp", 70
UNKNOWN_PLANT:
.incbin "unknown_plant.bmp", 70

##MOTOR##

.equ LEGOCONTROLLER, 0xFF200060

.equ TIMER,   		0xFF202000
.equ outputConfigure,  0x07F557FF

.equ motorForward,  0xFFFFFFFC
.equ motorBackward, 0xFFFFFFFE
.equ motorOff,   	0xFa5FFFFF

.equ gostraight,    0xFa5FFFFC
.equ goback,    	0xFFFFFFFA
.equ reset,         0xFFFFFFFF

.equ NOTE1_SUSTAIN, 80000
.equ NOTE2_SUSTAIN, 120000
.equ NOTE4_SUSTAIN, 90000
.equ NOTE5_SUSTAIN, 150000

.equ NOTE_DELAY, 1000000
.equ  TICKSPERSEC,      1000000000

.equ VOLUME, 0x06000000




#------------------------------------------------------------------------#

.data

COUNTER: .word 0
car_run: .word 1


.text

.global main
main:

/*********************REINIT COUNTER************************/

  #increment COUNTER
  movia r4, COUNTER
  mov r5, r0
  stw r5, 0(r4)

/*********************LOAD TITLE CARD 1************************/

movia r4, TITLE1 		#r14 is the pixel pointer points to the image
call DRAW_IMAGE
movia r4, 200000000
loop2:
	subi r4, r4, 1
	bne r4, r0, loop2

	

	
/*********************LOAD TITLE CARD 2************************/

movia r4, TITLE2 		#r14 is the pixel pointer points to the image
call DRAW_IMAGE




/******************POLL KEY 0 TO BEGIN********************/


PollKey0Second:
  movia r10, ADDR_PUSHBUTTONS
  movi r3, 1
  stwio r3, 12(r10)
  ldwio r3, 0(r10)   # Read in buttons - active high
  beq r3, r0, PollKey0Second






/*********************LOAD INSTRUCTIONS************************/



movia r4, INSTRUCTION     #r14 is the pixel pointer points to the image
call DRAW_IMAGE






/******SMALL DELAY*********/

movia r4, 9000000
loop3:
	subi r4, r4, 1
	bne r4, r0, loop3







/******************POLL KEY 0 TO BEGIN********************/


PollKey0Third:
  movia r10, ADDR_PUSHBUTTONS
  movi r3, 1
  stwio r3, 12(r10)
  ldwio r3, 0(r10)   # Read in buttons - active high
  beq r3, r0, PollKey0Third





/*************AUDIO****************/

audio_intro:



/***************note 1****************/
note1:

    #set note 1 counter
    movia r10, NOTE1_SUSTAIN

    movia r6, 0xff203040	# Audio device base address: DE1-SoC

    movi r8, 48 				# Half period = 48 samples
    movia r4, VOLUME	# Audio sample value
    mov r5, r8

WaitForWriteSpace1:

	#check counter
    beq r10, r0, DelayInit1
    subi r10, r10, 1

	#poll to load note1 to audio fifo
    ldwio r2, 4(r6)
    andhi r3, r2, 0xff00
    beq r3, r0, WaitForWriteSpace1
    andhi r3, r2, 0xff
    beq r3, r0, WaitForWriteSpace1

WriteTwoSamples1:
    stwio r4, 8(r6)
    stwio r4, 12(r6)
    subi r5, r5, 1
    bne r5, r0, WaitForWriteSpace1


HalfPeriodInvertWaveform1:
    mov r5, r8
    sub r4, r0, r4				# 32-bit signed samples: Negate.
	br WaitForWriteSpace1


/******DELAY 1******/
DelayInit1:
	movia r10, NOTE_DELAY

DelayLoop1:
    subi r10, r10, 1
    bne r10, r0, DelayLoop1




/***************note 2****************/
note2:

    #set note 2 counter
    movia r10, NOTE2_SUSTAIN

    movia r6, 0xff203040	# Audio device base address: DE1-SoC

    movi r8, 48 				# Half period = 48 samples
    movia r4, VOLUME	# Audio sample value
    mov r5, r8

WaitForWriteSpace2:

	#check counter
    beq r10, r0, note5
    subi r10, r10, 1

	#poll to load note3 to audio fifo
    ldwio r2, 4(r6)
    andhi r3, r2, 0xff00
    beq r3, r0, WaitForWriteSpace2
    andhi r3, r2, 0xff
    beq r3, r0, WaitForWriteSpace2

WriteTwoSamples2:
    stwio r4, 8(r6)
    stwio r4, 12(r6)
    subi r5, r5, 1
    bne r5, r0, WaitForWriteSpace2


HalfPeriodInvertWaveform2:
    mov r5, r8
    sub r4, r0, r4				# 32-bit signed samples: Negate.
	br WaitForWriteSpace2



/***************note 5****************/
note5:

    #set note 5 counter
    movia r10, NOTE5_SUSTAIN

    movia r6, 0xff203040	# Audio device base address: DE1-SoC

    movi r8, 35 				# Half period = 48 samples
    movia r4, VOLUME	# Audio sample value
    mov r5, r8

WaitForWriteSpace5:

	#check counter
    beq r10, r0, EndNoteSequence
    subi r10, r10, 1

	#poll to load note1 to audio fifo
    ldwio r2, 4(r6)
    andhi r3, r2, 0xff00
    beq r3, r0, WaitForWriteSpace5
    andhi r3, r2, 0xff
    beq r3, r0, WaitForWriteSpace5

WriteTwoSamples5:
    stwio r4, 8(r6)
    stwio r4, 12(r6)
    subi r5, r5, 1
    bne r5, r0, WaitForWriteSpace5


HalfPeriodInvertWaveform5:
    mov r5, r8
    sub r4, r0, r4				# 32-bit signed samples: Negate.
	br WaitForWriteSpace5


EndNoteSequence:



  
  
  



/*********************LOAD INSTRUCTION CARD************************/











/************** DEBUG SEG ENABLE ******************/

  movia r2, ADDR_7SEG1
  movia r3, 0x00000006   # bits 0000110 will activate segments 1 and 2
  stwio r3,0(r2)        # Write to 7-seg display
  movia r2,ADDR_7SEG2
  stwio r0, 0(r2)

/*********ENABLE LIGHT SENSOR 3 STATE MODE************/


   movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
   movia  r9, 0x07f557ff       # set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs
   stwio  r9, 4(r8)

# load sensor3 threshold value 5 and enable sensor3

   movia  r9,  0xfa3effff       # set motors off enable threshold load sensor 3 ffff 1010
   stwio  r9,  0(r8)            # store value into threshold register

# disable threshold register and enable state mode

   movia  r9,  0xfa5fffff      # keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)

# enable interrupts

    movia  r12, 0x40000000       # enable interrupts on sensor 3
    stwio  r12, 8(r8)

    movia  r8, ADDR_JP2_IRQ    # enable interrupt for GPIO JP2 (IRQ12)
    wrctl  ctl3, r8

    movia  r8, 1
    wrctl  ctl0, r8            # enable global interrupts
	

	

/********************BEGIN TIMED MOTION MOVEMENT************************/
	
	
	
initClock:	
   movia r7, 0xFF202000                   # r7 contains the base address for the timer 
   
   
   #reset
   stwio r0, 0(r7)
   
   
   addi  r2, r0, %lo(TICKSPERSEC)
   stwio r2, 8(r7)  
   addi  r2, r0, %hi(TICKSPERSEC)   
   stwio r2, 12(r7)

   movui r2, 4
   stwio r2, 4(r7)                          # Start the timer without continuing or interrupts 
	

	
#poll clock
	movi r15, 0    #enable forward
pollClock:	
    movia r7, 0xFF202000   
	ldwio r2, 0(r7)
	movui r3, 1
	and r2, r3, r2
	bne r2, r0, finalStop

	
#----------motor motion part--------------------#	

NEXTMOVE:
	movi r17, 0
	beq  r15, r17, FORWARD
	movui r17, 1
	beq  r15, r17, STOP


#motor 0 moves forward
FORWARD:
	movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
	movia r9, gostraight
	stwio r9, 0(r8)
	movia r10, 490000
    movi r15, 1
	bne r10, zero, DELAY#just let the motor move for a small period

STOP:
	movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
	movia r9, motorOff
	stwio r9, 0(r8)
	movia r10, 20000000
	movi r15, 0
	bne r10, zero, DELAY#just let the motor move for a small period

#motor next move logic


DELAY:
	subi r10, r10, 1
	bne  r10, zero, DELAY
	br   pollClock

finalStop:
#	movia r4, car_run
#	ldw r5, 0(r4)
#	movi r6, 0
#	stw r6, 0(r4)
#	bne r5, r0, initClock
	
    movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
    movia r9, motorOff
	stwio r9, 0(r8)



	
	
	
/************** LOAD PLANT ******************/	
	
	
CallCaseStatement:	
    call herb_select
	




/******SMALL DELAY*********/

movia r4, 900000
loop8:
	subi r4, r4, 1
	bne r4, r0, loop8




/******GO BACKWARDS**********/

/********************BEGIN TIMED MOTION MOVEMENT************************/
	
	
	
initClock2:	
   movia r7, 0xFF202000                   # r7 contains the base address for the timer 
   
   
   #reset
   stwio r0, 0(r7)
   
   
   addi  r2, r0, %lo(TICKSPERSEC)
   stwio r2, 8(r7)  
   addi  r2, r0, %hi(TICKSPERSEC)   
   stwio r2, 12(r7)

   movui r2, 4
   stwio r2, 4(r7)                          # Start the timer without continuing or interrupts 
	

	
#poll clock
	movi r15, 0    #enable forward
pollClock2:	
    movia r7, 0xFF202000   
	ldwio r2, 0(r7)
	movui r3, 1
	and r2, r3, r2
	bne r2, r0, finalStop2

	
#----------motor motion part--------------------#	

NEXTMOVE2:
	movi r17, 0
	beq  r15, r17, FORWARD2
	movui r17, 1
	beq  r15, r17, STOP2


#motor 0 moves forward
FORWARD2:
	movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
	movia r9, goback
	stwio r9, 0(r8)
	movia r10, 490000
    movi r15, 1
	bne r10, zero, DELAY2#just let the motor move for a small period

STOP2:
	movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
	movia r9, motorOff
	stwio r9, 0(r8)
	movia r10, 20000000
	movi r15, 0
	bne r10, zero, DELAY2#just let the motor move for a small period

#motor next move logic


DELAY2:
	subi r10, r10, 1
	bne  r10, zero, DELAY2
	br   pollClock2

finalStop2:
#	movia r4, car_run
#	ldw r5, 0(r4)
#	movi r6, 0
#	stw r6, 0(r4)
#	bne r5, r0, initClock2
	
    movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
    movia r9, motorOff
	stwio r9, 0(r8)




/******************POLL KEY 0 TO BEGIN********************/


PollRestart:
  movia r10, ADDR_PUSHBUTTONS
  movi r3, 1
  stwio r3, 12(r10)
  ldwio r3, 0(r10)   # Read in buttons - active high
  beq r3, r0, PollRestart
  br main









/******************ISR FOR LIGHT SENSOR*******************/
.section .exceptions, "ax"
ISR:

  movia r2, ADDR_7SEG1
  movia r3, 0x0000007   # bits 0000110 will activate segments 1 and 2
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

  #increment COUNTER
  movia r4, COUNTER
  movia r23, COUNTER
  ldw r5, 0(r4)
  addi r5, r5, 1
  stw r5, 0(r4)
 

EXIT:



  movia et, ADDR_JP2_EDGE
  movia r5, 0xffffffff
  stwio r5, 0(et)


	subi ea, ea, 4#restore the address of next instruction
	eret
	


DRAW_IMAGE: 
	subi sp, sp, 28
	stw r19, 0(sp)
	stw r20, 4(sp)
	stw r13, 8(sp)
	stw r16, 12(sp)
	stw r17, 16(sp)
	stw r18, 20(sp)
	stw ra, 24(sp)
	
    movia r5, ADDR_VGA 
	mov r6, r4
	mov r7, r0  				#r10 is initial x=0 
	movui et, 240			#r11 is initial y=239
	movui r19, 320		#r12 max limit for x
	movia r20, 0xffffffff
#draw the pixel
draw_loop:
	ldh r13,0(r6) 				#r13 stores pixel information
	muli r16,r7,2 				#r16 = x*2
	muli r17,et,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r5				#add offset to address
	beq r13, r20, SKIP
	sthio r13,0(r18) 			#draw the pixel

SKIP:	addi r6,r6,2   			#increase pixel pointer
	addi r7,r7,1   			#increase x
	blt r7,r19,draw_loop 	#if x < 320, keep drawing 

	mov r7,r0   				#reset x
	subi et, et, 1	 			#decrease y
	bge et,r0,draw_loop 	#if y > 0, keep drawing
	
	ldw r19, 0(sp)
	ldw r20, 4(sp)
	ldw r13, 8(sp)
	ldw r16, 12(sp)
	ldw r17, 16(sp)
	ldw r18, 20(sp)
	ldw ra, 24(sp)
	addi sp, sp, 28
ret
	
	
	

