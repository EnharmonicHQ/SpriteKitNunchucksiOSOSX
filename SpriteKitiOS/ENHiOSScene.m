//
//  ENHMyScene.m
//  SpriteKitiOS
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHiOSScene.h"
#import "ENHBaseSceneProtected.h"
#import <CoreMotion/CoreMotion.h>

@interface ENHiOSScene ()

@property(nonatomic, strong)CMMotionManager *motionManager;

@end

@implementation ENHiOSScene

-(void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [view addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [view addGestureRecognizer:pan];
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:0.15f green:0.15f blue:0.3f alpha:1.0f];
        self.motionManager = [[CMMotionManager alloc] init];
        if (self.motionManager.isDeviceMotionAvailable)
        {
            [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
        }
        else
        {
            self.motionManager = nil;
        }
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];

    static NSTimeInterval lastTime;
    static NSUInteger chuckCount;
    if (ABS(currentTime - lastTime) >= 1.0)
    {
        lastTime = currentTime;
        CGSize sceneSize = self.scene.size;
        for (NSUInteger i=0; i<100; i++)
        {
            CGPoint someplace = (CGPoint){.x = myRand(0.0, sceneSize.width), .y = myRand(0.0, sceneSize.height)};
            SKColor *color = i%2 == 0 ? [SKColor redColor] : [SKColor greenColor];
            SKNode *chuck = [self makeNunchuckAtLocation:someplace
                                     withBackgroundColor:color
                                         withStrokeColor:[SKColor blackColor]];
            [self addChild:chuck];
            chuckCount++;
        }
        NSLog(@"chuckCount = %@", @(chuckCount));
    }

    if (self.motionManager != nil && self.motionManager.isDeviceMotionActive)
    {
        CMDeviceMotion *deviceMotion = [self.motionManager deviceMotion];
        CMAcceleration gravity = deviceMotion.gravity;


    }

}

-(void)wiggleStuffWithMagnitude:(CGFloat)magnitude
{

}

-(void)tap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized)
    {
        if (tap.numberOfTouches > 1)
        {
            [self wiggleStuffWithMagnitude:300.0f];
        }
        else
        {
            if (![self.mouseNode parent])
            {
                //Make a new chuck if the mouse wasn't dragging around (mouse node has no parent)
                CGPoint locationInView = [tap locationInView:self.view];
                CGPoint location = [self.view convertPoint:locationInView toScene:self];
                SKNode *spriteOne = [self makeNunchuckAtLocation:location withBackgroundColor:[SKColor greenColor] withStrokeColor:[SKColor blackColor]];
                location.x += spriteOne.frame.size.width;
                SKNode *spriteTwo = [self makeNunchuckAtLocation:location withBackgroundColor:[SKColor redColor] withStrokeColor:[SKColor blackColor]];
                [self addChild:spriteOne];
                [self addChild:spriteTwo];
            }
            else
            {
                [self.mouseNode removeFromParent];
            }
        }
    }
}

-(void)pan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled)
    {
        [self.mouseNode removeFromParent];
    }
    else
    {
        CGPoint locationInView = [pan locationInView:self.view];
        CGPoint location = [self.view convertPoint:locationInView toScene:self];
        self.mouseNode.position = location;
        if (![self.mouseNode parent])
        {
            [self addChild:self.mouseNode];
        }
    }
}

@end
