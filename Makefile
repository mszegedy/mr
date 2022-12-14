LM_BIN := /home/mszegedy/lm/bin
ASAR := asar
OTS_PATCHES := patches/off-the-shelf

all: clean mr.smc mr.bps

mr.bps: base.sfc mr.smc
	$(LM_BIN)/flips --create -b base.sfc mr.smc mr.bps

mr.smc: patched.smc finalize.bps
	cp patched.smc mr.smc
  # test-change.bps tweaks lvl 03 in lunar magic to be passable. this is to
  # test this makefile's way of applying lunar magic changes (as incremental
  # patches). seems to work so far.
	$(LM_BIN)/flips --apply --exact test-change.bps mr.smc

patched.smc: base.sfc
	cp base.sfc patched.sfc

  # essentials
	$(ASAR) patches/essentials/sa1/sa1.asm patched.sfc
	$(ASAR) patches/essentials/sram-bwram-plus/LX5\'s\ bwram_plus/bwram_plus.asm \
		patched.sfc

  # uberasm
	$(LM_BIN)/uberasm patches/uberasm.txt patched.sfc

  # add changes made by lm to rom when you do nothing and then save it
	$(LM_BIN)/flips --apply --exact add-lm-headers.bps patched.sfc patched.smc

  # off-the-shelf
	$(ASAR) $(OTS_PATCHES)/dcsave/dcsave.asm patched.smc
	$(ASAR) $(OTS_PATCHES)/Disable_Timer.asm patched.smc
	$(ASAR) $(OTS_PATCHES)/coin-counters/coincounter_1.6.asm patched.smc
	$(ASAR) $(OTS_PATCHES)/coin-counters/disablescoresprites.asm patched.smc
	$(ASAR) $(OTS_PATCHES)/OffscreenIndicatorPatch.asm patched.smc
	$(ASAR) $(OTS_PATCHES)/ultimate-teleporter/UltimateTeleporter.asm patched.smc
	$(ASAR) patches/tweaks.asm patched.smc

clean:
	rm patched.sfc patched.smc mr.smc mr.bps ||:
	rm *.srm *.000 *.bst ||:
