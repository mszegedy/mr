;act like 25

db $42
JMP code : JMP code : JMP code
JMP sprite : JMP sprite : JMP end : JMP end
JMP code : JMP code : JMP code

code:
	LDA $72		;is in air
	AND #$FF	;0 = no
	BEQ sprite	;if not in air dont do the thing
	LDA $1DFD|!addr
	BEQ sprite
	LDA #$09	;set dash at half according to patch
	STA $1DFD|!addr
	STZ $1DFE|!addr	;reset dash counter to allow after exiting
	LDA #$28	;firework whistle sfx
	STA $1DF9|!addr
	BRA end

sprite:
	LDY #$01	;\
	LDA #$30	; |Act like a stone block
	STA $1693|!addr	;/

end:
	RTL

print "Keeps your dash timer full if you dash through it, solid otherwise"