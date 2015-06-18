Click or tap for a little jump and to add a nunchuck.
Press any key or two-finger tap for a big jump.
Click or tap and drag to toss the nunchucks salad.

The interesting bits:
    - wiggleStuffWithMagnitude: applys a random impulse that favors "up" to make the nunchucks jump.
    - The mouse dragging thing was interesting. I wanted to make the nunchucks avoid the mouse if the mouse was down.  The easiest way I could find to do that was to make a clear node for collisions and move that around with the mouse / gesture.
    - The nunchucks consist of two SKNodes connected by a SKPhysicsJointPin.  You can limit the joint's range of motion by setting the AngleLimit properties.
    - collisionBitMask and categoryBitMask control what can collide with what.

