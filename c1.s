;;; -*- mode: asm; -*-
;;; -*- asm-comment-char: ?\; -*-
;;; vim: syntax=asm68k ts=8 sw=8
;;;
;;; *** Copperbars ***
;;;
;;; Copperbars-1 example from http://vikke.net/

DMACONR		EQU		$dff002
ADKCONR		EQU		$dff010
INTENAR		EQU		$dff01c
INTREQR		EQU		$dff01e

DMACON		EQU		$dff096
ADKCON		EQU		$dff09e
INTENA		EQU		$dff09a
INTREQ		EQU		$dff09c

; Optimizations could easily be made to the small/tight loops in the code by using incremental addressing (An)+ or decremental addressing -(An) and REPT <n> / ERPT

init:
; store hardware registers, store view- and copperaddresses, load blank view, wait 2x for top of frame, own blitter, wait for blitter AND finally forbid multitasking!
; all this just to be able to exit gracely

	; store data in hardwareregisters ORed with $8000 (bit 15 is a write-set bit when values are written back into the system)
	move.w	DMACONR,d0
	or.w #$8000,d0
	move.w d0,olddmareq
	move.w	INTENAR,d0
	or.w #$8000,d0
	move.w d0,oldintena
	move.w	INTREQR,d0
	or.w #$8000,d0
	move.w d0,oldintreq
	move.w	ADKCONR,d0
	or.w #$8000,d0
	move.w d0,oldadkcon

	move.l	$4,a6
	move.l	#gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)	; oldOpenLibrary offset=-408 ... would OpenLibrary be better? offset=-552
	move.l	d0,gfxbase
	move.l 	d0,a6
	move.l 	34(a6),oldview
	move.l 	38(a6),oldcopper

	move.l #0,a1
	jsr -222(a6)	; LoadView
	jsr -270(a6)	; WaitTOF
	jsr -270(a6)	; WaitTOF
	jsr -456(a6)	; OwnBlitter
	jsr -228(a6)	; WaitBlit
	move.l	$4,a6
	jsr -132(a6)	; Forbid

; end exit gracely preparations!

	; clear Bitplanes from garbage - very slow routine! should be done with the Blitter, or unrolled loop
	move.w #320/8*200/4,d0 	; d0 is a counter for number of longwords to get cleared
	move.l #bpl0,a0 	; bpl0 => a0
	move.l #bpl1,a1 	; bpl1 => a1
	screen_clear:
		move.l #0,(a0)+	; #0 => (a0), and increment a0 to next longword (a0=a0+4)
		move.l #0,(a1)+	; #0 => (a1), and increment a1 to next longword (a1=a1+4)
		subq.w #1,d0
		bne screen_clear

	; copy bitmap to bitplanes
	move.w #320/8*65/4,d0
	move.l #bpl0,a0 	; bpl0 => a0
	move.l #bpl1,a1 	; bpl1 => a1
	move.l #img_amigavikke,a6
	move.l #320/8*130,d1
	add.l d1,a0
	add.l d1,a1
	copy_img:
		move.l 320/8*65(a6),(a1)+	; bpl1
		move.l (a6)+,(a0)+			; bpl0
		subq.w #1,d0
		bne copy_img

; setup displayhardware to show a 320x200px 2 bitplanes playfield, with zero horizontal scroll and zero modulos
	move.w	#$2200,$dff100				; 2 bitplane lowres
	move.w	#$0000,$dff102				; horizontal scroll 0
	move.w	#$0000,$dff108				; odd modulo 0
	move.w	#$0000,$dff10a				; even modulo 0
	move.w	#$2c81,$dff08e				; DIWSTRT - topleft corner (2c81)
	move.w	#$f4d1,$dff090				; DIVSTOP - bottomright corner (f4d1)
	move.w	#$0038,$dff092				; DDFSTRT - max overscan $0018 ; standard 0038 & 00d0
	move.w	#$00d0,$dff094				; DDFSTOP - max overscan $00d8 ; max overscan: 368x283px in PAL
	move.w 	#%1000010111000000,DMACON	; DMA set ON
	move.w 	#%0000000000111111,DMACON	; DMA set OFF
	move.w 	#%1100000000000000,INTENA	; IRQ set ON
	move.w 	#%0011111111111111,INTENA	; IRQ set OFF


mainloop:
; increase framecounter by 1
	move.l frame,d0
	addq.l #1,d0
	move.l d0,frame

; change effect settings according to framecounter
	; normal or "additive" bars
	move.l d0,d1
	and.l #$ff,d1 			; 255/50 ~ 5sec => every 5 sec change between modes
	bne .10
	eori.b #1,cbar_mode
	.10:
	; anglespeed
	move.l d0,d1
	and.l #$1ff,d1 			; 511/50 ~ 10sec => every 10 sec speed changes +1, in interval [2,5]
	bne .20
	move.b anglespeed,d2
	add.b #1,d2
	cmp.b #6,d2
	bne .21
	moveq #2,d2
	.21:
	move.b d2,anglespeed
	.20:
	; startline
	move.l d0,d1
	and.l #$ff,d1 			; change angle each frame, but only with 8 LSB!
	move.l #sin255_60,a0
	move.b (a0,d1),d2
	move.w cbar_start_default,d1
	add.w d2,d1
	move.w d1,cbar_start

; make copperlist
; doubblebuffering of copperlists, defined at copper1 and copper2, chosen by LSB in framecounter
; copper (and a6) will hold the address to the copperlist we will write to (not the one currently in use)
	and.l #1,d0
	bne usecopper2
	move.l #copper1,a6
	bra usecopper1
	usecopper2:
	move.l #copper2,a6
	usecopper1:
	move.l a6,copper

	; bitplane 0
	move.l #bpl0,d0
	move.w #$00e2,(a6)+	; LO-bits of start of bitplane
	move.w d0,(a6)+		; go into $dff0e2
	swap d0
	move.w #$00e0,(a6)+	; HI-bits of start of bitplane
	move.w d0,(a6)+		; go into $dff0e0

	; bitplane 1
	move.l #bpl1,d0
	move.w #$00e6,(a6)+	; LO-bits of start of bitplane
	move.w d0,(a6)+		; go into $dff0e6
	swap d0
	move.w #$00e4,(a6)+	; HI-bits of start of bitplane
	move.w d0,(a6)+		; go into $dff0e4

	; colors
	move.l #$01800000,(a6)+	; color 0: $000 into $dff180
	move.l #$01820000,(a6)+	; color 1: $000 into $dff182
	move.l #$01840f00,(a6)+	; color 2: $f00 into $dff184
	move.l #$01860fff,(a6)+	; color 3: $fff into $dff186

	; horizontal scroll
	move.l #$01020000,(a6)+	; 0 for both odd and even numbered bpl (rightmost 2 zeros)

	; change angles according to anglespeed
	move.b anglespeed,d1
	move.l #sin255_60,a0
	move.l #cos255,a1
	move.l #cbar_a,a2
	move.l #cbar_y,a3
	move.l #cbar_z,a4
	move.b #4,d2
	loop_copperbars:
		move.b (a2),d3		; angle
		add.b d1,d3			; angle + anglespeed
		move.b (a0,d3),d4 	; y from sintable
		move.b (a1,d3),d5	; z from costable
		move.b d3,(a2)+		; angle
		move.b d4,(a3)+		; y
		move.b d5,(a4)+		; z
		subq.b #1,d2
		bne loop_copperbars

	; get z-value for all bars
	move.l #0,copperbars_z	; 0 to z for all 3 bars
	move.l #cbar_z,a2
	move.b (a2)+,d1
	move.b (a2)+,d2
	move.b (a2)+,d3
	moveq #0,d4		; z red
	moveq #0,d5 	; z grn
	moveq #0,d6 	; z blu
	; compare z-values
	cmp.b d1,d2
	bcc z1
	addq #1,d5
	bra z1e
	z1:
	addq #1,d4
	z1e:
	cmp.b d1,d3
	bcc z2
	addq #1,d6
	bra z2e
	z2:
	addq #1,d4
	z2e:
	cmp.b d2,d3
	bcc z3
	addq #1,d6
	bra z3e
	z3:
	addq #1,d5
	z3e:
	move.l #cbar_z,a2
	move.b d4,(a2)+		; red
	move.b d5,(a2)+		; grn
	move.b d6,(a2)+		; blu

	; empty copperline data - needed because of "additive"-mode!
	moveq #0,d3
	move.l #copperlines1,a3
	move.l #90,d2 				; max height of copperbars: 60 + 30
	loop_empty_copperlines1:
		move.w d3,(a3)+
		subq #1,d2
		bne loop_empty_copperlines1

	move.l #0,d0 		; d0 is the loop index
	loop_rasterlines:
		move.l #0,d3	; no bar
		cmp.b d0,d6
		bne zz1
		move.l #3,d3	; blu
		zz1:
		cmp.b d0,d5
		bne zz2
		move.l #2,d3	; grn
		zz2:
		cmp.b d0,d4
		bne zz3
		move.l #1,d3	; red
		zz3:
		cmp.b #0,d3
		beq copperline_nothing
		; now d3 contains the number of the copperbar to be drawn (0 = dummy bar)
		move.l #cbar_y,a2
		move.l #0,d1
		move.b (a2,d3),d1 	; y start
		lsl.b #1,d1 		; *2 to get from b to w addressing in copperlines1
		move.l #copperlines1,a3 	; copperlines1 is just an array for storing color info for each line
		add.l d1,a3
		lsl.b #6,d3			; *64 to get from b to w addressing in cbars and each bar is 32 words long (*64 = *2*32)
		move.l #cbars,a2
		add.l d3,a2
		move.l #30,d7 		; d7 is the loop index, each bar is 30 lines high (+2 lines that aren't drawn, to get 32 = 2^5)
		loop_copperline_render:
			cmp.b #0,cbar_mode
			bne cbar_additive
			move.w (a2)+,(a3)+ 	; if normal mode: just write over old data
			bra cbar_normal
			cbar_additive:
			move.w (a2)+,d1 	; if additive mode: old OR new
			or.w d1,(a3)+ 		; this isn't the same as old + new, but it works well enough in binary
			cbar_normal:
			subq #1,d7
			bne loop_copperline_render
		copperline_nothing:
		addq #1,d0
		cmp #3,d0
		bcs loop_rasterlines

