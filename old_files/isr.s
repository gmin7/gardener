.section .exceptions, “ax”
.align 2

/*
Pseudocode:
  -determine interrupt
    -if timer, end program and call herb_database
    -else, increment counter
  -clear interrupt
  -return
*/

/*
    r7- pointer to devices
    ea- return reg??????
    r5- temp stores ctl1
*/

isr:

prologue:
  # PROLOGUE
  subi sp, sp, 12
  stwio ea, 0(sp)
  ###
  rdctl r5, ctl1                # save ctl1
  stwio r5, 4(sp)
  ###
  stwio r7, 8(sp)

  # determine which device called interrupt
  # to do so: check threshold first, then timeout (since threshold more likely to occur
  #during a single execution of program)

determine_device:

check_light_sensor:
  # first check 
  .equ ADDR_JP2_IRQ, 0x1000            # IRQ line for for GPIO JP2 (bit 12)
  .equ ADDR_JP2_Edge, 0xFF20007C       # address Edge Capture register GPIO JP2

  rdctl et, ctl4                    # check the interrupt pending register (ctl4)
  movia r2, ADDR_JP2_IRQ
  and	r2, r2, et                    # check if the pending interrupt is from GPIO JP2
  beq   r2, r0, exit_handler

  movia r2, ADDR_JP2_EDGE           # check edge capture register from GPIO JP2
  ldwio et, 0(r2)
  andhi r2, et, 0x2000              # mask bit 29 (sensor 2)
  beq   r2, r0, exit_handler        # exit if sensor 2 did not interrupt


check_timer:
  #next check timer bit
  movia r7, TIMER0_BASE  #get pointer to timer
  ldwio       r7, TIMER0_STATUS(r7)   # check if the TO bit of the status register is 1
  andi        r7, r9, 0x1
  bne         r7, r0, onesec

epilogue:
  # EPILOGUE
  ldwio ea, 0(sp)
  ###
  ldwio r5, 4(sp)              # restore ctl1
  wrctl ctl1, r5
  ###
  ldwio r7 4(sp)
  addi sp, sp 8


exit_handler:
  eret
    # return from interrupt
    # this restores ctl0 to it’s previous state that was saved in ctl1
    # and does pc = ea
