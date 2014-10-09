;;; -*- mode: asm; -*-
;;; -*- asm-comment-char: ?\; -*-
;;;
;;; *** Dual-Playfield & Scroll Demo ***
;;;
;;; From Amiga System Programmer's Guide, page 117-121

;; CustomChip-Registers
INTENA = $9A			; Interrupt-Enable-Register (write)
INTREQR = $1e			; Interrupt-Request-Register (read)
DMACON = $96			; DMA-control register (write)
COLOR00 = $180			; Color palette register 0
VPOSR = $4			; half line position (read)

;; Copper Registers
COP1LC = $80			; Address of 1. Copper list
COP2LC = $84			; Address of 2. Copper list
COPJMP1 = $88			; Jump to Copper list 1
COPJMP2 = $8a			; Jump to Copper list 2

;; Bitplane Registers
BPLCON0 = $100			; Bitplane control register 0
BPLCON1 = $102			; 1 (Scroll value)
BPLCON2 = $104			; 2 (Sprite<>Playfie1d Priority)
BPL1PTH = $0E0			; Pointer to l. Bitplane
BPL1PTL = $0E2			;
BPL1MOD = $108			; Modulo-Value for odd Bit-Planes
BPL2MOD = $10A			; Module-value for even Bit-Planes
DIWSTRT = $08E			; Start of screen windows
DIWSTOP = $090			; End of screen windows
DDFSTRT = $092			; Bit-Plane DMA Start
DDFSTOP = $094			; Bit-Plane DMA Stop

;; CIA-A Port register A (Mouse key)
CIAAPRA = $bfe001

;; Exec Library Base Offsets
OpenLibrary = -30-522		; LibName,Version/al,d0
Forbid = -30-102
Permit = -30-108
AllocMem = -30-168		; Byte Size, Requirements/d0,d1
FreeMem = -30-180		; Memory Block, Byte Size/al,d0

;; graphics base
StartList = 38

;; Misc Labels
Execbase = 4
Planesize = 52*345		; Size of the Bitplane
Planewidth = 52
CLsize = 5*4			; The Copperlist contains 5 commands
Chip = 2			; request Chip-RAM
Clear = Chip+$10000		; clear previous Chip-RAM

;; *** Pre-program ***

Start:
;; Alloc memory for Bitplanes
	move.l	Execbase, a6
	move.l	#Planesize*2, d0 ; memory size of the Planes
	move.l	#Clear, d1
	jsr	AllocMem(a6)
	move.l	d0, Planeaddr
	beq	End

;; Alloc memory for the Copperlist
	moveq	#CLsize, d0
	moveq	#Chip, d1
	jsr AllocMem(a6)
	move.l	d0, CLaddr
	beq	FreePlane	; Error! -> Free memory for the Planes
				; and quit

;; Build Copperlist
	moveq	#1, d4		; two Bitplanes
	move.l	d0, a0
	move.l	Planeaddr, d1
	move.w	#BPL1PTH, d3
MakeCL:
	move.w	d3, (a0)+
	addq.w	#2, d3
	swap	d1
	move.w	d1, (a0)+
	move.w	d3, (a0)+
	addq.w	#2, d3
	swap	d1
	move.w	d1, (a0)+
	add.l	#Planesize, d1	; Address of the next Plane
	dbf	d4, MakeCL
	move.l	#$fffffffe, (a0) ; End of the Copperlist

;; *** Main program ***

;; DMA and Task switching off
	jsr	Forbid(a6)
	lea	$dff000, a5
	move.w	#$01e0, DMACON(a5)

;; Copper initialization
	move.l	CLaddr, COP1LC(a5)	; Copperlist addr -> COP1LC
	clr.w	COPJMP1(a5)		; Load copperlist in pc

;; Playfield initialization
	;; Colors in original listing were:
	;; Black (0000), Red (0f00) and Blue (000f)
	move.w	#$0000, COLOR00(a5)	; Bg color
	move.w	#$0094, COLOR00+2(a5)	; Plane 1 color
	move.w	#$0fff, COLOR00+18(a5)	; Plane 2 color
	move.w	#$1a64, DIWSTRT(a5)	; 26,100
	move.w	#$39d1, DIWSTOP(a5)	; 313,465
	move.w	#$0020, DDFSTRT(a5)	; read one extra word
	move.w	#$00d8, DDFSTOP(a5)
	move.w	#%0010011000000000, BPLCON0(a5) ; Dual-Playfield
	clr.w	BPLCON1(a5)			; and scroll to start on 0
	clr.w	BPLCON2(a5)			; Playfield 1 or Playfield 2
	move.w	#4, BPL1MOD(a5)			; Modulo on 2 Words
	move.w	#4, BPL2MOD(a5)

;; DMA on
	move.w	#$8180, DMACON(a5)

;; Bitplanes filled with checker pattern
	move.l	Planeaddr, a0
	move.w	#Planesize/2-1, d0 ; loop value
	move.w	#13*16, d1	   ; Height = 16 Lines
	move.l	#$ffff0000, d2	   ; checker pattern
	move.w	d1, d3

fill:
	move.l	d2, (a0)+
	subq.w	#1, d3
	bne.s	continue
	swap d2			; pattern change
	move.w	d1, d3
continue:
	dbf	d0, fill

;; Playfields scroll
	clr.l	d0		; vertical Scroll position
	clr.l	d1		; horizontal Scroll position
	move.l	CLaddr, a1	; Address of the Copperlist
	move.l	Planeaddr, a0	; Address of first Bitplane

;; Wait on Raster line 16 (for the Exec-Interrupts)
wait:
	move.l	VPOSR(a5), d2	; read Position
	and.l	#$0001FF00, d2	; horizontal Bits masked
	cmp.l	#$00001000, d2	; wait on line 16
	bne.s	wait

;; Playfield 1 vertical scroll
	addq.b	#2, d0		; raise vertical Scroll value
	cmp.w	#$80, d0	; already 128 (4*32)
	bne.s	novover
	clr.l	d0		; Then back to 0
novover:
	move.l	d0, d2		; copy scroll value
	lsr.w	#2, d2		; copy divided by 4 s
	mulu	#52, d2		; Number Bytes per line * Scroll
				; position
	add.l	a0, d2		; plus Address of first Plane
	add.l	#Planesize, d2	; plus Plane size
	move.w	d2, 14(a1)	; give End address for Copperlist
	swap	d2
	move.w	d2, 10(a1)

;; Playfield 2 horizontal scroll
	addq.b	#1, d1		; raise horizontal Scroll value
	cmp.w	#$80, d1	; already 128 (4*32)
	bne.s	nohover
	clr.l	d1		; then back to 0
nohover:
	move.l	d1, d2		; copy scroll value
	lsr.w	#2, d2		; copy divided by 4
	move.l	d2, d3		; copy Scroll position
	and.w	#$fff0, d2	; lower 4 Bit masked
	sub.w	d2, d3		; lower 4 Bit in d3 isolated
	move.w	d4, BPLCON1(a5)	; last Value in BPLCONl
	move.w	d3, d4		; new scroll value to d4
	lsr.w	#3, d2		; new Address for Copperlist
	add.l	a0, d2		; calculate
	move.w	d2, 6(a1)	; and write in Copperlist
	swap	d2
	move.w	d2, 2(a1)

	btst	#6, CIAAPRA	; Mouse key pressed?
	bne.s	wait		; No -> continue

;; *** End program ***

;; Activate old Copperlist
	move.l	#GRname, a1	; Set parameter for OpenLibrary
	clr.l	d0
	jsr	OpenLibrary(a6)	; Open Graphics Library
	move.l	d0, a4		; Address of GraphicsBase to a4
	move.l	StartList(a4), COP1LC(a5)
	clr.w	COPJMP1(a5)
	move.w	#$83e0, DMACON(a5) ; all JMA on
	jsr	Permit(a6)	   ; Task-Switching on

;; Free memory used by Copperlist
	move.l	CLaddr, a1	; Set parameter for FreeMem
	moveq	#CLsize, d0
	jsr	FreeMem(a6)

;; Free memory used by Bit planes
FreePlane:
	move.l	Planeaddr, a1
	move.l	#Planesize*2, d0
	jsr	FreeMem(a6)

End:
	clr.l	d0
	rts			; Program end

;; Variables
CLaddr: dc.l 0
Planeaddr: dc.l 0
test: dc.l 0

;; Constants
GRname: dc.b "graphics.library", 0

end
