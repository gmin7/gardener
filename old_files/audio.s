audio_intro:

.equ NOTE1_SUSTAIN, 80000
.equ NOTE2_SUSTAIN, 120000
.equ NOTE4_SUSTAIN, 90000
.equ NOTE5_SUSTAIN, 150000

.equ NOTE_DELAY, 1000000

.equ VOLUME, 0x06000000



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
	br WaitForWriteSpace3



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
	ret
