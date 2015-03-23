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

@property(readwrite,assign) float _vx,_vy,_aimDir,_wave;
@property(readwrite,assign) int _follow_pos;
@property(readwrite,assign) BOOL _following, _tossed, _remove_me;

-(SpiritBase*) cons_size:(float)size;

-(void)i_update_game:(GameEngineScene*)g;
-(void)water_behavior:(GameEngineScene*)g;
-(void)air_behavior:(GameEngineScene*)g;
-(float)angle_towards_x:(float)x y:(float)y;
-(void)toss:(GameEngineScene*)g;
@end