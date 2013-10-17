//
//  ENHScene.m
//  SpriteKit0
//
//  Created by Jonathan Saggau on 10/17/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHScene.h"
#import "ENHSceneProtected.h"

static const uint32_t edgeCategory = 0x1 << 1;
static const uint32_t chuckCategory = 0x1 << 2;
static const uint32_t mouseCategory = 0x1 << 3;

@interface ENHScene () <SKPhysicsContactDelegate>

@property BOOL contentCreated;
@property SKNode *mouseNode;

@end

@implementation ENHScene

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
#if TARGET_OS_IPHONE
    CGSize mouseSize = (CGSize) {24.f, 24.f};
#else
    CGSize mouseSize = (CGSize) {120.f, 120.f};
#endif
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

-(SKNode *)makeNunchuckAtLocation:(CGPoint)location withBackgroundColor:(SKColor *)backgroundColor withStrokeColor:(SKColor *)strokeColor
{
    SKShapeNode *chuck = [SKShapeNode node];
    CGAffineTransform transform = CGAffineTransformIdentity;
#if TARGET_OS_IPHONE
    CGFloat width = 44.0f;
    CGFloat height = 8.0f;
    CGFloat lineWidth = 1.0f;
#else
    CGFloat width = 110.0f;
    CGFloat height = 20.0f;
    CGFloat lineWidth = 2.0f;
#endif
    CGRect chuckRect = (CGRect) {{.x = 0.0, .y = 0.0}, {.width = width, .height = height}};
    CGPathRef path = CGPathCreateWithRect(chuckRect, &transform);
    chuck.path = path;
    chuck.fillColor = backgroundColor;
    chuck.strokeColor = strokeColor;
    chuck.lineWidth = lineWidth;
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


-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

#pragma mark - @protocol SKPhysicsContactDelegate<NSObject>


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