; let's finally "draw" the copperbars into the copperlist, so that the copper can "draw" them onto the display
	move.l #copperlines1,a2
	move.w cbar_start,d3	; startline
	move.l #0,d7 			; d7 is the loop index, going from 0 to 89 because the WAIT instructions of the copper have to be in the right order to work!
	loop_rasterlines_copper:
		move.w d3,d4
		add.w d7,d4
		cmp.w #256,d4 				; PAL needs a trick to to handle more than 256 lines in overscan
		bne no_PAL_fix
		move.l #$ffdffffe,(a6)+ 		; we wait for the last beamposition on line 255 that is possible for the copper to handle, after that line 0 = line 256 etc
		no_PAL_fix:
		; copper WAIT-instruction generation
		move.w d7,d4 		; d4=d7
		add.w d3,d4 		; d4=d7+d3 (d7+startline)
		lsl.w #8,d4 		; d4=(d7+startline)*256
		add.w #$07,d4 		; d4=(d7+startline)<<256+07
		move.w d4,(a6)+ 	; Wait - first line, ex: $6407
		move.w #$fffe,(a6)+ 	; Mask
		; copper MOVE-instruction generation
		move.w #$0180,(a6)+ 	; Color0: $0180
		move.w (a2)+,(a6)+ 	; Colordata
		;
		addq #1,d7
		cmp #90,d7
		bcs loop_rasterlines_copper


	; set colors to default on next line - for a "clean" setup on next screen
	; d7 = 90 at this point, so copying the same code as above will put the next WAIT and MOVE instructions for the next line
	move.w d7,d4 			; d4=d7
	add.w d3,d4 			; d4=d7+d3 (d7+startline)
	lsl.w #8,d4 			; d4=(d7+startline)<<8
	add.w #$07,d4 			; d4=(d7+startline)<<8+07
	move.w d4,(a6)+ 		; Wait - first line ex: $6407
	move.w #$fffe,(a6)+ 		; Mask
	move.l #$01800000,(a6)+ 	; color 0

	; end of copperlist (copperlist ALWAYS ends with WAIT $fffffffe)
	move.l #$fffffffe,(a6)+ 	; end copperlist


	; if mousebutton/joystick 1  or 2 pressed then exit
	btst.b #6,$bfe001
	beq exit
	btst.b #7,$bfe001
	beq exit

