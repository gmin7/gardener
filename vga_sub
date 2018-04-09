IMAGE:
	.incbin "p.bmp", 70
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

.global _start
_start:

call draw_image1

LOOP: br LOOP

draw_image1:
	subi sp, sp, 12
	stw r18,0(sp)
	stw r19,4(sp)
	stw r20,8(sp)
    
    
    movia r4, ADDR_VGA 
	movia r5, IMAGE 		#r14 is the pixel pointer points to the image
	mov r6, r5
	mov r7, r0  				#r10 is initial x=0 
	movui et, 100			#r11 is initial y=239
	movui r19, 100		#r12 max limit for x
	movia r20, 0xffffffff
#draw the pixel
draw_win:
	ldh r13,0(r6) 				#r13 stores pixel information
	muli r16,r7,2 				#r16 = x*2
	muli r17,et,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r4				#add offset to address
	beq r13, r20, SKIP
	sthio r13,0(r18) 			#draw the pixel

SKIP:	addi r6,r6,2   			#increase pixel pointer
	addi r7,r7,1   			#increase x
	blt r7,r19,draw_win 	#if x < 320, keep drawing 

	mov r7,r0   				#reset x
	subi et, et, 1	 			#decrease y
	bge et,r0,draw_win 	#if y > 0, keep drawing
    
    
    ldw r18,0(sp)
	ldw r19,4(sp)
	ldw r20,8(sp)
	addi sp,sp,12
    ret
