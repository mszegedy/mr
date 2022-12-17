; Mad Dash v4 Patch
; Created by CoMPMStR
; Original (Wario Dash v2) by K3fka

; edited by mszegedy for the mushroom rebellion hack

;v1 -	Initial release
;v2 -	Fixed animation glitch
;	Fixed cape spin using X button
;	Added cooldown timer
;	Added R button option
;	Added crouch dash option
;v3 -	Added "horizontal dash only" option
;v4 -	Fixed death bugs

header

if read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!ram = $400000
else
	lorom
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!ram = $7E0000
endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!UseRButton = 0			;Set to 1 to use the R button, 0 to use the X button

!DisableDashSpin = 1		;Set to 1 to disable the cape spin with X completely
				;Set to 0 to allow cape spin while pressing left/right on the d-pad

!AllowCrouchDash = 0		;Set to 1 to allow dashing while crouching, 0 to disable

!MMDash = 0			;Set to 1 to set dashing only left/right, 0 to allow up/down also

!DashDir = $1DEF|!addr		;The dash direction (freeram)
!DashRAM1 = $1DFD|!addr		;The dash timer (freeram)
!DashRAM2 = $1DFE|!addr		;The dash counter (freeram)
!DashTick = $1F48|!addr		;The dash cooldown tick (freeram)
!DashMax = $1F2C|!addr		;Freeram that doesn't reset on level load (saves to SRAM)
!HasDied = $1F3B|!addr		;Did the player die recently? (freeram)

!DashTimer = #$12		;Time you will dash
!DashCooldown = #$5		;Cooldown before next dash
!DashSpeed = #$24		;Speed you will dash

!DashOnGround = 1		;Allow dashing while on the ground, or require to be in the air
!DashOnVine = 0			;Allow dashing while climbing, or require to be in the air
!VineGivesDash = 1		;Whether or not to reset the dash counter when climbing

!RequiresPowerup = 0		;Does it need a powerup
!UsedPowerup = #01		;If so, which is the used powerup
!MaxDashes = #01		;Max dashes allowed, if DashMax exceeds this it will be capped

!KeepMaxDashes = 1	;enabled (1) will keep the maximum dashes set to the above MaxDashes value
;disabled (0) will start DashMax at 0 and allow increasing or decreasing the amount during gameplay with custom blocks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org $008E6F|!bank
autoclean JSL DashCheck
NOP
NOP

org $00D062|!bank
autoclean JSL SpinCheck

;prevents the 1-frame cape glitch when dashing on the ground, also disables cape sliding after flight
org $00CF51|!bank	;mario will start running after ground contact
BRA $0F			;rather than a small slide to slow down while holding the cape

;monitor if the player died to reset dash vars
org $00F614|!bank
autoclean JSL DeathCheck


freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+


DashCheck:
	LDA !HasDied	;has died
	CMP #$01
	BNE .NotDead	;if not skip
	STZ !DashDir	;\
	STZ !DashRAM1	;| reset dash vars
	STZ !DashRAM2	;|
	STZ !DashTick	;/
	LDA $1496|!addr	;if death anim isn't playing
	CMP #$01
	BCC .SkipDeathExit	;jump over exit
	LDA $0F31|!addr		; \ Restore the 
	STA $0F25|!addr		; / Hijacked code.
	RTL
.SkipDeathExit
	STZ !HasDied	;otherwise reset var and continue
.NotDead
	LDA $77		;is blocked
	AND #$04	;0 = no, 1 = right, 2 = left, 4 = down, 8 = up
	BEQ .Air	;if not in air..

	LDA $15		;\
	AND #$40	; |Only reset if we're NOT holding X
	BNE .NoReset	;/(need this or you get an extra dash from the ground)
	STZ !DashRAM2	;reset the dash counter

.NoReset
	LDA !MaxDashes
	if !KeepMaxDashes : STA !DashMax

	CMP !DashMax	;check if var max dashes exceeds coded max dashes
	BCS .Air
	STA !DashMax	;if greater, reset to hardcoded max

.Air
	if !VineGivesDash : JSR DashVine

	LDA !DashRAM1		;\We're not dashing if our dash timer is zero
	BEQ .ButtonCheck	;/
	DEC !DashRAM1		;Decrease the dash timer
	LDA !DashRAM1		;\
	CMP #01			; |if the dash timer has depleated, stop dashing
	BCC .Cancel		;/
if not(!MMDash)
	JSR DashAction		;Do the action of dashing
else
	JSR DashActionMM	;Do the action of dashing (horizontal only)
endif
	JSR DashPose		;set mario's pose and p-speed
	JSR DisableController	;disable controller input
	BRA .WallCheck

.ButtonCheck
	LDA !DashTick	;\If the cooldown timer is zero, start the dash
	BEQ .NoCooldown	;/
	DEC !DashTick	;If not, decrease the cooldown timer
	BRA .End	;Jump to the end

.NoCooldown
	LDA $16		;\
	AND #$40	; |Jump to the end if we're NOT pressing X
	BEQ .End	;/

	LDA $75		;is in water
	ORA $140D|!addr	;or spinning
	BNE .End

if !RequiresPowerup
	LDA $19		;\Or if we dont have the powerup
	CMP !UsedPowerup; |
	BNE .End	;/
endif

if not(!DashOnGround)
	LDA $77		;\
	AND #$04	; |Check to see if we're touching the ground
	BNE .End	;/
endif

if not(!AllowCrouchDash)
	LDA $73		;\
	BNE .End	;/Check to see if we're ducking
endif

if not(!DashOnVine)
	LDA $74		;check if on vine
	BNE .End
endif

	LDA !DashRAM2	;\check if dash counts exceeded
	CMP !DashMax	;/
	BCS .End

.BeginDash
	LDA $187A|!addr		;\If riding yoshi, don't dash
	BNE .End		;/
	LDA $15			;\Store the d-pad direction
	STA !DashDir		;/
	LDA !DashTimer		;\Set the dash timer
	STA !DashRAM1		;/
	LDA !DashCooldown	;\Set the cooldown timer
	STA !DashTick		;/
	INC !DashRAM2		;increment the dash count
	JSR CreateSmoke		;Create puff effect
	JSR DashSFX		;Play the SFX
	BRA .End		;Then jump to the end

.WallCheck
	LDA $77		;\
	AND #$03	; |Check to see if we're touching a wall
	BNE .Wall	;/
	LDA $77		;\
	AND #$08	; |Check to see if we're touching the ceiling
	BNE .Ceiling	;/
	BRA .End

.Wall
	STZ $7B		;Stop moving x-axis
	BRA .Cancel
.Ceiling
	STZ $7D		;Stop moving y-axis
.Cancel
	STZ !DashRAM1		;Zero out the timer
	STZ $13ED|!addr		;\Stop sliding
	STZ $13EE|!addr		;/

.End
	LDA $0F31|!addr	; \ Restore the 
	STA $0F25|!addr	; / Hijacked code.
	RTL


DisableController:
	STZ $15            ;  \
	STZ $16            ;   | Keep the controller value zero, simulating no button press
	STZ $17            ;   | This is JSR to to because it saves space, keeping some branches working
	STZ $18            ;  /  (BRA, BNE, BCS, etc)
RTS


DashActionMM:
	INC $1406|!addr		;Scroll camera?
	LDA #$FF		;\
	STA $13ED|!addr		; |Simulate sliding
	LDA #$7F		; |This allows killing some enemies
	STA $13EE|!addr		;/
	LDA !DashDir		;\
	AND #$03		; |Check if left or right was pressed
	BEQ .DashR		; |If not dash using facing direction
	AND #$02		;\Check if holding left
	BEQ .NotLeft		;/
	LDA !DashSpeed		;\
	EOR #$FF		; |Xor to reverse the speed
	STA $7B			; |Set dash speed
	STZ $7D			;/zero out vertical speed
	RTS
.NotLeft
	LDA !DashSpeed		;\
	STA $7B			; |Set dash speed
	STZ $7D			;/zero out vertical speed
	RTS
.DashR
	LDA $76			;\Dash left if we're facing left
	BEQ .DashL		;/
	LDA !DashSpeed		;\
	STA $7B			; |Set dash speed
	STZ $7D			;/zero out vertical speed
	RTS
.DashL
	LDA !DashSpeed		;\
	EOR #$FF		; |Xor to reverse the speed
	STA $7B			; |Set dash speed
	STZ $7D			;/zero out vertical speed
	RTS



DashAction:
	INC $1406|!addr		;Scroll camera?
	LDA #$FF		;\
	STA $13ED|!addr		; |Simulate sliding
	LDA #$7F		; |This allows killing some enemies
	STA $13EE|!addr		;/
	LDA !DashDir		;\
	AND #$08		; |Check if up was pressed
	BEQ .NotUp		; |If not check down
	LDA !DashSpeed		; |Set dash speed
	EOR #$FF		; |Xor to reverse the speed
	STA $7D			;/Apply speed to vertical
	BRA .NotDown
.NotUp
	LDA !DashDir		;\
	AND #$04		; |Check if down was pressed
	BEQ .NotDown		; |If not check left/right
	LDA !DashSpeed		; |Set dash speed
	STA $7D			;/Apply speed to vertical
.NotDown
	LDA !DashDir		;\
	AND #$03		; |Check if left or right was pressed
	BEQ .NotH		; |If not dash using facing direction
	AND #$02		;\Check if holding left
	BEQ .NotLeft		;/
	LDA !DashSpeed		;\
	EOR #$FF		; |Xor to reverse the speed
	STA $7B			;/Set dash speed
	LDA !DashDir		;\
	AND #$0C		; |Check if pressing up/down
	BNE .V1			; |If not zero out vertical speed
	STZ $7D			;/
.V1
	RTS
.NotLeft
	LDA !DashSpeed		;\Set dash speed
	STA $7B			;/
	LDA !DashDir		;\
	AND #$0C		; |Check if pressing up/down
	BNE .V2			; |If not zero out vertical speed
	STZ $7D			;/
.V2
	RTS
.NotH
	LDA !DashDir		;\
	AND #$0C		; |Check if up or down was pressed
	BEQ .DashR		; |If not dash using facing direction
	RTS			;/If so just dash up/down
.DashR
	LDA $76			;\Dash left if we're facing left
	BEQ .DashL		;/
	LDA !DashSpeed		;\
	STA $7B			;/Set dash speed
	LDA !DashDir		;\
	AND #$0C		; |Check if pressing up/down
	BNE .V3			; |If not zero out vertical speed
	STZ $7D			;/
.V3
	RTS
.DashL
	LDA !DashSpeed		;\
	EOR #$FF		; |Xor to reverse the speed
	STA $7B			; |Set dash speed
	LDA !DashDir		;\
	AND #$0C		; |Check if pressing up/down
	BNE .V4			; |If not zero out vertical speed
	STZ $7D			;/
.V4
	RTS


DashPose:
if not(!MMDash)
	LDA !DashDir		;\
	AND #$08		; |Check if up was pressed
	BEQ .NotUp		;/If not check down
	LDA #$0A		;\Set the up direction pose
	STA $13E0|!addr		;/
	BRA .End
.NotUp
	LDA !DashDir		;\
	AND #$04		; |Check if down was pressed
	BEQ .NotDown		;/If not check left/right
	LDA #$1D		;\Set the down direction pose
	STA $13E0|!addr		;/
	BRA .End
endif
.NotDown
	LDA #$0D		;\Set the pose (same for left/right)
	STA $13E0|!addr		;/
.End
	LDA #$70		;\Set the p-meter value
	STA $13E4|!addr		;/
	RTS


DashVine:
	LDA $74			;check if on vine
	BEQ .NoVine
	STZ !DashRAM2		;reset the dash counter
.NoVine
	RTS


DashSFX:
	LDA $19		;check powerup
	BNE .Big	;if small play a different sound
	LDA #$13	;load yoshi hurt sfx
	BRA .Play	;play it
.Big
	LDA #$10	;not small, load bullet bill shot sfx
.Play
	STA $1DFC|!addr	;store in proper bank
	RTS


CreateSmoke:
	LDA $17C0|!addr
	BNE .retn

	INC $17C0|!addr
	LDA #$1B
	STA $17CC|!addr

	LDA $77		;is blocked
	AND #$04	;4 bit = down
	BEQ .NotAir	;if in air move smoke up a block
	LDA $98		;touched block y pos
	AND #$F0	;rounded
	SEC		;clear flags
	SBC #$10	;subtract 0x10
	BRA .Air	;in the air...
.NotAir
	LDA $98
	AND #$F0
.Air
	STA $17C4|!addr
	LDA $9A
	AND #$F0
	STA $17C8|!addr

.retn
	RTS


DeathCheck:
	LDA #$01
	STA !HasDied
	LDA #$09	;restore overwritten
	STA $71
	RTL


SpinCheck:
if not(!UseRButton)
	LDA $18		;\
	AND #$40	; |Jump to the end if we're NOT pressing X
	BEQ .End	;/
if not(!DisableDashSpin)
	LDA !DashDir	;\
	AND #$03	; |Check if left or right was pressed
	BNE .End	;/
endif
	LDA $19		;check for powerup
	CMP #$FF	;this will make it always BNE so no spin
	RTL
endif

.End
	LDA $19		;check for powerup
	CMP #$02	;check if cape so Mario can do cape actions normally
	RTL

print "Bytes inserted: ", bytes
