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
*/

isr:
  # PROLOGUE
  subi sp, sp, XXXXX
  stw ea, 0(sp)
  stw ctl1, 4(sp)
  stw r7, 8(sp)

  # determine which device called interrupt
  # to do so, check threshold first, then timeout (since threshold more likely to occur
  during a single execution of program)

  # first check threshold bit




  #next check timer bit
  movia r7, TIMER0_BASE  #get pointer to timer
  ldwio       r7, TIMER0_STATUS(r7)   # check if the TO bit of the status register is 1
  andi        r7, r9, 0x1
  beq         r7, r0, onesec



  # EPILOGUE
  ldw ea, 0(sp)
  ldw ctl1, 4(sp)
  ldw 8(sp)
