header
lorom

!addr = $0000

if read1($00ffd5) == $23
	sa1rom
	!addr = $6000
endif

org $02ADBD
autoclean JML LabelZ

freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+

LabelZ:
LDA $16E1|!addr,x
CMP #$0D
BCC JumpAndDex
JML $02ADC2

JumpAndDex:
JML $02ADC5