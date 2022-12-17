"Lower Volume When Pausing" patch by KevinM
Version 1.1

How to use:
- Pick the folder relative to the version of AddmusicK you're using.
- Put all the .txt files ("11 Pause.txt", "12 Unpause.txt" and for 1.0.8 also "12 Unpause (silent).txt") in the folder "AddmusicK/1DF9/" (replacing the original ones).
- Run AddmusicK.
- Patch "startselectsfx.asm" with asar (this is needed so if you exit a level using start+select, the music doesn't stay silent). NOTE: the 1.0.8 folder doesn't have this file, because you don't need to patch anything in this case: AMK 1.0.8 already includes it.

Note:
Doesn't work well with Addmusic 1.0.7 + SA-1, if you Start+Select out of the level, the game will randomly play pause sound, unintentionally lowering volume (during OW or after level load)