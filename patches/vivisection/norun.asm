!MaxSpeedRight = $21		; Maximum speed right.
!MaxSpeedLeft  = $DE		; Maximum speed left.

if read1($00FFD5) == $23
	sa1rom
	!base3 = $000000
else
	lorom
	!base3 = $800000
endif

;---------
;Hex Edits;
;---------

org $00D66F|!base3
	db $80 ; Disable air flight/max speed.

;-----------
org $00A299|!base3
autoclean JSL NoRun

freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+

NoRun:
	JSL $00F6DB|!base3		; Restore
	LDA $7B				; If speed is negative (#$80-#$FF)..
	BMI Left			; Check maximum left speed.
	CMP #!MaxSpeedRight		; Else check if ..
	BPL Limit			; ...maximum speed limit for right reached.
Left:
	CMP #!MaxSpeedLeft
	BMI LimitLeft			; Return if not going lower than maximum.
	RTL
Limit:
	LDA #!MaxSpeedRight		; Get maximum right speed ...
	BRA SetSpeed			; And store it.
LimitLeft:
	LDA #!MaxSpeedLeft		; Store maximum left speed.
SetSpeed:
	STA $7B
	RTL