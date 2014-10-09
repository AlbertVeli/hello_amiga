;; -*- mode: asm; -*-
;; -*- asm-comment-char: ?\; -*-
;;     ^^ tells emacs it should use asm-mode with ; as comment char
;;
;; Example hello world program using Amiga DOS output routines
;; (mostly cut-and-paste from an aminet post)

_LVOOpenLibrary EQU -552
_LVOCloseLibrary EQU -414
_LVOOutput EQU -60		; Ret stdout file in d0
_LVOWrite EQU -48		; Write(file, buf, len)(d1/d2/d3)

start:
	move.l	4.w, a6
	lea	dosname(pc), a1
	moveq	#0, d0
	jsr	_LVOOpenLibrary(a6) ; Open DOS library
	tst.l	d0
	beq.s	end		; Exit on failure
	move.l	d0, a6		; DOSBase addr -> a6

	lea	hello(pc), a0	; buf in a0, doslib in a6
	jsr	puts
	lea	goodbye(pc), a0
	jsr	puts

	move.l	a6, a1		; Done, clean up
	move.l	4.w, a6
	jsr	_LVOCloseLibrary(a6)

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
	jsr	_LVOOutput(a6)	; Output file pointer -> d0
	move.l	d0, d1		; to d1
	jsr	_LVOWrite(a6)	; Write(fp, buffer, len) in d1,d2,d3
	rts

dosname:
	dc.b	'dos.library', 0
hello:
	dc.b 'Hello, world!', 10, 0
goodbye:
	dc.b 'Goodbye, cruel world!', 10, 0
