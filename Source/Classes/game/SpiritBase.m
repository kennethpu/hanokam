//
//  EnemyBase.m
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpiritBase.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "SpiritManager.h"
#import "Player.h" 

@implementation SpiritBase {
	float _vx, _vy;
	float _aimDir;
	float _wave;
	int _follow_pos;
	BOOL _following;
}
@synthesize _vx,_vy,_aimDir,_wave;
@synthesize _follow_pos;
@synthesize _following;

-(SpiritBase*) cons_size:(float)size {
	_following = NO;
	return self;
}

-(void)i_update_game:(GameEngineScene*)g{
	[self basic_behaviors:g];
}


-(void)basic_behaviors:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	
	_wave += _vy / 50 * dt_scale_get();
	
	if(!_following) {
		// DIVING WAITING FOR PLAYER
		[self water_behavior:g];
		
		if(g.player.position.y < _y) {
			_following = true;
			_follow_pos = 0;
			[g.get_spirit_manager advance_follow_pos];
		}
	} else {
		if(_y < 0) {
			// UNDER WATER
			if(g.touch_down){
				// FOLLOWING
				float goto_y = g.player.position.y + _follow_pos * 20 + 50;
				if(_y > goto_y) {
					_aimDir = [self angle_towards_x:(g.player.position.x + sinf(_wave) * 30 + ((_follow_pos + 1) % 3 - 1) * 30) y:goto_y];
					_vx += (sinf(_aimDir) * 10 - _vx) * .02 * dt_scale_get();
					_vy += (cosf(_aimDir) * 20 - _vy) * .1 * dt_scale_get();
				} else {
					_vy = _vy - (_vy *  .1 * dt_scale_get());
				}
			} else {
				if(_y > g.player.position.y - _follow_pos * 100 - 70) {
					_vy += (-6 - _vx) * .07 * dt_scale_get();
				} else {
					// SWIM UP
					_aimDir = [self angle_towards_x:g.player.position.x y:g.player.position.y - _follow_pos * 100 - 70];
					
					_vx += (sinf(_aimDir) * 10 - _vx) * .02 * dt_scale_get();
					_vy += (cosf(_aimDir) * 20 - _vy) * .1 * dt_scale_get();
				}
			}
			_vx = _vx - (_vx *  .05 * dt_scale_get());
			_vy = _vy - (_vy *  .05 * dt_scale_get());
			
		} else {
			// HIT PLAYER
			if(g.player.position.x > _x - 15 && g.player.position.x < _x + 15) {
				if(g.player.position.y < _y && g.player.position.y > _y - 40) {
					g.player._vy = 10;
					_x = -100;
				}
			}
			if(_y < g.player.position.y - 400)
			_x = float_random(0, game_screen().width);
			
			[self air_behavior:g];
			_vx *= .9;
			_vy = 8;
		}
	}
	
	_rotation = atan2f(_vx, _vy);
	
	_x += _vx;
	_y += _vy;
	
	[self setRotation:_rotation * 57.2957795];
	[self setPosition:ccp(_x, _y)];
	
}

-(void) water_behavior:(GameEngineScene*)g {
}

-(void) air_behavior:(GameEngineScene*)g {
}

-(float)angle_towards_x:(float)x y:(float)y {
	return atan2f(x - self.position.x, y - self.position.y);
}


@end
