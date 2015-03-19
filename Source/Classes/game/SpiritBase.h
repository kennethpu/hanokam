//
//  EnemyBase.h
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"
#import "GameEngineScene.h"
#import "SpiritManager.h"

@interface SpiritBase : CCSprite
-(void)i_update_game:(GameEngineScene*)g;
-(void)water_behavior:(GameEngineScene*)g;
@end