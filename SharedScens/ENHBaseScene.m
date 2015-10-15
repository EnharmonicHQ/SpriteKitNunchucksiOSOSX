//
//  ENHScene.m
//  SpriteKitMavericks
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHBaseScene.h"
#import "ENHBaseSceneProtected.h"
#import "ENHSKTextureMetadata.h"
#import "ENHSimplifyingCoreGraphics.h"

static const BOOL showMouseNode = NO;

//Useful random functions
inline CGFloat myRandf()
{
    return rand() / (CGFloat) RAND_MAX;
}

inline CGFloat myRand(CGFloat low, CGFloat high)
{
    return myRandf() * (high - low) + low;
}

@interface ENHBaseScene ()

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
        CGImageRef image = [ENHSimplifyingCoreGraphics newRectangleImageWithSize:size withBackgroundColor:backgroundColor withStrokeColor:strokeColor withStrokeWidth:strokeWidth];
        SKTexture *texture = [SKTexture textureWithCGImage:image];
        CGImageRelease(image);
        metadata = [ENHSKTextureMetadata metadataWithTexture:texture
                                                        size:size
                                             backgroundColor:backgroundColor
                                                 strokeColor:strokeColor
                                                 strokeWidth:strokeWidth];
        [self.textureArray addObject:metadata];
    }
    return metadata.texture;
}

-(void)createSceneContents
{
    self.scaleMode = SKSceneScaleModeAspectFit;

    CGFloat mouseSquareWidthHeight = TARGET_OS_IPHONE ? 24.f : 120.f;
    CGSize mouseSize = (CGSize) {mouseSquareWidthHeight, mouseSquareWidthHeight};
    self.mouseNode = [SKSpriteNode spriteNodeWithColor:showMouseNode ? [[SKColor lightGrayColor] colorWithAlphaComponent:0.5]:[SKColor clearColor] size:mouseSize];
    self.mouseNode.zPosition = 1.0;
    
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
    
}

-(SKNode *)makeNunchuckAtLocation:(CGPoint)location withBackgroundColor:(SKColor *)backgroundColor withStrokeColor:(SKColor *)strokeColor
{
    
    //Little chucks on iPhone; bigger ones on OS X
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
                           withBackgroundColor:[SKColor whiteColor]
                               withStrokeColor:strokeColor
                               withStrokeWidth:lineWidth];
    
    SKSpriteNode *chuck = [SKSpriteNode spriteNodeWithTexture:texture size:chuckSize];
    [chuck setColor:backgroundColor];
    [chuck setColorBlendFactor:1.0];
    chuck.position = location;
    chuck.zPosition = 1.0f;
    
    return chuck;
}


-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}


@end
