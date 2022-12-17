if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
else
	lorom
	!addr = $0000
	!bank = $800000
endif

org $00A284
	autoclean JML PlaySfx
	nop

freedata

PlaySfx:
	lda #$08
	sta $1DFA|!addr
	lda #$0B
	sta $0100|!addr
	jml $00A289|!bank
