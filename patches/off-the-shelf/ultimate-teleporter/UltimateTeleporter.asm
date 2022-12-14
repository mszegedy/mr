;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Ultimate Screen Teleporter
; by Mario90
; Original teleport via fall code by MarioFanGamer
;
; This patch will let you use screen exits by walking into them
; or it will let you teleport from falling off screen
; or jumping off the top of the screen.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

assert read1($05D8B7) == $80,      "This patch requires UberASM to be inserted in your ROM, please install it in order to use this patch."

;Defines
!LevelNum = $010B|!SA1Address	; Level number, make sure level/uberasm is installed first or this won't work.

!FreeRam = $60			;Change if needed

!FreeRam2 = $61

!AnimationState = $0E		;Only used if combined with GHB's player trigger patch to remove pipe centering.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options
;; 00 = No 
;; 01 = Yes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!NeedUpSpeed = 1		;Need Upward Speed for top screen warp

!AllowFlying = 1			;Allows cape gliding into top screen warps

;The following can only be used properly with GHB's player trigger patch: https://www.smwcentral.net/?p=section&a=details&id=11432

!RemovePipeCenter = 0		;Removes the pipe centering effect for side exits but not actual pipes so Mario isn't a few pixels above the ground.

!RemovePipePriority = 0		;Removes pipe priority effects for side exits but again not for actual pipes. 

; SA-1 compatibility

; Do NOT touch

if read1($00FFD5) == $23	; Check, if the ROM uses SA-1
	sa1rom
	!SA1Address = $6000
else
	lorom
	!SA1Address = $0000
endif

; Hijacks
org $00F5B2
autoclean JSL Hijacking

org $00F5A3 
JSL SideScreen

org $00D1DB
JML ScreenPipeFix

if !RemovePipeCenter == 1

org $00D1B2	
JML FixYpos
endif

if !RemovePipePriority == 1
org $00D231
JSL Priority
NOP
endif

freecode
if read1($05D8B7) == $80
print "Patch is written at $",pc
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Falling off screen code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Hijacking:
		PHB			; \
		PHK			;  |
		PLB			;  |
		PHY			;  |
		PHX			;  |
		REP #$30		;  |
		LDA !LevelNum		;  |
		PHA             	;  |
		LSR #3			;  | Code by Roy:
		TAY			;  | Load the bit that corresponds
		PLA			;  | to the current level
		AND #$0007		;  |
		TAX			;  |
		SEP #$20		;  |
		LDA.W Table,y		;  |
		AND.W ANDTable,x	;  |
		SEP #$10		;  |
		PLX			;  |
		PLY			; /
		CMP #$00		; \  If not zero,
		BNE Teleport		; /  teleport

NoLocation:	
		PLB
		JSL $00F60A 		; Kill Mario if no screen exit (for pits)
		RTL

Teleport:	
		LDX $95			; Load Mario's x position high byte (screen number) to x.
		LDA $19B8|!SA1Address,x	; Load exit table.
		BEQ NoLocation		; You don't want to teleport Mario to level x00
		LDA #$06		; \
		STA $71			; | Teleport Mario
		STZ $89			; |
		STZ $88			; /
		PLB
		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of side screen exit code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

FixYpos:
LDA $71
CMP #!AnimationState
BEQ NoCenter
REP #$20 
LDA $96     
JML $00D1B6

NoCenter:
JML $00D1C4

Priority:
LDA !FreeRam
BNE NormalPriority
LDA #$02 
STA $13F9|!SA1Address 
NormalPriority:
RTL

SideScreen:
	SEP #$20           ;Jump to our code and restore the original
	JSR SideStart
	JSR UpStart
	LDA $81               
	RTL

SideStart:
	LDA $71			;Don't run if doing other animations
	BNE NoTeleYet
	LDA $5B
	AND #$01
	BNE MaybeTeleport 	;If in a vertical level skip checking only screen 0 and the level's last screen
	LDA $95
	BEQ MaybeTeleport	;If on screen 0, check for a screen exit
	LDA $5E
	SEC
	SBC #$01					;If on the last screen in the level check for a screen exit
	CMP $95
	BEQ MaybeTeleport
	NoTeleYet:
	STZ !FreeRam			;Clear the flag for screen exits if set
	RTS

MaybeTeleport:
		REP #$10
		LDX !LevelNum		;If the current level
		LDA.l SideExitTable,x		;allows side screen warps
		SEP #$10
		STA !FreeRam
		CMP #$00		; run the teleport code
		BNE Teleport2		
NoLocation2:
		RTS

Teleport2:
		LDA $5B
		AND #$01
		ASL 
		TAX 	
		LDA $95,x			; Load Mario's x position high byte (screen number) to x.
		TAX					
		LDA $19B8|!SA1Address,x	; Load exit table.
		BEQ NoLocation2		; You don't want to teleport Mario to level x00		
		LDA !FreeRam
		JSL $0086DF

dw Null			;00 - Set up like this so you can add more values if you want to edit this and add your own animations/code/whatever
dw Walk		;01
dw Null			;02 etc...

Null:
RTS 

Walk:
	LDA $77		;Must be on the ground
	AND #$04
	BNE Onground
	RTS
Onground:
	LDA $1471|!SA1Address ;Can't be on top of a sprite
	ORA $72							;Or in the air
	BNE EndWalkCheck
	LDA $7E						;Check if at the left edge of the screen
	CMP #$0C
	BCC LeftScreen
	CMP #$E4					;If not, check if at the right edge of the screen
	BCS RightScreen
	RTS
LeftScreen:
	LDA $15						;If you're actually pushing left
	AND #$02						;finally use the screen exit
	BNE CanTeleport
EndWalkCheck:
	RTS
CanTeleport:
	LDA #$FF					;Freeze sprites
	STA $9D
	LDA #$50					;Warp timer
	STA $88
	STZ $89
	LDA #$05					;Horizontal pipe entrance
	STA $71
	RTS
RightScreen:	
	LDA $15				;If you're actually pushing right
	AND #$01				;finally use the screen exit
	BNE CanTeleport2
	RTS
CanTeleport2:
	LDA #$FF					;Freeze sprites		
	STA $9D
	LDA #$50					;Warp timer
	STA $88
	LDA #$01
	STA $89
	LDA #$05					;Horizontal pipe entrance
	STA $71
	RTS

ScreenPipeFix:	;Piece of original game's code for dealing with pipes
	LDX $88
	CPX #$1D
	BCS CODE_00D1F0
	CPY #$03
	BCC CODE_00D1F0 
	REP #$20
	INC $96
	INC $96
	SEP #$20
CODE_00D1F0: 
	LDA !FreeRam	;If warping from screen exit, use a slightly different method of warping
	BNE Adjust
	JML $00D1F2
Adjust:
	LDA $5B
	AND #$01
	BNE VerticalLevel	;Use slightly different code in a vertical level
	JSR CalcScreen
	JML $00D1F2

VerticalLevel:
	JSR CalcScreenVert
	JML $00D1F2


CalcScreen:
	LDA $95
	BMI ScreenZero		;If you happen to walk into screen #$FF
	BEQ ScreenZero	;Use screen 0's exit.
WarpToLvl:
	TAX
	LDA $5E				;If on the last screen in the level and you happen to walk past it
	SEC						;Correct it by using the last screen's exit anyway
	SBC #$01
	TAY
UseScreenZero:
	LDA $19B8|!SA1Address,y	;\adjust what screen exit to use for
	STA $19B8|!SA1Address,x		;|teleporting.
	LDA $19D8|!SA1Address,y	;|
	STA $19D8|!SA1Address,x		;/
	RTS
	
ScreenZero:
	TAX
	LDY #$00
	BRA UseScreenZero

CalcScreenVert:						;Same stuff as above but for vertical levels
	LDA $97					
	BMI ScreenZero
	BEQ ScreenZero
WarpToLvlVert:
	TAX
	TAY
UseScreenZeroVert:
	LDA $19B8|!SA1Address,y	;\adjust what screen exit to use for
	STA $19B8|!SA1Address,x		;|teleporting.
	LDA $19D8|!SA1Address,y	;|
	STA $19D8|!SA1Address,x		;/
	RTS
	
ScreenZeroVert:
	LDX #$00 
	LDY #$00
	BRA UseScreenZeroVert
	
UpStart:
	LDA $71			;Don't run if doing other animations
	BNE NoTeleYet2
	REP #$20
	LDA $96
	CMP #$FFE0			;Position that the warp will activate (just offscreen)
	SEP #$20					;Make it lower to push it higher I.E #$FFD0 is 2 blocks off screen
	BCC MaybeTeleportUp
	NoTeleYet2:
	STZ !FreeRam2			;Clear the flag for screen exits if set
	RTS

MaybeTeleportUp:
		LDA $97				;Don't bother if within normal level screens
		CMP #$20
		BCC NoLocation3
if !NeedUpSpeed == 1		
		LDA $7D
		BPL NoLocation3		;Optional - player needs upward momentum to actually teleport
endif
if !AllowFlying == 0
		LDA $1407|!SA1Address 	;Also can't cape glide into it
		BNE NoLocation3
endif			
CanStillTeleport:	
		REP #$10
		LDX !LevelNum		;If the current level
		LDA.l UpExitTable,x		;allows top screen warps
		SEP #$10
		STA !FreeRam2
		CMP #$00		; run the teleport code
		BNE TeleportUp
NoLocation3:
		RTS

TeleportUp:
		LDA $5B
		AND #$01
		BNE VerticalLevelUp
		TAX 	
		LDA $95,x			; Load Mario's x position high byte (screen number) to x.
		TAX					
		LDA $19B8|!SA1Address,x	; Load exit table.
		BNE UpWarpTable
		RTS
VerticalLevelUp:		
		JSR CalcScreenVert	
		LDA $19B8|!SA1Address,x	; Load exit table.
		BEQ NoLocation3
UpWarpTable:
		LDA !FreeRam2
		JSL $0086DF
		
