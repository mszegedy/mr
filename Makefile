LM_BIN := /home/mszegedy/lm/bin
ASAR := asar
OTS_PATCHES := patches/off-the-shelf

all: clean mr.sfc mr.bps

mr.bps: base.sfc mr.sfc
	$(LM_BIN)/flips --create -b base.sfc mr.sfc mr.bps

mr.sfc: patched.sfc finalize.bps
	$(LM_BIN)/flips --apply --exact finalize.bps patched.sfc mr.sfc

patched.sfc: base.sfc
	cp base.sfc patched.sfc

  # essentials
	$(ASAR) patches/essentials/sa1/sa1.asm patched.sfc
	$(ASAR) patches/essentials/sram-bwram-plus/LX5\'s\ bwram_plus/bwram_plus.asm \
		patched.sfc

  # uberasm
	$(LM_BIN)/uberasm patches/uberasm.txt patched.sfc

  # off-the-shelf
	$(ASAR) $(OTS_PATCHES)/dcsave/dcsave.asm patched.sfc
	$(ASAR) $(OTS_PATCHES)/Disable_Timer.asm patched.sfc
	$(ASAR) $(OTS_PATCHES)/coin-counters/coincounter_1.6.asm patched.sfc
	$(ASAR) $(OTS_PATCHES)/coin-counters/disablescoresprites.asm patched.sfc
	$(ASAR) $(OTS_PATCHES)/OffscreenIndicatorPatch.asm patched.sfc
	$(ASAR) $(OTS_PATCHES)/ultimate-teleporter/UltimateTeleporter.asm patched.sfc
	$(ASAR) patches/tweaks.asm patched.sfc

clean:
	rm patched.sfc mr.sfc mr.bps ||:
	rm *.srm *.000 *.bst ||:
