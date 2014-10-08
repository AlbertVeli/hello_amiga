;; -*- mode: asm; -*-
;; -*- asm-comment-char: ?\; -*-
;;     ^^ tells emacs it should use asm-mode with ; as comment char
;;
;; Example hello world program using Amiga DOS output routines
;; (mostly cut-and-paste from an aminet post)

_LVOOpenLibrary EQU -552
_LVOCloseLibrary EQU -414
_LVOOutput EQU -60
_LVOWrite EQU -48

start:
	move.l	4.w, a6		; Note. Compile with -spaces to allow space between args
	lea	dosname(pc), a1
	moveq	#0, d0
	jsr	_LVOOpenLibrary(a6) ; Open library
	tst.l	d0
	beq.s	nodos		; Exit on failure
	move.l	d0, a6		; DOSBase addr -> a6
	lea	msg(pc), a0	; Set up rest of registers for lib calls
	moveq	#-1, d3
	move.l	a0, d2
strlen:
	addq.l	#1, d3		; len of msg -> d3
	tst.b	(a0)+
	bne.s	strlen
	jsr	_LVOOutput(a6)	; Print the msg
	move.l	d0, d1
	jsr	_LVOWrite(a6)
	move.l	a6, a1		; Done, clean up
	move.l	4.w, a6
	jsr	_LVOCloseLibrary(a6)
nodos:
	moveq	#0, d0
	rts
dosname:
	dc.b	'dos.library', 0
msg:
	dc.b 'Hello, world!', 10, 0
