/*The timer will run for a 10 seconds, then raise a flag when it clocks out,
  upon which the timer is reset and returns to main program*/

    .equ  TIMER0_BASE,      0xFF202000
    .equ  TIMER0_STATUS,    0
    .equ  TIMER0_CONTROL,   4
    .equ  TIMER0_PERIODL,   8
    .equ  TIMER0_PERIODH,   12
    .equ  TIMER0_SNAPL,     16
    .equ  TIMER0_SNAPH,     20

.text
timer:
     #obtain timer base
     movia r7, TIMER0_BASE

     # Set the period to be 1000 clock cycles
     movui r2, 1000
     stwio r2, TIMER0_PERIODL(r7)
     stwio r0, TIMER0_PERIODH(r7)

     #enable timer start and enables timeout interrupt
     movui r2, 5
     stwio r2, TIMER0_CONTROL(r7)                          # Start the timer

     ret