; display is ready, or atleast we have done everything we wanted and the copper continues on its own
; we have to wait for Vertical Blanking before making the next frame

waitVB:
	move.l $dff004,d0
	and.l #$1ff00,d0
	cmp.l #300<<8,d0
	bne waitVB

	; use next copperlist - as we are using doubblebuffering on copperlists we now take the new one into use
	move.l copper,d0
	move.l d0,$dff080
	bra mainloop

exit:
; exit gracely - reverse everything done in init
	move.w #$7fff,DMACON
	move.w	olddmareq,DMACON
	move.w #$7fff,INTENA
	move.w	oldintena,INTENA
	move.w #$7fff,INTREQ
	move.w	oldintreq,INTREQ
	move.w #$7fff,ADKCON
	move.w	oldadkcon,ADKCON

	move.l	oldcopper,$dff080
	move.l 	gfxbase,a6
	move.l 	oldview,a1
	jsr -222(a6)	; LoadView
	jsr -270(a6)	; WaitTOF
	jsr -270(a6)	; WaitTOF
	jsr -228(a6)	; WaitBlit
	jsr -462(a6)	; DisownBlitter
	move.l	$4,a6
	jsr -138(a6)	; Permit

	; end program
	rts



; *******************************************************************************
; *******************************************************************************
; DATA
; *******************************************************************************
; *******************************************************************************


; storage for 32-bit addresses and data
	CNOP 0,4
oldview:	dc.l 0
oldcopper:	dc.l 0
gfxbase:	dc.l 0
frame:		dc.l 0
copper:		dc.l 0

; storage for 16-bit data
	CNOP 0,4
olddmareq:	dc.w 0
oldintreq:	dc.w 0
oldintena:	dc.w 0
oldadkcon:	dc.w 0

	CNOP 0,4
; storage for 8-bit data and text
gfxname:		dc.b 'graphics.library',0

	CNOP 0,4
cbar_start_default: dc.w 60 	; startline default
cbar_start:			dc.w 0		; calculated startline
cbars:							; copperbar 30px high + 2 word for 32 word alignment in code
	blk.w 32,0 					; dummybar = no bar just backgroundcolor				; blk - 32w
	dc.w $100,$200,$300,$400,$500,$600,$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00		; red - 32w
	dc.w $f00,$e00,$d00,$c00,$b00,$a00,$900,$800,$700,$600,$500,$400,$300,$200,$100,0,0
	dc.w $010,$020,$030,$040,$050,$060,$070,$080,$090,$0a0,$0b0,$0c0,$0d0,$0e0,$0f0 	; grn - 32w
	dc.w $0f0,$0e0,$0d0,$0c0,$0b0,$0a0,$090,$080,$070,$060,$050,$040,$030,$020,$010,0,0
	dc.w $001,$002,$003,$004,$005,$006,$007,$008,$009,$00a,$00b,$00c,$00d,$00e,$00f 	; blu - 32w
	dc.w $00f,$00e,$00d,$00c,$00b,$00a,$009,$008,$007,$006,$005,$004,$003,$002,$001,0,0

	CNOP 0,4
