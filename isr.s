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

isr:
  # PROLOGUE


  # EPILOGUE
