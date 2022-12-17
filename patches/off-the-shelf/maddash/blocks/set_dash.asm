;act like 25

!DashValue = $01

db $42
JMP code : JMP code : JMP code
JMP end : JMP end : JMP end : JMP end
JMP code : JMP code : JMP code

code:
	LDA $1F2C|!addr
	CMP #!DashValue
	BCS end
	LDA #!DashValue
	STA $1F2C|!addr

end:
	RTL

print "Sets your dash count to ", dec(!DashValue), " if its lower"