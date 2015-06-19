//
//  ENHSimplifyingCoreGraphics.h
//  SpriteKit0
//
//  Created by Jonathan Saggau on 11/8/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENHSimplifyingCoreGraphics : NSObject

+(CGImageRef)newRectangleImageWithSize:(CGSize)size
                   withBackgroundColor:(SKColor *)backgroundColor
                       withStrokeColor:(SKColor *)strokeColor
                       withStrokeWidth:(CGFloat)strokeWidth;

@end
