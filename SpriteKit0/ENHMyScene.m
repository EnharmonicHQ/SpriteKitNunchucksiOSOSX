//
//  ENHMyScene.m
//  SpriteKit0
//
//  Created by Jonathan Saggau on 8/10/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHMyScene.h"


static const uint32_t edgeCategory = 0x1 << 1;
static const uint32_t shuttlecraftCategory = 0x1 << 2;
static const uint32_t chuckCategory = 0x1 << 3;
static const uint32_t mouseCategory = 0x1 << 4;


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

-(void)createSceneContents
{
    self.scaleMode = SKSceneScaleModeAspectFit;

    // Give the scene an edge and configure other physics info on the scene.
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsWorld.gravity = (CGPoint) {0.0f, -9.8f};
    self.physicsWorld.contactDelegate = self;

    CGSize mouseSize = CGSizeMake(120.f, 120.f);
    self.mouseNode = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:mouseSize];
    SKPhysicsBody *spriteBody = [SKPhysicsBody bodyWithRectangleOfSize:mouseSize];
    spriteBody.categoryBitMask = mouseCategory;
    spriteBody.mass = 2;
    spriteBody.restitution = 0.0f; //bouncy bouncy
    spriteBody.collisionBitMask = shuttlecraftCategory;
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
    NSArray *nodes = [self children];
    for (SKNode *node in nodes)
    {
        SKPhysicsBody *physicsBody = node.physicsBody;

        CGFloat dx = myRand(-magnitude, magnitude);
        CGFloat dy = myRand(0, magnitude * 9.8); //Favor "up..." against gravity.
        
        CGVector impulseVector = CGVectorMake(dx, dy);
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
    CGRect chuckRect = CGRectMake(0, 0, 110, 20);
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
    chuckBody.collisionBitMask = chuckCategory | shuttlecraftCategory | mouseCategory | edgeCategory;
    chuck.physicsBody = chuckBody;
    return chuck;
}

-(SKNode *)makeShuttlecraftAtLocation:(CGPoint)location
{
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];

    sprite.position = location;
    sprite.scale = 0.25f;
    CGSize spriteSize = [sprite size];

    SKPhysicsBody *spriteBody = [SKPhysicsBody bodyWithRectangleOfSize:spriteSize];
    spriteBody.categoryBitMask = shuttlecraftCategory;
    spriteBody.collisionBitMask = shuttlecraftCategory | mouseCategory | edgeCategory; //collide with edge of scene and other shuttlecraft
    spriteBody.contactTestBitMask = shuttlecraftCategory | mouseCategory; //Let us know when a shuttlecraft collides with another only (add | edgeCategory to get notifications at edge, too)
    spriteBody.mass = 1;
    spriteBody.restitution = .45f; //bouncy bouncy
    spriteBody.linearDamping = 0.3f; //friction
    sprite.physicsBody = spriteBody;
    return sprite;
}

-(void)mouseUp:(NSEvent *)theEvent
{
    if (![self.mouseNode parent])
    {
        CGPoint location = [theEvent locationInNode:self];
        if(myRand(0.0f, 1.0f) < 0.5)
        {
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
        }
           else
        {
            [self makeShuttlecraftAtLocation:location];
        }
        [self wiggleStuffWithMagnitude:40.0f];
    }
    else
    {
        [self.mouseNode removeFromParent];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent
{
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
//    NSString *description = enhSpecialPhysicsContactDescription(contact);
}

- (void)didEndContact:(SKPhysicsContact *)contact;
{
//    NSString *description = enhSpecialPhysicsContactDescription(contact);
}


@end
