Requires OS X 10.9; Until 10.9 releases, also requires Xcode with 10.9 SDK from developer.apple.com (manual download).
Not (yet) ported to iOS 7 ;)

Click for a little jump and to add a nunchuck.
Press any key for a big jump.
Click and drag to toss the nunchucks salad.

The interesting bits:
    - wiggleStuffWithMagnitude: applys a random impulse that favors "up" to make the nunchucks jump.
    - The mouse dragging thing was interesting. I wanted to make the nunchucks avoid the mouse if the mouse was down.  The easiest way I could find to do that was to make a clear node and move that around with the mouse.
    - The nunchucks consist of two SKNodes connected by a SKPhysicsJointPin.  You can limit the joint's range of motion by setting the AngleLimit properties.
    - collisionBitMask and categoryBitMask controls what can collide with what.
