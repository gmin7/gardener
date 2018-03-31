/*Taken and modified from http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/dev_newlegocontroller2.html*/
/*"Assembly Example: Assuming Lego controller is plugged into JP2, Trigger interrupt when the
Sensor3 value becomes greater than a threshold value of 0x5 (using state mode)"*/

/*********DECLARE CONSTANTS***********/

.equ ADDR_JP2, 0xFF200070      # address GPIO JP2
.equ ADDR_JP2_IRQ, 0x1000      # IRQ line for GPIO JP2 (IRQ12)


light_sensor_rs:
   movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
   movia  r9, 0x07f557ff       # set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs
   stwio  r9, 4(r8)

# load sensor3 threshold value 5 and enable sensor3

   movia  r9,  0xfabeffff       # set motors off enable threshold load sensor 3
   stwio  r9,  0(r8)            # store value into threshold register

# disable threshold register and enable state mode

   movia  r9,  0xfadfffff      # keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)

# enable interrupts

    movia  r12, 0x40000000       # enable interrupts on sensor 3
    stwio  r12, 8(r8)

    movia  r8, ADDR_JP2_IRQ    # enable interrupt for GPIO JP2 (IRQ12)
    wrctl  ctl3, r8

    movia  r8, 1
    wrctl  ctl0, r8            # enable global interrupts

    LOOP:
    br LOOP
