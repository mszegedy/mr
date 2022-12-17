;act like 25

db $42
JMP code : JMP code : JMP code
JMP end : JMP end : JMP end : JMP end
JMP code : JMP code : JMP code

code:
	STZ $1F2C|!addr

end:
	RTL

print "Sets your dash count to 0"