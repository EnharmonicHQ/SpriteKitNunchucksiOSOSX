//
//  ENHBaseSceneProtected.h
//  SpriteKit0
//
//  Created by Jonathan Saggau on 10/17/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

@interface ENHBaseScene (protected_methods)

@property SKSpriteNode *mouseNode;

-(SKNode *)makeNunchuckAtLocation:(CGPoint)location withBackgroundColor:(SKColor *)backgroundColor withStrokeColor:(SKColor *)strokeColor;
-(void)wiggleStuffWithMagnitude:(CGFloat)magnitude;

NSString *enhSpecialPhysicsContactDescription(SKPhysicsContact *physicsThing);

@end