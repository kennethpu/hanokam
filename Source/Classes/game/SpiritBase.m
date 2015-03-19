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

@implementation SpiritBase {
}

-(void)i_update_game:(GameEngineScene*)g{}


-(void)basic_behaviors:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	
	_wave += _vy / 50 * dt_scale_get();
	
	if(!_following) {
		// DIVING WAITING FOR PLAYER
		[self custom_water_behavior]
		if(g.player.position.y < _y) {
			_following = true;
			_follow_pos = [SpiritManager follow_pos];
			[SpiritManager advance_follow_pos];
		}
	} else {
		if(_y < 0) {
			// UNDER WATER
			if(g.touch_down){
				float gotoY = g.player.position.y + _follow_pos * 20 + 100;
				if(_y > gotoY) {
					_aimDir = [self angle_towards_x:(g.player.position.x + sinf(_wave) * 30 + ((_follow_pos + 1) % 3 - 1) * 30) y:gotoY];
					_vx += (sinf(_aimDir) * 10 - _vx) * .02 * dt_scale_get();
					_vy += (cosf(_aimDir) * 15 - _vy) * .1 * dt_scale_get();
				} else {
					_vy = _vy - (_vy *  .1 * dt_scale_get());
				}
			} else {
				if(_y > g.player.position.y) {
					_vy += (-6 - _vx) * .07 * dt_scale_get();
				} else {
					_aimDir = [self angle_towards_x:g.player.position.x y:g.player.position.y - _follow_pos * 50 - 100];
				
					_vx += (sinf(_aimDir) * 10 - _vx) * .02 * dt_scale_get();
					_vy += (cosf(_aimDir) * 20 - _vy) * .1 * dt_scale_get();
				}
			}
			_vx = _vx - (_vx *  .05 * dt_scale_get());
			_vy = _vy - (_vy *  .05 * dt_scale_get());
			
		} else {
			// HIT PLAYER
			if(g.player.position.x > _x - 15 && g.player.position.x < _x + 15) {
				if(g.player.position.y < _y && g.player.position.y > _y - 20) {
					g.player._vy = 10;
					_x = -100;
				}
			}
			_vx *= .9;
			_vy = 8;
		}
	}
	
	_rotation = atan2f(_vx, _vy);
	
	_x += _vx;
	_y += _vy;
	
	[self setRotation:_rotation * 57.2957795];
	//[self setPosition:ccp(clampf(_x, 0, game_screen().width),_y)];
	[self setPosition:ccp(_x, _y)];
	
}

-(void) water_behavior:(GameEngineScene*)g {
}

@end
