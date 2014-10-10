;;; -*- mode: asm; -*-
;;; -*- asm-comment-char: ?\; -*-
;;; vim: syntax=asm68k ts=8 sw=8
;;;
;;; *** Define for some commonly used registers and offsets ***

;; CustomChip-Registers
CUSTOM = $dff000		; Addr of CustomChip
INTENA = $9A			; Interrupt-Enable-Register (write)
INTREQR = $1e			; Interrupt-Request-Register (read)
DMACON = $96			; DMA-control register (write)
VPOSR = $4			; half line position (read)

;; Color palette registers
COLOR00 = $180
COLOR01 = $182
COLOR02 = $184
COLOR03 = $186
COLOR04 = $188
COLOR05 = $18a
COLOR06 = $18c
COLOR07 = $18e
COLOR08 = $190
COLOR09 = $192
COLOR10 = $194
COLORll = $196
COLOR12 = $198
COLOR13 = $19a
COLOR14 = $19c
COLOR15 = $19e
COLOR16 = $1a0
COLOR17 = $1a2
COLOR18 = $1a4
COLORl9 = $1a6
COLOR20 = $1a8
COLOR21 = $1aa
COLOR22 = $1ac
COLOR23 = $1ae
COLOR24 = $1b0
COLOR25 = $1b2
COLOR26 = $1b4
COLOR27 = $1b6
COLOR28 = $1b8
COLOR29 = $1ba
COLOR30 = $1bc
COLOR31 = $1be

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

;; Sprite Registers
SPR0PTH = $120
SPR0PTL = $122
SPR1PTH = $124
SPR1PTL = $126
SPR2PTH = $128
SPR2PTL = $12a
SPR3PTH = $12c
SPR3PTL = $12e
SPR4PTH = $130
SPR4PTL = $132
SPR5PTH = $134
SPR5PTL = $136
SPR6PTH = $138
SPR6PTL = $13a
SPR7PTH = $13c
SPR7PTL = $13e

;; CIA-A Port register A (Left mouse key = FIR0)
				; 7    6    5   4   3    2    1   0
CIAAPRA = $bfe001		; FIR1 FIR0 RDY TK0 WPRO CHNG LED OVL

;; Exec library offsets
Execbase = 4
OpenLibrary = -30-522		; LibName,Version/al,d0
CloseLibrary = -30-384
Forbid = -30-102		; Forbid multitasking
Permit = -30-108		; Permit multitasking
AllocMem = -30-168		; Byte Size, Requirements/d0,d1
FreeMem = -30-180		; Memory Block, Byte Size/al,d0
Chip = 2			; request Chip-RAM

;; DOS library
Output = -60			; Ret stdout file in d0
Write = -48			; Write(file, buf, len)(d1/d2/d3)

;; Graphics library
StartList = 38
