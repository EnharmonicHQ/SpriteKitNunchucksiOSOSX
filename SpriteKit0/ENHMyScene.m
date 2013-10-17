//
//  ENHMyScene.m
//  SpriteKit0
//
//  Created by Jonathan Saggau on 8/10/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHMyScene.h"
#import "ENHBaseSceneProtected.h"

@implementation ENHMyScene

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
        SKPhysicsJointPin *chuckJoint = [SKPhysicsJointPin jointWithBodyA:spriteOne.physicsBody bodyB:spriteTwo.physicsBody anchor:location];

        chuckJoint.shouldEnableLimits = YES;
        chuckJoint.lowerAngleLimit = -M_PI;
        chuckJoint.upperAngleLimit = M_PI;
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

NSString *enhSpecialPhysicsContactDescription(SKPhysicsContact *physicsThing)
{
    return [[physicsThing description] stringByAppendingFormat:@"\n     bodyA:%@\n     bodyB:%@\n     contactPoint:%@\n     collisionImpulse:%@",
            physicsThing.bodyA, physicsThing.bodyB, NSStringFromPoint((NSPoint)physicsThing.contactPoint), @(physicsThing.collisionImpulse)];
}


@end
