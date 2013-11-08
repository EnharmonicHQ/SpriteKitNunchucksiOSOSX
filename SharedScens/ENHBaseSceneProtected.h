//
//  ENHBaseSceneProtected.h
//  SpriteKitMavericks
//
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

// Useful random functions.
extern CGFloat myRandf();
extern CGFloat myRand(CGFloat low, CGFloat high);

// Protected methods Category for subclasses to override
@interface ENHBaseScene (protected_methods)

@property SKSpriteNode *mouseNode;

-(SKNode *)makeNunchuckAtLocation:(CGPoint)location withBackgroundColor:(SKColor *)backgroundColor withStrokeColor:(SKColor *)strokeColor;
-(void)wiggleStuffWithMagnitude:(CGFloat)magnitude;

@end