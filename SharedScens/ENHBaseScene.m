//
//  ENHScene.m
//  SpriteKit0
//
//  Created by Jonathan Saggau on 10/17/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHBaseScene.h"
#import "ENHBaseSceneProtected.h"
#import "ENHSKTextureMetadata.h"
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif

static const uint32_t edgeCategory = 0x1 << 1;
static const uint32_t chuckCategory = 0x1 << 2;
static const uint32_t mouseCategory = 0x1 << 3;

// Useful random functions.
inline CGFloat myRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

inline CGFloat myRand(CGFloat low, CGFloat high) {
    return myRandf() * (high - low) + low;
}

static inline void enhPushGraphicsContext(CGContextRef context)
{
#if TARGET_OS_IPHONE
    UIGraphicsPushContext(context);
#else
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
    [NSGraphicsContext setCurrentContext:graphicsContext];
#endif
}

static inline void enhPopGraphicContext()
{
#if TARGET_OS_IPHONE
    UIGraphicsPopContext();
#else
    [NSGraphicsContext restoreGraphicsState];
#endif
}

@interface ENHBaseScene () <SKPhysicsContactDelegate>

@property BOOL contentCreated;
@property SKNode *mouseNode;
@property NSMutableArray *textureArray;

@end

@implementation ENHBaseScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:0.15f green:0.15f blue:0.3f alpha:1.0f];
        _textureArray = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

+(CGImageRef)newRectangleImageWithSize:(CGSize)size
                   withBackgroundColor:(SKColor *)backgroundColor
                       withStrokeColor:(SKColor *)strokeColor
                       withStrokeWidth:(CGFloat)strokeWidth
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    //Push the current graphics context (state) onto the stack
    enhPushGraphicsContext(context);
    CGRect rect = (CGRect){strokeWidth/2.0f, strokeWidth/2.0f, size.width - strokeWidth, size.height - strokeWidth};

    //create a bezier path
#if TARGET_OS_IPHONE
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:rect];
#else
    NSBezierPath *rectanglePath = [NSBezierPath bezierPathWithRect:rect];
#endif

    //draw the rectangle
    [backgroundColor setFill];
    [rectanglePath fill];
    [strokeColor setStroke];
    rectanglePath.lineWidth = strokeWidth;
    [rectanglePath stroke];

    //Pop graphics context
    enhPopGraphicContext();

    //Make and return an image
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return image;
}

-(SKTexture *)textureWithSize:(CGSize)size
          withBackgroundColor:(SKColor *)backgroundColor
              withStrokeColor:(SKColor *)strokeColor
              withStrokeWidth:(CGFloat)strokeWidth
{
    NSPredicate *textureInfoPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        ENHSKTextureMetadata *metadata = evaluatedObject;
        BOOL equal = (CGSizeEqualToSize(size, metadata.size)
                      && strokeWidth == metadata.strokeWidth
                      && [strokeColor isEqual:metadata.strokeColor]
                      && [backgroundColor isEqual:metadata.backgroundColor]);
        return equal;
    }];

    NSArray *matchingTextureMetadata = [self.textureArray filteredArrayUsingPredicate:textureInfoPredicate];
    ENHSKTextureMetadata *metadata = [matchingTextureMetadata firstObject];

    if (metadata == nil || metadata.texture == nil)
    {
        CGImageRef image = [[self class] newRectangleImageWithSize:size withBackgroundColor:backgroundColor withStrokeColor:strokeColor withStrokeWidth:strokeWidth];
        SKTexture *texture = [SKTexture textureWithCGImage:image];
        CGImageRelease(image);
        ENHSKTextureMetadata *metadata = [ENHSKTextureMetadata metadataWithTexture:texture
                                                                              size:size
                                                                   backgroundColor:backgroundColor
                                                                       strokeColor:strokeColor
                                                                       strokeWidth:strokeWidth];
        [self.textureArray addObject:metadata];
    }
    return metadata.texture;
}

static const BOOL showMouseNode = NO;
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
    CGFloat mouseSquareWidthHeight = TARGET_OS_IPHONE ? 24.f : 120.f;
    CGSize mouseSize = (CGSize) {mouseSquareWidthHeight, mouseSquareWidthHeight};
    self.mouseNode = [SKSpriteNode spriteNodeWithColor:showMouseNode ? [[SKColor lightGrayColor] colorWithAlphaComponent:0.5]:[SKColor clearColor] size:mouseSize];
    self.mouseNode.zPosition = 1.0f;
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

#if TARGET_OS_IPHONE
    CGFloat width = 44.0f;
    CGFloat height = 8.0f;
    CGFloat lineWidth = 1.0f;
#else
    CGFloat width = 110.0f;
    CGFloat height = 20.0f;
    CGFloat lineWidth = 4.0f;
#endif

    CGSize chuckSize = (CGSize){.width=width, .height=height};
    SKTexture *texture = [self textureWithSize:chuckSize
                           withBackgroundColor:backgroundColor
                               withStrokeColor:strokeColor
                               withStrokeWidth:lineWidth];

    SKSpriteNode *chuck = [SKSpriteNode spriteNodeWithTexture:texture size:chuckSize];
    chuck.position = location;
    chuck.zPosition = 1.0f;

    SKPhysicsBody *chuckBody = [SKPhysicsBody bodyWithRectangleOfSize:chuckSize];
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
