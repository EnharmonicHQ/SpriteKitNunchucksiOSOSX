//
//  ENHMyScene.m
//  SpriteKitiOS
//
//  Created by Jonathan Saggau on 10/17/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHMyScene.h"
#import "ENHSceneProtected.h"

@implementation ENHMyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:0.15f green:0.15f blue:0.3f alpha:1.0f];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)theEvent
{
    if ([touches count] > 1)
    {
        [self wiggleStuffWithMagnitude:300.0f];
    }
    else
    {
        if (![self.mouseNode parent])
        {
            UITouch *touch = [touches anyObject];
            //Make a new chuck if the mouse wasn't dragging around (mouse node has no parent)
            CGPoint location = [touch locationInNode:self];
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
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)theEvent
{
    //Move the clear mouse node around
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    self.mouseNode.position = location;
    if (![self.mouseNode parent])
    {
        [self addChild:self.mouseNode];
    }
}

NSString *enhSpecialPhysicsContactDescription(SKPhysicsContact *physicsThing)
{
    return [[physicsThing description] stringByAppendingFormat:@"\n     bodyA:%@\n     bodyB:%@\n     contactPoint:%@\n     collisionImpulse:%@",
            physicsThing.bodyA, physicsThing.bodyB, NSStringFromCGPoint(physicsThing.contactPoint), @(physicsThing.collisionImpulse)];
}

@end
