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


@interface ENHMyScene () <SKPhysicsContactDelegate>

@property BOOL contentCreated;

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
}


- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

-(SKSpriteNode *)makeShuttlecraftAtLocation:(CGPoint)location
{
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];

    sprite.position = location;
    sprite.scale = 0.5f;
    CGSize spriteSize = [sprite size];

    SKPhysicsBody *spriteBody = [SKPhysicsBody bodyWithRectangleOfSize:spriteSize];
    spriteBody.categoryBitMask = shuttlecraftCategory;
    spriteBody.collisionBitMask = shuttlecraftCategory | edgeCategory; //collide with edge of scene and other shuttlecrafts
    spriteBody.contactTestBitMask = shuttlecraftCategory ; //Let us know when shuttlecraft collides with another only (add | edgeCategory to get notifications at edge, too)
    spriteBody.mass = 1;
    spriteBody.restitution = .45f; //bouncy bouncy
    sprite.physicsBody = spriteBody;
    return sprite;
}

// Useful random functions.
static inline CGFloat myRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat myRand(CGFloat low, CGFloat high) {
    return myRandf() * (high - low) + low;
}

-(void)wiggleStuff
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSArray *nodes = [self children];
    NSLog(@"NODES: %@", nodes);
    for (SKNode *node in nodes)
    {
        CGFloat zRotation = node.zRotation;
        NSLog(@"zRotation : %@", @(zRotation));
        SKPhysicsBody *physicsBody = node.physicsBody;
        NSLog(@"physicsBody: %@", physicsBody);

        CGFloat dx = myRand(-1000, 1000);
        CGFloat dy = myRand(0, 1000*9.8);
        
        CGVector impulseVector = CGVectorMake(dx, dy);
        NSLog(@"impulseVector: {%@, %@}", @(impulseVector.dx), @(impulseVector.dy));
        [physicsBody applyImpulse:impulseVector];

        CGFloat angularImpulse = myRand(-M_PI_4, M_PI_4);
        [physicsBody applyAngularImpulse:angularImpulse];
    }
}

- (void)keyDown:(NSEvent *)theEvent;
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), theEvent);
    [self wiggleStuff];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    CGPoint location = [theEvent locationInNode:self];

    SKSpriteNode *sprite = [self makeShuttlecraftAtLocation:location];
    [self addChild:sprite];
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
    NSString *description = enhSpecialPhysicsContactDescription(contact);
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), description);
}

- (void)didEndContact:(SKPhysicsContact *)contact;
{
    NSString *description = enhSpecialPhysicsContactDescription(contact);
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), description);
}


@end
