# 320x240, 1024 bytes/row, 2 bytes per pixel: DE1-SoC, DE2, DE2-115
.equ WIDTH, 50
.equ HEIGHT, 50
.equ LOG2_BYTES_PER_ROW, 10
.equ LOG2_BYTES_PER_PIXEL, 1
# 160x120, 256 bytes/row, 1 byte per pixel: DE10-Lite
#.equ WIDTH, 160
#.equ HEIGHT, 120
#.equ LOG2_BYTES_PER_ROW, 8
#.equ LOG2_BYTES_PER_PIXEL, 0
# 128 bytes/row, 1 byte per pixel: DE0
#.equ WIDTH, 80
#.equ HEIGHT, 60
#.equ LOG2_BYTES_PER_ROW, 7
#.equ LOG2_BYTES_PER_PIXEL, 0

.equ PIXBUF, 0x08000000	# Pixel buffer. Same on all boards.
.equ CHARBUF, 0x09000000	# Character buffer. Same on all boards.

.global _start
_start:
	movia sp, 0x800000	# Initial stack pointer

    movia r16, IMAGE  /* image address */

  #sthio r4,1032(r2) /* pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */

Loop:
	mov r4, r16
    call FillImage		# Fill screen with image

    br Loop_forever

Loop_forever:
	br Loop_forever

# r4: image
FillImage:
	subi sp, sp, 16
    stw r16, 0(sp)		# Save some registers
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw ra, 12(sp)

    mov r18, r4

    # Two loops to draw each pixel
    movi r16, WIDTH-1
    1:	movi r17, HEIGHT-1
        2:  mov r4, r16
            mov r5, r17
            mov r6, r18
            call WritePixel		# Draw one pixel
            subi r17, r17, 1
            bge r17, r0, 2b
        subi r16, r16, 1
        bge r16, r0, 1b

    ldw ra, 12(sp)
	ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 16
    ret


# r4: col
# r5: row
# r6: character
WriteChar:
	slli r5, r5, 7
    add r5, r5, r4
    movia r4, CHARBUF
    add r5, r5, r4
    stbio r6, 0(r5)
    ret

# r4: col (x)
# r5: row (y)
# r6: colour value
WritePixel:
	movi r2, LOG2_BYTES_PER_ROW		# log2(bytes per row)
    movi r3, LOG2_BYTES_PER_PIXEL	# log2(bytes per pixel)

    sll r5, r5, r2
    sll r4, r4, r3
    add r5, r5, r4
    movia r4, PIXBUF
    add r5, r5, r4

    bne r3, r0, 1f		# 8bpp or 16bpp?
  	stbio r6, 0(r5)		# Write 8-bit pixel
    ret

1:	sthio r6, 0(r5)		# Write 16-bit pixel
	ret
