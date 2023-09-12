## TODO

### HIGH

- Way less bricks in lower levels -- too hard
- Create first 5 Levels and screens between them
- When you finish a level the balls don't reset (they are just floating where they were before)
- Create 25 levels
- Better end game
- Say something on death
- You should not be able to sit sticky and shoot as much as you want. Either have a shoot timer, or prevent guns + sticky or something...

---

### Medium

- Use timers for places where we are currently capturing the time (I didn't know they existed https://sdk.play.date/1.12.1/Inside%20Playdate.html#C-timer)
- Save state of game on suspend resume https://sdk.play.date/1.12.1/Inside%20Playdate.html#saving-state
- Use total bounces to calculate speed, instead of time elapsed
- Store high scores

---

### Low

- More Powerups:
  - Bomb
  - Laser (can go through metal?)
  - Something else?
  - Backup wall below the paddle that breaks after it is hit but can save you one time

## Bugs

- Ball can go through the very right side of the paddle if it is right at the edge
- was able to get a ball to bounce side to side and never come down
- Right now we have an issue that if you shoot, and then restart level, the gun shots keep propagating

## Consider / Ideas

- Should we make each pill say what it does as it rolls down?
- Comment code better
- Level file format?
- Ideally render all the stuff on the right side into a sprite so it's not drawn over and over
  https://devforum.play.date/t/90-rotatable-text/3325/4
- probably need to split bullet into two bullets
- Should speed progress if you are stuck to paddle -- you could be shooting. Maybe we should stop time even so
- Manually calculating pill collisions will allow us to remove collisions with paddle completely, saving computation
- Double paddle mode -- paddle turns into two paddles
- Bricks should come down as time passes (but only go so far)
- Specify where pills are stored
- Animate paddle's movement, even though it can move by large #'s, just to make it smoother? Or will this create lag?

---

## Completed

✅- Remove life if ball falls too low
✅- Start with ball stuck to paddle and button press to release
✅- Limit number of gun shots at any time -- it's too easy to shoot fast
✅ - Sticky
✅ - Extra life
✅ - Multi
✅ - Flip
✅ - Shrink
✅ - SLOW
✅ - Animation when you get a powerup?
✅- Game goes faster and faster as time passes
✅- Now with MULTI ball, we need to count the number of active balls before we decrement life
✅- Spreading from the highest ball isn't working. Height is in inverse. Are we doing it right?
✅- Sticky doesn't work with multiball, and sometimes gets stuck on edge -- just turned it off blah
✅- Speed up timer happens right away, but shoudl start when you first shoot the ball
✅- Gun bullet sprite is ugly
✅- Different name
✅- Home Splash Screen
✅- Remove ball and replace entirely with multiball array
✅- Show speed somehow in a guage
✅- Test speed up timer at highest speeds. Is it too fast? no it's ok
✅- When there are multiple balls shown on the screen, and you shoot, they all shoot upwards, even if not on the paddle
✅- was able to grab sticky on multi and some balls stuck in the middle of the sky - Need to remove concept of "isStuck" to paddle and move it to the ball
✅- balls once stuck don't move with paddle
✅- Sticky -- if you keep moving to edge it goes off teh edge and weird stuff happens
✅- Change collision on paddle to manual -- just look at y of ball and if it collided
✅- Fake Homescreen
✅- Fake custscenes
✅- At top speed, the ball sometimes goes through the paddle
✅-- Don't shoot if the ball is stuck to paddle
✅-- Real Home Screen