angle:			dc.b 0
	CNOP 0,4
anglespeed:		dc.b 2
	CNOP 0,4
sin255_60:	dc.b 30,31,31,32,33,34,34,35,36,37,37,38,39,39,40,41,42,42,43,44,44,45,45,46,47,47,48,49,49,50,50,51,51,52,52,53,53,54,54,55,55,55,56,56,57,57,57,57,58,58,58,59,59,59,59,59,59,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,59,59,59,59,59,58,58,58,58,57,57,57,56,56,56,55,55,54,54,53,53,53,52,52,51,50,50,49,49,48,48,47,46,46,45,45,44,43,43,42,41,40,40,39,38,38,37,36,36,35,34,33,33,32,31,30,30,29,28,27,27,26,25,24,24,23,22,22,21,20,20,19,18,17,17,16,15,15,14,14,13,12,12,11,11,10,10,9,8,8,7,7,7,6,6,5,5,4,4,4,3,3,3,2,2,2,2,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,3,3,3,3,4,4,5,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,13,13,14,15,15,16,16,17,18,18,19,20,21,21,22,23,23,24,25,26,26,27,28,29,29,30
	CNOP 0,4
cos255:		dc.b 255,255,255,255,254,254,254,253,253,252,251,250,249,249,248,246,245,244,243,241,240,238,237,235,233,232,230,228,226,224,222,220,218,215,213,211,208,206,203,201,198,196,193,190,187,185,182,179,176,173,170,167,164,161,158,155,152,149,146,143,140,137,133,130,127,124,121,118,115,112,109,105,102,99,96,93,90,87,84,81,78,76,73,70,67,65,62,59,57,54,51,49,47,44,42,40,37,35,33,31,29,27,25,23,22,20,18,17,15,14,13,11,10,9,8,7,6,5,4,4,3,3,2,2,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,6,7,8,9,10,11,13,14,15,17,18,20,22,23,25,27,29,31,33,35,37,40,42,44,47,49,51,54,57,59,62,64,67,70,73,76,78,81,84,87,90,93,96,99,102,105,109,112,115,118,121,124,127,130,133,137,140,143,146,149,152,155,158,161,164,167,170,173,176,179,182,185,187,190,193,196,198,201,203,206,208,211,213,215,218,220,222,224,226,228,230,232,233,235,237,238,240,241,243,244,245,246,248,249,249,250,251,252,253,253,254,254,254,255,255,255,255
	CNOP 0,4
cbar_mode:	dc.b 0 			; 0=normal, 1=additive
	CNOP 0,4
cbar_y:	dc.b 0,0,0,0 		; y-position
cbar_z:	dc.b 0,1,2,0 		; z-position (depth, for calculating order of display)
cbar_a:	dc.b 0,85,170,0		; angle - 0 , 85 , 170 = evenly distributed on 255 bitgrad
	CNOP 0,4
copperbars_z:	dc.l 0
copperlines1:	blk.w 1000,0

	Section ChipRAM,Data_c

; bitplanes aligned to 32-bit
	CNOP 0,4
bpl0:	blk.b 320/8*200,0
bpl1:	blk.b 320/8*200,0

; datalists aligned to 32-bit
	CNOP 0,4
copper1:
			dc.l $ffffffe 	; CHIPMEM!
			blk.l 1023,0 	; CHIPMEM!
	CNOP 0,4
copper2:
			dc.l $ffffffe 	; CHIPMEM!
			blk.l 1023,0 	; CHIPMEM!

	CNOP 0,4
img_amigavikke:	incbin "amigavikke.raw"
