# Jump Puzzles

## Using the Jump Scripts
1. Walk to the base of the jump puzzle and start the script.
2. If you fall, but don't fall all the way down, find the number of which jump
you're on and change `JumpNumber` correspondingly to resume from there.

Jumps are VERY server tick dependent, so you may need to run the script multiple
times to reach the top.

## Writing Your Own Jump Puzzles

The jump puzzles in this folder all follow the same template, just replace the
x,y,z coordinates with the ones corresponding to your jump puzzle locations.

To get these x,y,z copy the following SND macro and run it. This will copy your
character's current coordinates to you clipboard, so you can paste it into your
code.
```
x = math.floor(GetPlayerRawXPos()*100)/100
y = math.floor(GetPlayerRawYPos()*100)/100
z = math.floor(GetPlayerRawZPos()*100)/100
SetClipboard("{ x="..x..", y="..y..", z="..z..", wait=0.08 },")
```

The `wait` parameter determines how many seconds of a running start you get
before you jump. Usually the shorter the wait, the shorter the jump.