//
//  Bird.h
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameEngineScene.h" 
@interface Bird : CCSprite
+(Bird*)cons;
-(void)i_update:(GameEngineScene *)game;
@end