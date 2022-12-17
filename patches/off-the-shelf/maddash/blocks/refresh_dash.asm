;act like 25

db $42
JMP code : JMP code : JMP code
JMP end : JMP end : JMP end : JMP end
JMP code : JMP code : JMP code

code:
	STZ $1DFE|!addr	;dash timer
	STZ $1F48|!addr	;dash cooldown
	LDA #$10	;magikoopa shoot sfx
	STA $1DF9|!addr
	%erase_block()
	%create_smoke()

end:
	RTL

print "Refreshes your dash then poofs away, does not respawn"