dw Null			;00 - Set up like this so you can add more values if you want to edit this and add your own animations/code/whatever
dw UpWarp	;01
dw Null			;02 etc...

UpWarp:
	LDA #$06
	STA $71
	STZ $89
	STZ $88
	RTS

;. Tables
ANDTable:
db $80,$40,$20,$10,$08,$04,$02,$01 ; Don't change.

;.. Level table
;; Change the corresponding bit to 1 to activate teleporting by falling off screen
Table:	db %00000000,%00000000 ; Levels 0-F
	db %00000000,%00000000 ; Levels 10-1F
	db %00000000,%00000000 ; Levels 20-2F
	db %00000000,%00000000 ; Levels 30-3F
	db %00000000,%00000000 ; Levels 40-4F
	db %00000000,%00000000 ; Levels 50-5F
	db %00000000,%00000000 ; Levels 60-6F
	db %00000000,%00000000 ; Levels 70-7F
	db %00000000,%00000000 ; Levels 80-8F
	db %00000000,%00000000 ; Levels 90-9F
	db %00000000,%00000000 ; Levels A0-AF
	db %00000000,%00000000 ; Levels B0-BF
	db %00000000,%00000000 ; Levels C0-CF
	db %00000000,%00000000 ; Levels D0-DF
	db %00000000,%00000000 ; Levels E0-EF
	db %00000000,%00000000 ; Levels F0-FF
	db %00000100,%00000000 ; Levels 100-10F
	db %00000000,%00000000 ; Levels 110-11F
	db %00000000,%00000000 ; Levels 120-12F
	db %00000000,%00000000 ; Levels 130-13F
	db %00000000,%00000000 ; Levels 140-14F
	db %00000000,%00000000 ; Levels 150-15F
	db %00000000,%00000000 ; Levels 160-16F
	db %00000000,%00000000 ; Levels 170-17F
	db %00000000,%00000000 ; Levels 180-18F
	db %00000000,%00000000 ; Levels 190-19F
	db %00000000,%00000000 ; Levels 1A0-1AF
	db %00000000,%00000000 ; Levels 1B0-1BF
	db %00000000,%00000000 ; Levels 1C0-1CF
	db %00000000,%00000000 ; Levels 1D0-1DF
	db %00000000,%00000000 ; Levels 1E0-1EF
	db %00000000,%00000000 ; Levels 1F0-1FF
	
;Rather than use the AND table above for this, use a normal table
;If skilled enough in ASM you can edit this patch use different values
;for a custom effect if wanted

SideExitTable:	
db $00,$00,$00,$01,$00,$00,$00,$00		; levels 00-07
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 08-0F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 10-17
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 18-1F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 20-27
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 28-2F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 30-37
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 38-3F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 40-47
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 48-4F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 50-57
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 58-5F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 60-67
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 68-6F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 70-77
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 78-7F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 80-87
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 88-8F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 90-97
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 98-9F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels A0-A7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels A8-AF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels B0-B7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels B8-BF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels C0-C7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels C8-CF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels D0-D7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels D8-DF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels E0-E7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels E8-EF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels F0-F7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels F8-FF
db $00,$00,$00,$00,$01,$01,$00,$00		; levels 100-107
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 108-10F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 110-117
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 118-11F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 120-127
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 128-12F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 130-137
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 138-13F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 140-147
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 148-14F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 150-157
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 158-15F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 160-167
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 168-16F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 170-177
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 178-17F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 180-187
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 188-18F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 190-197
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 198-19F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1A0-1A7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1A8-1AF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1B0-1B7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1B8-1BF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1C0-1C7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1C8-1CF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1D0-1D7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1D8-1DF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1E0-1E7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1E8-1EF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1F0-1F7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1F8-1FF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Can do the same as above with this table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpExitTable:	
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 00-07
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 08-0F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 10-17
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 18-1F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 20-27
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 28-2F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 30-37
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 38-3F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 40-47
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 48-4F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 50-57
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 58-5F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 60-67
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 68-6F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 70-77
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 78-7F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 80-87
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 88-8F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 90-97
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 98-9F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels A0-A7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels A8-AF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels B0-B7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels B8-BF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels C0-C7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels C8-CF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels D0-D7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels D8-DF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels E0-E7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels E8-EF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels F0-F7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels F8-FF
db $00,$00,$00,$00,$01,$01,$00,$00		; levels 100-107
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 108-10F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 110-117
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 118-11F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 120-127
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 128-12F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 130-137
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 138-13F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 140-147
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 148-14F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 150-157
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 158-15F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 160-167
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 168-16F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 170-177
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 178-17F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 180-187
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 188-18F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 190-197
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 198-19F
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1A0-1A7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1A8-1AF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1B0-1B7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1B8-1BF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1C0-1C7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1C8-1CF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1D0-1D7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1D8-1DF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1E0-1E7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1E8-1EF
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1F0-1F7
db $00,$00,$00,$00,$00,$00,$00,$00		; levels 1F8-1FF

if read1($05D8B7) == $80
print "By the way, if you want to know how much freespace it wastes"
print "then here you are: 0x",freespaceuse," bytes."
endif
