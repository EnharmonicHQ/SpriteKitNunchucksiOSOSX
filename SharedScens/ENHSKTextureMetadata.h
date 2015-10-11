//
//  ENHSKTextureMetadata.h
//  SpriteKit0
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKTexture, SKColor;
@interface ENHSKTextureMetadata : NSObject

@property(readonly)SKTexture *texture;
@property(readonly)CGSize size;
@property(readonly)SKColor *backgroundColor;
@property(readonly)SKColor *strokeColor;
@property(readonly)CGFloat strokeWidth;

+(instancetype)metadataWithTexture:(SKTexture *)texture
                              size:(CGSize)size
                   backgroundColor:(SKColor *)backgroundColor
                       strokeColor:(SKColor *)strokeColor
                       strokeWidth:(CGFloat)strokeWidth;

@end
