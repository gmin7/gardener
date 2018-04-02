#---------------------initial equ-----------------------#
.equ JP1, 		 	0xFF200060
.equ TIMER,   		0xFF202000
.equ directionSet,  0x07F557FF

.equ motorForward,  0xFFFFFFFC
.equ motorBackward, 0xFFFFFFFE
.equ motorOff,   	0xFFFFFFFF

.equ senser0On, 	0xFFFFFBFF
.equ sensor1On,		0xFFFFEFFF



.equ ADDR_JP2, 0xFF200070      # address GPIO JP2

 movia  r8, ADDR_JP2

 movia  r9, 0x07f557ff       # set direction for motors to all output
 stwio  r9, 4(r8)

 movia	 r9, 0xfffffffc       # motor0 enabled (bit0=0), direction set to forward (bit1=0)
 stwio	 r9, 0(r8)
