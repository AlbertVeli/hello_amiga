;; -*- mode: asm; -*-
;; -*- asm-comment-char: ?\; -*-
;; vim: syntax=asm68k ts=8 sw=8
;;
;; Example hello world program using Amiga DOS output routines
;; (mostly cut-and-paste from an aminet post)

	;; Include register and offset defines
	include registers.i

start:
	move.l	4.w, a6
	lea	dosname(pc), a1
	moveq	#0, d0
	jsr	OpenLibrary(a6)	; Open DOS library
	tst.l	d0
	beq.s	end		; Exit on failure
	move.l	d0, a6		; DOSBase addr -> a6

	lea	hello(pc), a0	; buf in a0, doslib in a6
	jsr	puts
	lea	goodbye(pc), a0
	jsr	puts

	move.l	a6, a1		; Done, clean up
	move.l	4.w, a6
	jsr	CloseLibrary(a6)

end:
	moveq	#0, d0
	rts

;; Subroutine to output string to stdout
;; params: Zero-terminated string in a0
;;         and DOSBase in a6
;; destroys: a0, d0-d3
puts:
	moveq	#-1, d3
	move.l	a0, d2
strlen:
	addq.l	#1, d3		; len of msg -> d3
	tst.b	(a0)+
	bne.s	strlen
	jsr	Output(a6)	; Output file pointer -> d0
	move.l	d0, d1		; to d1
	jsr	Write(a6)	; Write(fp, buffer, len) in d1,d2,d3
	rts

dosname:
	dc.b	'dos.library', 0
hello:
	dc.b 'Hello, world!', 10, 0
goodbye:
	dc.b 'Goodbye, cruel world!', 10, 0
