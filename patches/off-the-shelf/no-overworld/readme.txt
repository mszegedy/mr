Disables overworld. Original idea by Alcaro, but code is new.

How to use:

- In your Uberasm folder find "other/global_code.asm" (default location) and open it.
- find where it says "main:" and "rts" and copypaste this between them:

	.NoOverworld
	LDA $0100|!addr
	CMP #$10
	BNE +
	JSL NoOverworld_PreLoadLevel ; this happens at gamemode 10 (init)
	+
	CMP #$14
	BNE +
	JSL NoOverworld_DuringLevel ; this happens at gamemode 14 (main)
	+
	CMP #$0C
	BNE +
	JSL NoOverworld_SkipOW ; this happens at gamemode 0C (init)
	+
	.NoOverworld_end

- Now you can copy library/NoOverworld.asm to your library folder (in your Uberasm folder)
- Open NoOverworld.asm to change some settings and apply with UberAsmTool.

-----------------------------------------
To unintall:
-----------------------------------------

- to uninstall, open "NoOverworld.asm" and set !completely_remove = 1.
- Run UberasmTool.
- Now you can remove NoOverworld.asm from your library and open "other/global_code.asm" to erase the inserted code.

-----------------------------------------
Using gamemode instead of global_code
-----------------------------------------
This code applies to global code, alternatively you can insert into gamemode if you know how to:

- Apply to gamemodes 0C, 10 and 14 (for saving at midway or transitions)

	Gamemode 0C
		
		init:
    			JSL NoOverworld_SkipOW
		RTL


	Gamemode 10

		init:
    			JSL NoOverworld_PreLoadLevel
		RTL


	Gamemode 14

		main:
    			JSL NoOverworld_DuringLevel
		RTL


--------------------

Changelog
	v1.2

	- Fixed crash with retry patch
	- Fixed graphic issue when using "VWF intro 1.22"
	- Fixed Player 2 compatiblity with "Exit Block (no OW events)" and "Door exit"
	- More info for coders.txt

	Thanks to Darolac for pointing some of these issues and testing.

	v1.1
	- Supports two players
	- Secret exits(advanced mode)
	- various fixes
	- clean.asm is now integrated in NoOverworld.asm

--------------------
About


No overworld (uberasm version) 1.0 by Brolencho

Inspired by noow.asm by Alcaro, does pretty much the same but different code
and functionality. Tried to make an uberasm version with no hijacks, but there is
one hijack to fix an issue with castle entrance.