header
lorom

!RAM_DecCoins		= $7F969E
!RAM_DecCoinsSA1	= $40969E

!coin_count		= 6		; How many digits to show. Valid values: 4, 5, 6.

!ShowZeroes		= $00		; 00 - don't show leading zeroes, anything else - show them
!ClearCoinOnGameOver	= $00		; 00 - don't reset all coins on game over, anything else - reset on game over.

!addr = $0000
!sram = $700000

if read1($00ffd5) == $23
	sa1rom
	!addr = $6000
	!sram = $41C000
	!RAM_DecCoins = !RAM_DecCoinsSA1
endif

org $008CB2
db     $3C ;  |
db $FC,$38 ;  |
db $FC,$38 ;  |
db $FC,$20 ;  | Tilemap in status bar.
db $FC,$20 ;  |
db $FC,$38 ;  |
db $FC,$38 ;  |
db $FC,$20 ; /
      
org $008CE7
db $2E,$3C ; \  Change $FC to $2E if you want the coin sign in front.
db $00,$38 ;  |
db $00,$38 ;  | More tilemap data.
db $00,$38 ;  |
db $00,$38 ;  |
db $00,$38 ;  |
db $00,$38 ;  |
db $FC,$3C ; /

org $008EE5

autoclean JSL ZeroCoins
NOP

org $00802A
autoclean JSL ZeroDec

;STZ $0F29|!addr,x       ; <--

org $008F1D
autoclean JML RoutineStart
LDA $00
BRA CycleSkip  ;\ Skip for reducing cycles
NOP            ; |
NOP            ; | Useless
NOP            ; |
NOP            ;/

CycleSkip:


org $008F7E
BRA Skip ; \ Skip to save cycles.
NOP      ;  |
NOP      ;  | 
NOP      ;  |
NOP      ; / There isn't written to coin total.
Skip:

org $009BCC
autoclean JSL SaveSRAMRoutine   ; Save data to SRAM!
NOP
NOP

org $009D14
autoclean JSL LoadSRAMRoutine   ; Load data from SRAM!

org $009E4E
NOP    ; Remove the first ; if you...
NOP    ; want to disable the score being...
NOP    ; deleted when getting to the Game Over screen.

org $009E56
NOP    ; Remove the first ; if you...
NOP    ; want to disable the score being...
NOP    ; deleted when getting to the Game Over screen.

if !ClearCoinOnGameOver
	org $00D0DD
	JSL STZSRAMWhenGameOver
	NOP
endif
	
org $028766
BRA $01
NOP ; /

org $028770
BRA $01
NOP ; /

org $02AE21
BRA SkipUseless     ; \ Skip to save cycles.
NOP                 ;  |
NOP                 ;  |
NOP         	    ;  |
NOP         	    ;  | Disable score
NOP         	    ;  |
NOP         	    ;  |
NOP         	    ;  |
NOP	    	    ;  |
NOP	            ;  |
NOP	            ; /
NOP
NOP
NOP
NOP                 ; \ Yeah more semi-colons and comments...
NOP                 ; / Etc.
NOP
NOP
NOP
SkipUseless:

org $05CEF9
BRA +
NOP ;  |
NOP ;  |
NOP ;  |
NOP ;  |
NOP ;  | Disable score being added at level end.
NOP ;  |
NOP ;  |
NOP ;  |
NOP ;  |
NOP ; /
+


freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+

RoutineStart:        ; Don't remove label
LDA !RAM_DecCoins
BEQ EndDec
LDA $0F34|!addr
ORA $0F35|!addr
if !coin_count != 4
ORA $0F36|!addr
endif
BEQ EndDec
REP #$20
LDA !RAM_DecCoins
DEC
STA !RAM_DecCoins
SEP #$20
LDA #$FF
DEC $0F34|!addr
CMP $0F34|!addr
BNE EndDec
DEC $0F35|!addr
if !coin_count != 4
CMP $0F35|!addr
BNE EndDec
DEC $0F36|!addr
endif
EndDec:

LDA $13CC|!addr
BEQ NoInc

IncCoins:
DEC $13CC|!addr
if !coin_count != 4
LDA #$FF
CMP $0F34|!addr
BNE NotMaxedOut
CMP $0F35|!addr
BNE NotMaxedOut
CMP $0F36|!addr
BNE NotMaxedOut
STZ $13CC|!addr
BRA EndInc

NotMaxedOut:
endif

if !coin_count == 5

LDA $0F36|!addr
CMP #$01
BCC NotMax
REP #$20
LDA $0F34|!addr
CMP #$869F
BCC NotMax
LDA #$869F
STA $0F34|!addr
SEP #$20
BRA EndInc
NotMax:
SEP #$20

endif

if !coin_count == 4
REP #$20
LDA $0F34|!addr
CMP #$270F
BCC NotMax
LDA #$270F
STA $0F34|!addr
SEP #$20
BRA EndInc
NotMax:
SEP #$20
endif

INC $0F34|!addr      ; $0F34 = Lowest 256 values.
BNE EndInc
INC $0F35|!addr      ; $0F35 = Lowest 65536 values.
if !coin_count != 4
BNE EndInc
INC $0F36|!addr      ; $0F36 = All 1000000 values
endif
EndInc:
LDA $00
JML $008F32

NoInc:
JML $008F3B

ZeroDec:
STA $7F8000
LDA #$0000
STA !RAM_DecCoins
RTL

SaveSRAMRoutine:
JSR GetSaveFile

LoadScoreData:

LDA $0F34|!addr,y      ; Transfer coin counter data over...
STA $00079F|!sram,x    ; to SRAM data. ($0007FD - $0007FF) + $700000 or $41C000 (normal, SA-1)
INX
INY
CPY #32
BCC LoadScoreData
LDX $010A|!addr
LDA $009CCB,x
RTL

LoadSRAMRoutine:

PHX
PHY
SEP #$10
JSR GetSaveFile

LoadSRAMData:

LDA $00079F|!sram,x       ; Transfer SRAM data...
STA $0F34|!addr,y         ; over to coin counter data.
INX
INY
CPY #32
BCC LoadSRAMData
REP #$10
PLY
PLX
LDA !sram,x
RTL

if !ClearCoinOnGameOver
	STZSRAMWhenGameOver:
		JSR GetSaveFile

	StoreZeroIntoSRAM:
		LDA #$00
		STA $0F34|!addr,y         ; Set coins to zero.
		STA $00079F|!sram,x       ; Set coins in SRAM to zero.
		INX
		INY
		CPY #32
		BCC StoreZeroIntoSRAM
		LDA #$0A
		STA $1DFB|!addr
		RTL 
endif

GetSaveFile:
LDA $010A|!addr
ASL
ASL
ASL
ASL
ASL
TAX
LDY #0
RTS

ZeroCoins:

if !ShowZeroes
if !coin_count == 5
CPX #$01
BCC BlankAtStart
endif
if !coin_count == 4
CPX #$02
BCC BlankAtStart
endif
STZ $0F29|!addr,x
RTL

if !coin_count != 6
BlankAtStart:
LDA #$FC
STA $0F29|!addr,x
RTL
endif
endif

if !ShowZeroes == 0
LDA #$FC		; hijacked routine
STA $0F29|!addr,x

LDA $0F34|!addr
ORA $0F35|!addr
ORA $0F36|!addr	; if you have 0 coins...
BNE DontStoreZero	; put "0" on the status bar
STZ $0F2E|!addr	; 0 for the first digit
DontStoreZero:
RTL
endif

