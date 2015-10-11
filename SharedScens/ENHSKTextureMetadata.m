//
//  ENHSKTextureMetadata.m
//  SpriteKit0
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHSKTextureMetadata.h"

@interface ENHSKTextureMetadata ()

@property(readwrite)SKTexture *texture;
@property(readwrite)CGSize size;
@property(readwrite)SKColor *backgroundColor;
@property(readwrite)SKColor *strokeColor;
@property(readwrite)CGFloat strokeWidth;

@end

@implementation ENHSKTextureMetadata

+(instancetype)metadataWithTexture:(SKTexture *)texture
                              size:(CGSize)size
                   backgroundColor:(SKColor *)backgroundColor
                       strokeColor:(SKColor *)strokeColor
                       strokeWidth:(CGFloat)strokeWidth
{
    ENHSKTextureMetadata *metadata = [[[self class] alloc] init];
    metadata.texture = texture;
    metadata.size = size;
    metadata.backgroundColor = backgroundColor;
    metadata.strokeColor = strokeColor;
    metadata.strokeWidth = strokeWidth;
    return metadata;
}

@end
