//
//  ENHAppDelegate.m
//  SpriteKitMavericks
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHAppDelegate.h"
#import "ENHOSXScene.h"

@implementation ENHAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* Pick a size for the scene */
    SKScene *scene = [ENHOSXScene sceneWithSize:CGSizeMake(1024, 768)];

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];
#if DEBUG
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    self.skView.showsPhysics = YES;
#endif
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
