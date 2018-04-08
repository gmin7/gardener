/*Taken and modified from http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/dev_newlegocontroller2.html*/
/*"Assembly Example: Assuming Lego controller is plugged into JP2, Trigger interrupt when the
Sensor3 value becomes greater than a threshold value of 0x5 (using state mode)"*/

/*********DECLARE CONSTANTS***********/

.equ ADDR_JP2, 0xFF200070      # address GPIO JP2
.equ ADDR_JP2_IRQ, 0x1000      # IRQ line for GPIO JP2 (IRQ12)
.equ ADDR_JP2_EDGE, 0xFF20007C      # address Edge Capture register GPIO JP2 


#segs
 .equ ADDR_7SEG1, 0xFF200020
 .equ ADDR_7SEG2, 0xFF200030



.text
.global _start
_start:


/************** SEGS ******************/
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


/******************ISR subroutine section*******************/
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

