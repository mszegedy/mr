LM_BIN := /home/mszegedy/lm/bin
ASAR := asar
FIXES := patches/fixes
OTS := patches/off-the-shelf

all: clean mr.smc mr.bps

mr.bps: base.sfc mr.smc
	$(LM_BIN)/flips --create -b base.sfc mr.smc mr.bps

mr.smc: patched.smc
	cp patched.smc mr.smc
  # test-change.bps tweaks lvl 03 in lunar magic to be passable. this is to
  # test this makefile's way of applying lunar magic changes (as incremental
  # patches). seems to work so far.
#	$(LM_BIN)/flips --apply --exact test-change.bps mr.smc

patched.smc: base.smc
	cp base.smc patched.smc

  # essentials
	$(ASAR) patches/essentials/sa1/sa1.asm patched.smc
	$(ASAR) patches/essentials/sram-bwram-plus/LX5\'s\ bwram_plus/bwram_plus.asm \
		patched.smc

  # uberasm
	$(LM_BIN)/uberasm patches/uberasm.txt patched.smc

  # add changes made by lm to rom when you do nothing and then save it
	$(LM_BIN)/flips --apply --exact add-lm-headers.bps patched.smc patched.smc

  # fixes and optimizations
	$(ASAR) $(FIXES)/lavafix_asar.asm patched.smc
	$(ASAR) $(FIXES)/vram_optimize.asm patched.smc
	$(ASAR) $(FIXES)/PlayerXSpeedFix/PlayerXSpeedFix.asm patched.smc

  # off-the-shelf
	$(ASAR) $(OTS)/dcsave/dcsave.asm patched.smc
	$(ASAR) $(OTS)/Disable_Timer.asm patched.smc
	$(ASAR) $(OTS)/coin-counters/coincounter_1.6.asm patched.smc
	$(ASAR) $(OTS)/coin-counters/disablescoresprites.asm patched.smc
	$(ASAR) $(OTS)/OffscreenIndicatorPatch.asm patched.smc
	$(ASAR) $(OTS)/ultimate-teleporter/UltimateTeleporter.asm patched.smc
#	$(ASAR) $(OTS)/maddash/dash.asm patched.smc
	$(ASAR) patches/tweaks.asm patched.smc

  # bespoke
	$(ASAR) patches/bespoke/no-button-aliases.asm patched.smc
	$(ASAR) patches/bespoke/always-running.asm patched.smc

clean:
	rm patched.smc mr.smc mr.bps ||:
	rm *.srm *.000 *.bst ||:
