=TODO=

- Change collision on paddle to manual -- just look at y of ball and if it collided (for pills and ball -- you can then remove collisions on pill entirely)
✅- Remove life if ball falls too low
✅- Start with ball stuck to paddle and button press to release
- Limit number of gun shots at any time

- Powerups:
✅    - Sticky
✅    - Extra life
    - Multi
    - Bomb
✅    - Flip
✅    - Shrink
    - Laser (can go through metal?)
✅    - SLOW
✅    - Animation when you get a powerup?


- Home Splash Screen, start timer?
- Create 5 Levels and screens between them

✅- Game goes faster and faster as time passes
- Bricks come down as time passes (only goes so far)

- Right now we have an issue that if you shoot, and then restart level, the gun shots keep propagating

- Speed up timer happens right away, but shoudl start when you first shoot the ball
- Test speed up timer at highest speeds. Is it too fast?


- Now with MULTI ball, we need to count the number of active balls before we decrement life
- Remove ball and replace entirely with multiball array
✅- Spreading from the highest ball isn't working. Height is in inverse. Are we doing it right?
- Sticky doesn't work with multiball