/*The timer will run for a 10 seconds, then raise a flag when it clocks out,
  upon which the timer is reset and returns to main program*/

/*
   r7- pointer to TIMER0_BASE
   r9- intermediate
*/

    .equ  TIMER0_BASE,      0xFF202000
    .equ  TIMER0_STATUS,    0
    .equ  TIMER0_CONTROL,   4
    .equ  TIMER0_PERIODL,   8
    .equ  TIMER0_PERIODH,   12
    .equ  TIMER0_SNAPL,     16
    .equ  TIMER0_SNAPH,     20
    .equ  TICKSPERSEC,      1000000000

.text
clock:
     #obtain timer base
     movia r7, TIMER0_BASE

     # Set the period registers to 10^7
      addi  r9, r0, %lo (TICKSPERSEC)
      stwio r9, TIMER0_PERIODL(r7)
      addi  r9, r0, %hi(TICKSPERSEC)
      stwio r9, TIMER0_PERIODH(r7)

     #enable timer start and enables timeout interrupt
     movui r9, 5
     stwio r9, TIMER0_CONTROL(r7)                          # Start the timer

     loop: br loop
