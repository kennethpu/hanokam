//
//  Arrow.h
//  hobobob
//
//  Created by spotco on 22/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"

@class GameEngineScene;

@interface Arrow : CCSprite
+(Arrow*)cons;
-(void)i_update:(GameEngineScene*)g;
@end
