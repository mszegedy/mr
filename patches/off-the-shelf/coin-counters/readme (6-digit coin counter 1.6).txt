------------------------------
6 DIGIT COIN COUNTER PATCH
VERSION 1.6
==============================

Q: What will this patch do?
A: It will apply a 6 digit coin counter to your hack.
They will use the score tiles - the 2 digit coin counter
will be removed.
There is seperate SRAM support for each save file.
This means that when you get a save prompt, everything will be saved.

Q: Do I need to credit someone?
A: If you wish to, credit Ringodoggie, HyperHacker, Roy, and/or imamelia.

--------
VERSIONS
--------

Asar, version 1.6a:
By Vitor Vilela. Converted & merged patches to Asar and added hybrid SA-1 support.

Xkas, version 1.6:
By imamelia.  Removed the hijack that resets the counter to 0 during game over.  (Why did the original author even do this in the first place?)

Xkas, version 1.5:
By imamelia.
Made it possible to choose whether leading zeroes should be displayed or not, added a 16-bit "decrease coins" RAM address, implemented better overflow handling, and added to the .zip folder a patch made by Roy that disables all score sprites other than 1UP, 2UP, 3UP, and 5UP from ever being shown.

Xkas, version 1.4:
By imamelia.
Slightly modified the code so that leading zeroes don't show up on the status bar.  (For example, a coin amount of 1043 coins will show up as 1043, not 001043.)

Xkas, version 1.3:
By Roy.
Fixed a few errors in the code, compressed the code
slightly, fixed a nasty bug that occured when having
a negative amount of coins (128-255) and getting a Dragon
Coin thereafter.

Xkas, version 1.2:
By HyperHacker.
Added to the SRAM support routine, to make use of different
values per save file, so that one save file does not affect
the other.

Xkas, version 1.1:
By Roy, a slight change.
SRAM support added, but all files use the same values.

Xkas, version 1.0:
By Roy, almost completely based off Ringodoggie's code.

IPS:
By Ringodoggie. Original patch, 6 digit coin counter.
Did not seem to work for everyone due to IPS format.


