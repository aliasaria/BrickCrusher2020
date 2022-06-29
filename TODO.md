=TODO=

- Sticky -- if you keep moving to edge it goes off teh edge and weird stuff happens
- Change collision on paddle to manual -- just look at y of ball and if it collided (for pills and ball -- you can then remove collisions on pill entirely)
- probably need to split bullet into two bullets
- Say something on death
- Show speed somehow in a guage
- Powerups:

    - Bomb
     - Laser (can go through metal?)

- Create 5 Levels and screens between them
- Create 25 levels
- Better end game

- Bricks come down as time passes (only goes so far)

- Right now we have an issue that if you shoot, and then restart level, the gun shots keep propagating

- Test speed up timer at highest speeds. Is it too fast?



Considerations:
- Should we make each pill say what it does?
- Comment code
- Level file format?



DONE
✅- Remove life if ball falls too low
✅- Start with ball stuck to paddle and button press to release
✅- Limit number of gun shots at any time -- it's too easy to shoot fast
✅    - Sticky
✅    - Extra life
✅    - Multi
✅    - Flip
✅    - Shrink
✅    - SLOW
✅    - Animation when you get a powerup?
✅- Game goes faster and faster as time passes
✅- Now with MULTI ball, we need to count the number of active balls before we decrement life
✅- Spreading from the highest ball isn't working. Height is in inverse. Are we doing it right?
✅- Sticky doesn't work with multiball, and sometimes gets stuck on edge -- just turned it off blah
✅- Speed up timer happens right away, but shoudl start when you first shoot the ball
✅- Gun bullet sprite is ugly
- Different name
- Home Splash Screen
- Remove ball and replace entirely with multiball array
