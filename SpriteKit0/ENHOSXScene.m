//
//  ENHMyScene.m
//  SpriteKitMavericks
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHOSXScene.h"
#import "ENHBaseSceneProtected.h"

@implementation ENHOSXScene

- (void)keyDown:(NSEvent *)theEvent;
{
    [self wiggleStuffWithMagnitude:300.0f];
}

-(void)mouseUp:(NSEvent *)theEvent
{
    if (![self.mouseNode parent])
    {
        //Make a new chuck if the mouse wasn't dragging around (mouse node has no parent)
        CGPoint location = [theEvent locationInNode:self];
        SKNode *spriteOne = [self makeNunchuckAtLocation:location withBackgroundColor:[SKColor greenColor] withStrokeColor:[SKColor blackColor]];
        location.x += spriteOne.frame.size.width;
        SKNode *spriteTwo = [self makeNunchuckAtLocation:location withBackgroundColor:[SKColor redColor] withStrokeColor:[SKColor blackColor]];
        [self addChild:spriteOne];
        [self addChild:spriteTwo];
        location.x -= spriteOne.frame.size.width / 2.f;

        SKPhysicsJointPin *chuckJoint = [SKPhysicsJointPin jointWithBodyA:spriteOne.physicsBody bodyB:spriteTwo.physicsBody anchor:location];

        chuckJoint.frictionTorque = 0.2;
        SKPhysicsWorld *world = [self physicsWorld];
        [world addJoint:chuckJoint];
        [self wiggleStuffWithMagnitude:40.0f];
    }
    else
    {
        [self.mouseNode removeFromParent];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    //Move the clear mouse node around
    CGPoint location = [theEvent locationInNode:self];
    self.mouseNode.position = location;
    if (![self.mouseNode parent])
    {
        [self addChild:self.mouseNode];
    }
}

@end
