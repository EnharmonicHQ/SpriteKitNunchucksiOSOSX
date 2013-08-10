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
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
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

-(void)mouseDown:(NSEvent *)theEvent
{

    CGPoint location = [theEvent locationInNode:self];

    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];

    sprite.position = location;
    sprite.scale = 0.5;
    CGSize spriteSize = [sprite size];

    SKPhysicsBody *spriteBody = [SKPhysicsBody bodyWithRectangleOfSize:spriteSize];
    spriteBody.categoryBitMask = shuttlecraftCategory;
    spriteBody.collisionBitMask = shuttlecraftCategory | edgeCategory;
    spriteBody.contactTestBitMask = shuttlecraftCategory | edgeCategory;
    spriteBody.mass = 1;
    [sprite setPhysicsBody:spriteBody];

    [self addChild:sprite];
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}


#pragma mark - @protocol SKPhysicsContactDelegate<NSObject>

- (void)didBeginContact:(SKPhysicsContact *)contact;
{
    NSLog(@"%@ %@ %@", self, NSStringFromSelector(_cmd), contact);
}

- (void)didEndContact:(SKPhysicsContact *)contact;
{
    NSLog(@"%@ %@ %@", self, NSStringFromSelector(_cmd), contact);
}


@end
