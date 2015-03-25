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
typedef enum _spirit_state {
	spirit_state_waiting = 0,
	spirit_state_following = 1,
	spirit_state_combat = 2
} spirit_state;

@interface SpiritBase : CCSprite

@property(readwrite,assign) float _vx,_vy,_aimDir,_wave, _air_time;
@property(readwrite,assign) int _health, _health_total, _follow_pos, _state;
@property(readwrite,assign) BOOL _remove_me;

-(SpiritBase*) cons_size:(float)size;

-(void)i_update_game:(GameEngineScene*)g;
-(void)water_behavior:(GameEngineScene*)g;
-(void)air_behavior:(GameEngineScene*)g;
-(float)angle_towards_x:(float)x y:(float)y;
-(void)toss:(GameEngineScene*)g;

-(CGPoint)get_healthbar_offset;
-(BOOL)has_health_bar;
-(float)get_health_pct;
@end