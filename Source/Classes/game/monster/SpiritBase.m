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
#import "ParticleLiquid.h"

@implementation SpiritBase {
	float _vx, _vy;
	float _pref_x, _pref_y;
	float _aimDir;
	float _wave;
	float _air_time;
	float _pos_x, _pos_y;
	int _follow_pos;
	int _state;
}

@synthesize _health, _health_total;
@synthesize _state;
@synthesize _vx,_vy,_aimDir,_wave;
@synthesize _follow_pos;
@synthesize _remove_me;
@synthesize _air_time;

-(SpiritBase*) cons_size:(float)size {
	_remove_me = false;
	return self;
}

-(void)i_update_game:(GameEngineScene*)g{
	[self basic_behaviors:g];
}

-(void)basic_behaviors:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	
	_wave += .2 + _vy / 120 * dt_scale_get();
	
	switch (_state) {
		case spirit_state_waiting:
			[self water_behavior:g];
			
			if(g.player.position.y < _y) {
				_state = spirit_state_following;
				_follow_pos = 0;
				_pos_x = (g.get_spirit_manager._spawned % 3 - 1) * 15 + float_random(-5,5);
				_pos_y = float_random(-5, 5);
				[g.get_spirit_manager advance_follow_pos];
			}
			break;
		case spirit_state_combat:
			[self air_behavior:g];
			
			/*
			_y += (g.player_combat_top_y - (_air_time * _air_time) - 50 - _y) * .05 * dt_scale_get();
			_vy = 1;
			_rotation += _vx;
			_air_time += .05 * dt_scale_get();
			if(_x < -30 || _x > game_screen().width + 20 || (_air_time > 1 && _y < g.get_camera_y - game_screen().height / 2 - 100) || _y > g.get_camera_y + game_screen().height / 2 + 100) {
				_remove_me = true;
				[g.get_spirit_manager toss_spirit];
			}
			
			if(_air_time > 1 && _y < g.get_camera_y - game_screen().height / 2 + 20) {
				_air_time += .1 * dt_scale_get();
			}
			
			// HIT PLAYER
			if(g.player.position.x > _x - 30 && g.player.position.x < _x + 30 && g.player.position.y < _y + 20 && g.player.position.y > _y - 20) {
				[g shake_for:15 distance:7];
				[g.player melee_spirit];
				[g.player setPosition:ccp(g.player.position.x, _y + 30)];
				[g freeze_frame:5];
				
				DO_FOR(10,
					[g add_particle:(Particle*)[[[[ParticleLiquid cons_tex:[Resource get_tex:TEX_PARTICLE_BLOOD_1]
						rect:CGRectMake(0, 0, 55, 55)]
						explode_speed:10]
						set_pos:ccp(_x, _y)]
						set_scale:.5]]
				);
				
				_health -= g.player.stat_damage;
				if(_health <= 0){
					_remove_me = true;
					[g.get_spirit_manager toss_spirit];
				}
			}
			*/
		break;
		case spirit_state_following:
			if(_y < 0) {
				float _goto_y;
				float _goto_x;
				// UNDER WATER
				if(g.touch_down && g._player_state != PlayerState_Return){
					// FOLLOWING
					_goto_x = g.player.position.x + sinf(_wave) * 20 + _pos_x;
					_goto_y = g.player.position.y + 25 + _follow_pos * 15 + _pos_y;
					
					_aimDir = [self angle_towards_x:_goto_x y:_goto_y];
					
					if(_y > _goto_y) {
						_vx += (sinf(_aimDir) * 7 - _vx) * .1 * dt_scale_get();
						_vy += (cosf(_aimDir) * 8 - _vy) * .1 * dt_scale_get();
						
						_x += (_goto_x - _x) * (.003 + .008 / (_follow_pos + 1)) * dt_scale_get();
						_y += (_goto_y - _y) * .01 * dt_scale_get();
					} else {
						_vx += (sinf(_aimDir) * 10 - _vx) * .1 * dt_scale_get();
						_vy = _vy - (_vy *  .1 * dt_scale_get());
						
						_x += (_goto_x - _x) * (.01 + .02 / (_follow_pos + 1)) * dt_scale_get();
						//_x += (_goto_x - _x) * .03 * dt_scale_get();
					}
				} else {
					_goto_x = g.player.position.x + sinf(_wave) * 5 + ((_follow_pos + 1) % 3 - 1) * 7;
					_goto_y = g.player.position.y - _follow_pos * 50 - 50;
					_aimDir = [self angle_towards_x:_goto_x y:_goto_y];
					
					if(_y > _goto_y) {
						// PLAYER STOPS
						_vx += (sinf(_aimDir) * 10 - _vx) * .1 * dt_scale_get();
						_vy += (- 4 - _vx) * .07 * dt_scale_get();
					} else {
						// SWIM UP
						
						if(_y > - 1000) {
							_goto_y -= (1000 + _y) * .2;
						}
						
						_aimDir = [self angle_towards_x:_goto_x y: _goto_y];
						
						_vx += (sinf(_aimDir) * 10 - _vx) * .1 * dt_scale_get();
						_vy += (cosf(_aimDir) * 30 - _vy) * .1 * dt_scale_get();
						_x += (_goto_x - _x) * .01 * dt_scale_get();
						_y += (_goto_y - _y) * .2 * dt_scale_get();
					}
				}
				_vx -= _vx * .05 * dt_scale_get();
				_vy -= _vy * .05 * dt_scale_get();
				
			} else {
				// IN AIR, HIDDEN
				/*
				if(g.player._falling) {
					_y = 400;
				} else {
					_vy = 3;
					_y = g.get_camera_y - 300;
				}
				*/
			}
		break;
	}
	
	
	_x += _vx * dt_scale_get();
	_y += _vy * dt_scale_get();
	
	if(self.position.y > 0 && _y < 0) {
		[g add_ripple:self.position];
	}
	
	_rotation = atan2f(_x - (self.position.x + _pref_x) / 2, _y - (self.position.y + _pref_y) / 2);
	
	_pref_x = _x;
	_pref_y = _y;
	
	[self setRotation:_rotation * 57.2957795];
	[self setPosition:ccp(_x, _y)];
}

-(void) toss:(GameEngineScene*)g {
	[self setPosition:ccp(float_random(40, game_screen().width-40), g.get_camera_y - game_screen().height / 2 - 20)];
	_vy = 0;
	_state = spirit_state_combat;
	
	_vx = float_random(-1, 1);
}

-(void) water_behavior:(GameEngineScene*)g {}

-(void) air_behavior:(GameEngineScene*)g {}

-(float)angle_towards_x:(float)x y:(float)y {
	return atan2f(x - self.position.x, y - self.position.y);
}

-(CGPoint)get_healthbar_offset { return ccp(0, 20);}
-(BOOL)has_health_bar { return YES; }
-(float)get_health_pct { return (float)_health / _health_total; }

@end