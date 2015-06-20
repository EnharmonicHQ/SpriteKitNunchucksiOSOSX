//
//  ENHMyScene.m
//  SpriteKitMavericks
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHOSXScene.h"
#import "ENHBaseSceneProtected.h"

@implementation ENHOSXScene

- (void)keyDown:(NSEvent *)theEvent;
{
    [self wiggleStuffWithMagnitude:300.0f];
}

-(void)mouseUp:(NSEvent *)theEvent
{
    if (![self.mouseNode parent])
    {

    }
    else
    {
        [self.mouseNode removeFromParent];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    //Move the clear mouse node around
    CGPoint location = [theEvent locationInNode:self];
    self.mouseNode.position = location;
    if (![self.mouseNode parent])
    {
        [self addChild:self.mouseNode];
    }
}

@end
