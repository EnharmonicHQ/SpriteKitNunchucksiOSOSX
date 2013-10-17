//
//  ENHMyScene.m
//  SpriteKit0
//
//  Created by Jonathan Saggau on 8/10/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHMyScene.h"


static const uint32_t edgeCategory = 0x1 << 1;
static const uint32_t chuckCategory = 0x1 << 2;
static const uint32_t mouseCategory = 0x1 << 3;


@interface ENHMyScene () <SKPhysicsContactDelegate>

@property BOOL contentCreated;
@property SKSpriteNode *mouseNode;

@end

@implementation ENHMyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:0.15f green:0.15f blue:0.3f alpha:1.0f];
    }
    return self;
}

static const BOOL showMouseNode = YES;
-(void)createSceneContents
{
    self.scaleMode = SKSceneScaleModeAspectFit;

    // Give the scene an edge and configure other physics info on the scene.
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsWorld.gravity = (CGVector) {.dx = 0.0f, .dy = -9.8f};
    self.physicsWorld.contactDelegate = self;

    CGSize mouseSize = (CGSize) {120.f, 120.f};
    self.mouseNode = [SKSpriteNode spriteNodeWithColor:showMouseNode ? [[SKColor lightGrayColor] colorWithAlphaComponent:0.5]:[SKColor clearColor] size:mouseSize];
    SKPhysicsBody *spriteBody = [SKPhysicsBody bodyWithRectangleOfSize:mouseSize];
    spriteBody.categoryBitMask = mouseCategory;
    spriteBody.mass = 2;
    spriteBody.restitution = 0.0f; //bouncy bouncy
    spriteBody.collisionBitMask = mouseCategory;
    spriteBody.affectedByGravity = NO;
    self.mouseNode.physicsBody = spriteBody;
}

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

// Useful random functions.
static inline CGFloat myRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat myRand(CGFloat low, CGFloat high) {
    return myRandf() * (high - low) + low;
}

-(void)wiggleStuffWithMagnitude:(CGFloat)magnitude
{
    NSMutableArray *nodes = [[self children] mutableCopy];
    [nodes removeObjectIdenticalTo:self.mouseNode]; //keep from wiggling the mouse node
    for (SKNode *node in nodes)
    {
        SKPhysicsBody *physicsBody = node.physicsBody;

        CGFloat dx = myRand(-magnitude, magnitude);
        CGFloat dy = myRand(0, magnitude * 9.8); //Favor "up..." against gravity.

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

- (void)keyDown:(NSEvent *)theEvent;
{
    [self wiggleStuffWithMagnitude:300.0f];
}

-(SKNode *)makeNunchuckAtLocation:(CGPoint)location withBackgroundColor:(SKColor *)backgroundColor withStrokeColor:(SKColor *)strokeColor
{
    SKShapeNode *chuck = [SKShapeNode node];
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect chuckRect = (CGRect) {{.x = 0.0, .y = 0.0}, {.width = 110, .height = 20}};
    CGPathRef path = CGPathCreateWithRect(chuckRect, &transform);
    chuck.path = path;
    chuck.fillColor = backgroundColor;
    chuck.strokeColor = strokeColor;
    chuck.lineWidth = 2.0f;
    chuck.position = location;

    SKPhysicsBody *chuckBody = [SKPhysicsBody bodyWithRectangleOfSize:chuckRect.size];
    chuckBody.categoryBitMask = chuckCategory;
    chuckBody.mass = 1;
    chuckBody.restitution = 0.0f; //bouncy bouncy
    chuckBody.linearDamping = 0.0f; //friction
    chuckBody.collisionBitMask = chuckCategory | mouseCategory | edgeCategory;
    chuck.physicsBody = chuckBody;
    return chuck;
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

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

#pragma mark - @protocol SKPhysicsContactDelegate<NSObject>

NSString *enhSpecialPhysicsContactDescription(SKPhysicsContact *physicsThing)
{
    return [[physicsThing description] stringByAppendingFormat:@"\n     bodyA:%@\n     bodyB:%@\n     contactPoint:%@\n     collisionImpulse:%@",
            physicsThing.bodyA, physicsThing.bodyB, NSStringFromPoint((NSPoint)physicsThing.contactPoint), @(physicsThing.collisionImpulse)];
}

- (void)didBeginContact:(SKPhysicsContact *)contact;
{
    //    Log this if you want to see when stuff collides
    //    NSString *description = enhSpecialPhysicsContactDescription(contact);
}

- (void)didEndContact:(SKPhysicsContact *)contact;
{
    //    NSString *description = enhSpecialPhysicsContactDescription(contact);
}


@end
