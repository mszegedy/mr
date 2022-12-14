Important information and how to use:

First, you'll need level/uberasm installed. If not, this won't work.

This patch will let you use screen exits by walking into them, or it will let you teleport from falling off screen or jumping off the top of the screen if an exit is enabled on the current screen. 

In horizontal levels for the side exits this checks screen 0 and whatever screen happens to be the last one in your level.
In vertical levels since there's always an edge of the screen, any screen can be used to exit from the sides as long as it is enabled on that screen.
The difference between this patch and imamelia's and MarioFanGamer's original patch is that in addition to both types of exits being combined into a single patch:

1. Mario will actually walk off screen before teleporting when exiting from the sides. (Think Yoshi's Island) 
2. You also don't need to manually set a ram address in every level to enable side exits, just editing the table at the bottom of the patch.
3. You don't need to worry about blocking certain sides of the screen you don't want to be used as exits, the patch automatically detects if there's a screen exit before allowing you to warp, otherwise does nothing.
4. If skilled enough with ASM you can use more values in the side or up exit tables. By default #$01 in the side exit table just teleports via the pipe walk animation but for example you can make a level use #$02 and make a different animation happen, set a ram address or anything else you want.
5. This also supports exiting from the top of the screen.

At the bottom of the patch there are 3 different sets of tables, one for enabling teleporting via falling, one for screen side exits, and one for top screen exits.

Example 1 (from MarioFanGamer's original patch):
;.. Level table
;; Change the corresponding bit to 1 to activate teleporting by falling off screen
Table:	db %00000000,%00000001 ; Levels 0-F

The very last bit is marked 1 so teleporting by falling will be enabled in level F

Example 2:
SideExitTable:	
db $00,$00,$00,$00,$00,$00,$00,$01		; levels 00-07

The last byte here is marked with 1, so teleporting via the sides is enabled in level 7.

Again, if any of these settings are enabled but there is no screen exit detected, the bottoms, sides, and tops of the screen will act like they normally do and won't teleport you. So falling will kill you and the screen edges do nothing of course. 

Using the side screen exits will use the horizontal pipe animation, however it will raise Mario a few pixels as if he's still entering a pipe. There is code to disable this effect, while still keeping it for actual pipes, provided you use GHB's player trigger patch here: https://www.smwcentral.net/?p=section&a=details&id=11432

If used, enable the option inside my patch. Then in GHB's patch use a custom value in $71 (#$0E in my patch by default) and have it JML to $00D197. 

So for example in GHB's patch you'll see:
dl Action_0E

Just go to that label and do this:

Action_0E:
JML $00D197

And the pipe centering effect will be removed when exiting from the sides.

Lastly, during the pipe animation code Mario's priority is set to be behind objects while its going. Using the option in the patch to disable it will change this without affecting the pipes. This way you can have background decorations and scenery right in front of the screen exit without going behind it. You also probably shouldn't use a pipe on the same screen an exit is active though (not sure why you'd need to unless its a specially coded one), I'm sure Mario will still appear in front of it otherwise.

To test, side and top exits are enabled in level 104, and falling is enabled in level 105.