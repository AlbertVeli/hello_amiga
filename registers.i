;;; -*- mode: asm; -*-
;;; -*- asm-comment-char: ?\; -*-
;;;
;;; *** Some commonly used register names ***
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

;; CIA-A Port register A (Left mouse key = FIR0)
				; 7    6    5   4   3    2    1   0
CIAAPRA = $bfe001		; FIR1 FIR0 RDY TK0 WPRO CHNG LED OVL

;; Exec Library Base Offsets
Execbase = 4
OpenLibrary = -30-522		; LibName,Version/al,d0
CloseLibrary = -30-384
Output = -30-30			; Ret stdout file in d0
Write = -30-18			; Write(file, buf, len)(d1/d2/d3)
Forbid = -30-102		; Forbid multitasking
Permit = -30-108		; Permit multitasking
AllocMem = -30-168		; Byte Size, Requirements/d0,d1
FreeMem = -30-180		; Memory Block, Byte Size/al,d0
Chip = 2			; request Chip-RAM

;; graphics base
StartList = 38
