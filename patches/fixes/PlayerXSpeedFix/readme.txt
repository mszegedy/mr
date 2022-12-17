Player X speed fix patch, by GreenHammerBro and tjb.

This is multiple fixes combined into one patch.

The original game doesn't let you jump if you're moving too fast (≥64 speed), even though
it plays the jump sound. This will fix that.

The oscillation fix will fix the way Mario's X speed bounces up and down around the maximum
speed, rather than capping out at exactly the maximum.
(http://tasvideos.org/GameResources/SNES/SuperMarioWorld.html#ExplanationOfOscillatingSpeeds)
This makes some setups (such as keeping slope speed, throwing sprites while running, or 
jumping with P-speed) much more consistent.

The deceleration fix removes a quirk where if you're moving over your maximum speed, (e.g.
because you were shot out of a diagonal pipe, or a custom boost block set your speed higher
than max) holding forward would drain your speed back down to its maximum. Instead, holding
forward will maintain your speed as if you were to keep the d-pad neutral.

Setting !GroundDecel to 0 will allow you to maintain your excess speed even while you're on
the ground, which would normally be impossible.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
The impact to the physics from removing the speed oscillation bug is extremely negligible,
other than the (very minor) fact that mashing B to slow down with cape will actually properly
enforce its intended maximum backwards speed of 8, rather than putting you randomly in the
oscillation of 7-13 speed. Enabling this patch makes backwards fly less effective and more
risky. Even more minor than that is that the intended maximum speed of cape is enforced at
48, rather than the slightly faster 47-51 speed oscillation.

Also worth noting is that fixing speed oscillation actually fixes a bug in very steep slopes:
When running against it, it's supposed to cap your downhill speed at 8, but the decelerate
routine is coded to slow you down toward the autoslide speed, which is 32 on very steep
slopes. Therefore, as soon as it sees that you're over the max speed of 8, it tries to slow
you down, but the code that slows you down ends up making you faster (toward 32). So both
decelerating and accelerating do the same thing, until you're 32 speed. With speed
oscillation removed, the cap of 8 speed is actually properly enforced. (at least unless
something puts you at 9+ speed downhill)

There are a few different things that call this hijacked acceleration routine, so the
deceleration fix only specifically applies where it should. For example, letting go of X/Y
or climbing uphill on a slope will still slow you down, as intended, and sliding on a slope
will always have you tend toward the intended sliding speed.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
The reason you can't jump with ≥64 speed is because when you jump, it references a table
indexed by your X speed to see what it should set your Y speed to, but the table is too
short, and while moving too fast, it indexes outside of the table and into another table of
deceleration values, most of which set your Y speed to 0, 1 or -1. This patch simply provides
a bigger table to support all possible X speed values.

Speed oscillation happens because of the strange way SMW caps out your speed. As long as
you're holding a direction on the D-pad, it'll always either add to or subtract from your
speed every frame, even if you're already moving at exactly the max. If your current speed
is greater than or equal to the maximum,  it'll slow you down. Else, if your current speed
is less than the maximum, it'll speed you up. This keeps happening in a loop, increasing and
decreasing your speed above and below the maximum over and over. The fix is to do another
check after adding to the speed, to clamp your speed to exactly the maximum, and then keep
it there by not touching the speed if it's already at max.

With this hijack, we can also change the way excess amounts of speed are handled. In the
original game, it'll jump to the decelerate routine every frame that your speed is greater
than or equal to the max while holding forward on the D-pad. Simply disabling this does cause
some issues with how slopes are supposed to work, so I added a table based on why the
acceleration routine is being called in the first place, to determine whether or not it
should jump to the deceleration routine to slow you down toward the max.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
And yes, this is a sa-1 hybrid (meaning that this patch will work on normal and sa-1 rom).

If you want to modify the Y speed jumping based on how fast you are running, open the patch
asm file and CTRL+F "How X speed affects your jump" and read from there.

If you modify the player's maximum speed for walking and running, simply edit the table
located at $00D535. The patch has been updated to actually modify to skip the deceleration
and use smw's speed table.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Version history:

3/5/2016
	-begin working on this patch.
3/8/2016
	-Added a jump fix (the inablity to jump if going in certain speeds), despite the sfx
	 playing.
2/14/2017
	-Truly fixed the mario x speed slowdown code (now hijacks actual code that
	 decelerates him; $00D742). 
	-Also fix a glitch to make it so that if the player reaches max speed, stays in lock
	 in that value rather than "shaking", causing a consistent speed.
2/15/2017
	-Added note that if the hacker wanted decelerations on ground, the value would be
	 shaking again.
2/28/2017
	-Fixed mario was able to maintain swim speed after releasing a carrying object.
10/15/2020
	-Complete rewrite of FixSpeed by tjb
	-Fixed speed oscillation still happening with !GroundDecel enabled
	-Fixed some slope-related bugs with !GroundDecel disabled
	-Fixed letting go of X/Y not slowing you down to walking speed
	-Added comments to make the jump Y speed table easier to edit
	-Added settings to enable/disable certain parts of the patch