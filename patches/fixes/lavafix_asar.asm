lorom
if read1($00FFD5) == $23
	sa1rom
	!Sprite_9E	= $3200
	!Sprite_167A	= $7616
else
	!Sprite_9E	= $9E
	!Sprite_167A	= $167A
endif

org $019310
autoclean JSL MainCode    ; Hijack
NOP
NOP

freecode		; Asar > xkas

MainCode:
TAY			; "Push" A ($1693)
CMP #$59		; \ If Map16 < 159
BCC SetCarry		; / Carry flag = 1
CMP #$5C		; \ If Map16 > 15B
BCS SetCarryOrNot	; / Branch

ClearCarry:
CLC			; > Clear carry
RTL			; > Return

SetCarryOrNot:
LDA !Sprite_9E,x	; \ 
CMP #$35		; | Kill Yoshi
BEQ KillYoshi		; / 
LDA !Sprite_167A,x	; \ 
AND #$02		; | If sprite is invulnerable to lava (bit 1 = set) don't kill
BNE SetCarry		; / 

KillYoshi:
TYA			; > "Pull" A
CMP #$D2		; \ If Map16 < 1D2
BCC SetCarry		; / Carry flag = 1
CMP #$D8		; \ If Map16 = 1D2 - 1D7
BCC ClearCarry		; / Carry flag = 0 (kill sprite)
CMP #$FB		; \ If Map16 > 1FA
BCS ClearCarry		; / Carry flag = 0

SetCarry:
TYA			; > "Pull" A
SEC			; > Set carry
RTL			; > Return
