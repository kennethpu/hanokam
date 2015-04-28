//
//  BGCharacterVillagerFishWoman.h
//  hobobob
//
//  Created by spotco on 27/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@class GameEngineScene;
@interface BGCharacterVillagerFishWoman : CCSprite
+(BGCharacterVillagerFishWoman*)cons_pos:(CGPoint)pos;
-(void)i_update:(GameEngineScene*)g;
@end
