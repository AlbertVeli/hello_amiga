;;; *** Example for a simple Copperlist ***
;;;
;;; From Amiga System Programmer's Guide

;; CustomChip-Registers
INTENA = $9A			; Interrupt-Enable-Register (write)
DMACON = $96			; DMA—control register (write)
COLOR00 = $180			; Color palette register 0

;; Copper Registers
COP1LC = $80			; Address of 1. Copper list
COP2LC = $84			; Address of 2. Copper list
COPJMP1 = $88			; Jump to Copper list 1
COPJMP2 = $8a			; Jump to Copper list 2

;; CIA-A Port register A (Mouse key)
CIAAPRA = $BFE001

;; Exec Library Base Offsets
OpenLibrary = -30-522		; LibName,Version/al,d0
Forbid = -30-102
Permit = -30-108
AllocMem = -30-168		; Byte Size, Requirements/d0,d1
FreeMem = -30-180		; Memory Block, Byte Size/al,d0

;; graphics base
StartList = 38

;; other Labels

Execbase = 4
Chip = 2			; request Chip-RAM

;; *** Initialize-program ***

Start:
	move.l	Execbase, a6
	moveq	#CLsize, d0	; Alloc CLsize bytes Chip-RAM
	moveq	#Chip, d1
	jsr	AllocMem(a6)
	move.l	d0, CLaddr	; Address of the RAM-area memory
	beq.s	Ende		; Error! -> End

;; copy Copperlist to Claddr
	lea	CLstart, a0
	move.l	CLaddr, a1
	moveq 	#CLsize-1, d0	; loop value
CLcopy:
	move.b	(a0)+, (a1)+	; copy Copperlist Byte for Byte
	dbf	d0, CLcopy

;; *** Main program ***

	jsr	Forbid(a6)	; Task Switching off
	lea	$dff000, a5	; Base addr -> a5

	move.w	#$03a0, DMACON(a5) ; DMA off
	move.l	CLaddr, COP1LC(a5) ; Copperlist addr -> COP1LC
	clr.w	COPJMP1(a5)	; Load copperlist in pc

;; Switch Copper DMA
	move.w	#$8280, DMACON(a5)

;; wait for left mouse key
Wait:	btst	#6, CIAAPRA	; Bit 6 in CIA-A
	bne.s	Wait		; Loop to Wait until mouse pressed

;;*** End program ***

;; Restore old Copper list
	move.l	#GRname, a1	; Set parameter for OpenLibrary
	clr.l	d0
	jsr	OpenLibrary(a6)	; Open Graphics Library
	move.l	d0, a4		; Address of GraphicsBase to a4
	move.l	StartList(a4), COP1LC(a5)
	clr.w	COPJMP1(a5)
	move.w	#$83e0, DMACON(a5) ; all JMA on
	jsr	Permit(a6)	   ; Task-Switching on

;; Free allocated memory
	move.l	CLaddr, a1	; Set parameter for FreeMem
	moveq	#CLsize, d0
	jsr	FreeMem(a6)

Ende:
	clr.l	d0		; error flag erased
	rts			; end program

;; Variables
CLaddr:	dc.l 0

;; Constants
GRname:	dc.b "graphics.library", 0

align				; Put next label on aligned address

;; Copperlist (German Flag)

CLstart:
	dc.w COLOR00, $0000	; Background color black
	dc.w $640f, $fffe	; On line 100 change to
	dc.w COLOR00, $0f00	; Red. Switch
	dc.w $be0f, $fffe	; Line 190 to
	dc.w COLOR00, $0fb0	; Gold
	dc.w $ffff, $fffe	; Impossible Position:
				; End of Copperlist
CLend:

CLsize = CLend - CLstart

end
