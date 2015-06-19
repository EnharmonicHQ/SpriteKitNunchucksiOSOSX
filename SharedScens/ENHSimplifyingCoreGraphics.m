//
//  ENHSimplifyingCoreGraphics.m
//  SpriteKit0
//
//  Created by Jonathan Saggau on 11/8/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHSimplifyingCoreGraphics.h"

#pragma mark simplifying core graphics functions
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

#if TARGET_OS_IPHONE
#define ENHBezierPath UIBezierPath
#else
#define ENHBezierPath NSBezierPath
#endif

#pragma mark - impl

@implementation ENHSimplifyingCoreGraphics

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
    ENHBezierPath *rectanglePath = [ENHBezierPath bezierPathWithRect:rect];

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

@end
