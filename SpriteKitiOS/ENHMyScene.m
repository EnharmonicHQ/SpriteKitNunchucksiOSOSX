//
//  ENHMyScene.m
//  SpriteKitiOS
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHMyScene.h"
#import "ENHBaseSceneProtected.h"
#import <CoreMotion/CoreMotion.h>

@interface ENHMyScene ()

@property(nonatomic, retain)CMMotionManager *motionManager;

@end

@implementation ENHMyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:0.15f green:0.15f blue:0.3f alpha:1.0f];
        self.motionManager = [[CMMotionManager alloc] init];
        if (self.motionManager.isDeviceMotionAvailable)
        {
            [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
        }
        else
        {
            self.motionManager = nil;
        }
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    if (self.motionManager != nil && self.motionManager.isDeviceMotionActive)
    {
        CMDeviceMotion *deviceMotion = [self.motionManager deviceMotion];
        CMAcceleration gravity = deviceMotion.gravity;
//        NSLog(@"Gravity.x = %f Gravity.y = %f Gravity.z = %f", gravity.x, gravity.y, gravity.z);
        self.physicsWorld.gravity = (CGVector) {.dx = gravity.x * 9.8, .dy = gravity.y * 9.8};
    }
}

-(void)wiggleStuffWithMagnitude:(CGFloat)magnitude
{
    NSMutableArray *nodes = [[self children] mutableCopy];
    [nodes removeObjectIdenticalTo:self.mouseNode]; //keep from wiggling the mouse node
    for (SKNode *node in nodes)
    {
        SKPhysicsBody *physicsBody = node.physicsBody;

        CGVector gravity = self.physicsWorld.gravity;

        CGFloat dx = myRand(-magnitude * gravity.dx, magnitude * gravity.dx);
        CGFloat dy = myRand(-magnitude * gravity.dx, magnitude * gravity.dx);

        CGVector impulseVector = (CGVector) {.dx = dx, .dy = dy};
        [physicsBody applyImpulse:impulseVector];

        CGFloat multiplier = 1.0f;
        if (magnitude < 100.0f)
        {
            //spin less at low magnitude (e.g.when clicking)
            multiplier *= (magnitude / 100.0f);
        }
        CGFloat angularImpulse = myRand(-M_PI_2 * multiplier, M_PI_2 * multiplier);
        [physicsBody applyAngularImpulse:angularImpulse];
    }
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
