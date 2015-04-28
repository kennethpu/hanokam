#import "Player.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"

#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"

#import "PlayerProjectile.h"
#import "ParticleBubble.h"

#import "CCTexture_Private.h"
#import "ControlManager.h"

#import "AirEnemyManager.h"

#import "PlayerAirCombatParams.h"
#import "PlayerUnderwaterCombatParams.h"
#import "PlayerLandParams.h"

@implementation Player {
	SpriterNode *_img;
	
	NSString *_current_playing;
	NSString *_on_finish_play_anim;
	
	PlayerAirCombatParams *_air_params;
	PlayerUnderwaterCombatParams *_underwater_params;
	PlayerLandParams *_land_params;
	
	CGPoint _s_pos;
}

+(Player*)cons_g:(GameEngineScene*)g {
	return [[Player node] cons_g:g];
}
-(Player*)cons_g:(GameEngineScene*)g {
	_air_params = [[PlayerAirCombatParams alloc] init];
	_underwater_params = [[PlayerUnderwaterCombatParams alloc] init];
	_land_params = [[PlayerLandParams alloc] init];
	
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"hanokav2.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_CHAR_HANOKA_V2] frames:frame_data scml:@"hanokav2.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[self play_anim:@"idle" repeat:YES];
	[self addChild:_img z:1];
	
	[self prep_initial_land_mode:g];
	
	[_img set_scale:0.25];
	
	return self;
}

-(void)i_update:(GameEngineScene*)g {
	if (g.get_player_state == PlayerState_OnGround) {
		[self setZOrder:GameAnchorZ_Player];
	} else {
		[self setZOrder:GameAnchorZ_Player_Out];
	}
	
	if (!_img.current_anim_repeating && _img.current_anim_finished && _on_finish_play_anim != NULL) {
		[_img playAnim:_on_finish_play_anim repeat:YES];
		_on_finish_play_anim = NULL;
	}
	
	switch ([g get_player_state]) {
		case PlayerState_Dive:
			[self update_dive:g];
	
		break;
		case PlayerState_DiveReturn:
			[self update_dive_return:g];
			
		break;
		case PlayerState_InAir:
			[self update_in_air:g];
			
		break;
		case PlayerState_OnGround:
			[self update_on_ground:g];
			
		break;
		case PlayerState_AirToGroundTransition:
			[self update_air_to_ground_transition:g];
		break;
	}
	[g.get_control_manager clear_proc_swipe];
	[g.get_control_manager clear_proc_tap];
}

-(void)play_anim:(NSString*)anim repeat:(BOOL)repeat {
	_on_finish_play_anim = NULL;
	if(_current_playing != anim) {
		_current_playing = anim;
		[_img playAnim:anim repeat:repeat];
	}
}

-(void)play_anim:(NSString*)anim1 on_finish_anim:(NSString*)anim2 {
	_current_playing = anim1;
	[_img playAnim:anim1 repeat:NO];
	_on_finish_play_anim = anim2;
}

-(float)get_next_update_accel_x_position:(GameEngineScene*)g { return clampf(_s_pos.x + clampf(((160 + g.get_control_manager.get_accel_x * 320) - _s_pos.x) * .07,-7, 7) * dt_scale_get(),0,game_screen().width); }
-(float)get_next_update_accel_x_position_delta:(GameEngineScene*)g { return [self get_next_update_accel_x_position:g]-_s_pos.x; }
-(void)update_accel_x_position:(GameEngineScene*)g {
	float x_pos = [self get_next_update_accel_x_position:g];
	_s_pos.x = x_pos;
	self.position = ccp(_s_pos.x,self.position.y);
}

-(void)apply_s_pos:(GameEngineScene*)g {
	self.position = CGPointAdd(_s_pos, ccp(g.get_viewbox.x1,g.get_viewbox.y1));
}

-(void)read_s_pos:(GameEngineScene*)g {
	_s_pos = CGPointSub(self.position, ccp(g.get_viewbox.x1,g.get_viewbox.y1));
}

-(void)prep_initial_land_mode:(GameEngineScene*)g {
	[g imm_set_camera_hei:150];
	g._player_state = PlayerState_OnGround;
	_s_pos = game_screen_pct(0.5, 0);
	[self apply_s_pos:g];
	_land_params._current_mode = PlayerLandMode_OnDock;
}

-(void)prep_water_to_air_mode:(GameEngineScene*)g {
	g._player_state = PlayerState_InAir;
	_air_params._w_camera_center = [g get_current_camera_center_y];
	_air_params._w_upwards_vel = 6;
	_air_params._s_vel = ccp(0,0);
	_air_params._current_mode = PlayerAirCombatMode_InitialJumpOut;
	_air_params._anim_ct = 0;
	_air_params._sword_out = NO;
	_air_params._arrow_throwback_ct = 2;
}

-(void)prep_land_to_water_mode:(GameEngineScene*)g {
	g._player_state = PlayerState_Dive;
	_underwater_params._vy = -7;
	_underwater_params._tar_camera_offset = g.get_current_camera_center_y - self.position.y;
	_underwater_params._current_mode = PlayerUnderwaterCombatMode_TransitionIn;
	_underwater_params._anim_ct = 0;
	_underwater_params._remainder_camera_offset = 0;
	_underwater_params._initial_camera_offset = _underwater_params._tar_camera_offset;
	[self read_s_pos:g];
}

-(void)prep_transition_air_to_land_mode:(GameEngineScene*)g {
	g._player_state = PlayerState_AirToGroundTransition;
	_land_params._vel = ccp(0,clampf(_air_params._w_upwards_vel + _air_params._s_vel.y,-15,-5));
	[g add_ripple:ccp(g.player.position.x,0)];
}

-(void)prep_transition_air_to_land_finish_mode:(GameEngineScene*)g {
	g.player.position = ccp(g.player.position.x,g.DOCK_HEIGHT);
	self.rotation = 0;
	g._player_state = PlayerState_OnGround;
	_land_params._current_mode = PlayerLandMode_OnDock;
	[self read_s_pos:g];
}

-(void)prep_dive_to_dive_return_mode:(GameEngineScene*)g {
	g._player_state = PlayerState_DiveReturn;
}

-(void)update_on_ground:(GameEngineScene*)g {
	switch(_land_params._current_mode) {
		case PlayerLandMode_OnDock:;
			[g set_zoom:drp(g.get_zoom,1,20)];
			[g set_camera_height:drp(g.get_current_camera_center_y,150,20)];
			if (g.get_control_manager.is_touch_down) {
				[self play_anim:@"prep dive" repeat:NO];
				_land_params._prep_dive_hold_ct += dt_scale_get();
				if (_land_params._prep_dive_hold_ct > _land_params.PREP_DIVE_HOLD_TIME) {
					_land_params._current_mode = PlayerLandMode_LandToWater;
					_land_params._vel = ccp(0,10);
				}
				
			} else {
				_land_params._prep_dive_hold_ct = 0;
				float vx = [self get_next_update_accel_x_position_delta:g];
				if (ABS(vx) > _land_params.MOVE_CUTOFF_VAL) {
					_land_params._move_hold_ct += dt_scale_get();
					if (_land_params._move_hold_ct > _land_params.MOVE_HOLD_TIME) {
						[self update_accel_x_position:g];
						[self play_anim:@"run" repeat:YES];
						if (vx > 0) {
							_img.scaleX = ABS(_img.scaleX);
						} else {
							_img.scaleX = -ABS(_img.scaleX);
						}
					} else {
						[self play_anim:@"idle" repeat:YES];
					}
				} else {
					_land_params._move_hold_ct = 0;
					[self play_anim:@"idle" repeat:YES];
				}
				self.position = ccp(self.position.x,g.DOCK_HEIGHT);
				[self read_s_pos:g];
			}
		break;
		case PlayerLandMode_LandToWater:;
			[g set_zoom:drp(g.get_zoom,1.25,20)];
			[g set_camera_height:drp(g.get_current_camera_center_y,150,20)];
			CGPoint last_s_pos = _s_pos;
			[self update_accel_x_position:g];
			_land_params._vel = ccp(0,_land_params._vel.y-0.4 * dt_scale_get());
			_s_pos = CGPointAdd(_s_pos, _land_params._vel);
			
			float tar_rotation = vec_ang_deg_lim180(vec_cons(_s_pos.x - last_s_pos.x,_s_pos.y - last_s_pos.y, 0),90);
			self.rotation += shortest_angle(self.rotation, tar_rotation) * 0.25;
			
			[self apply_s_pos:g];
			[self play_anim:@"dive" repeat:YES];
			if (self.position.y < 0) {
				[self prep_land_to_water_mode:g];
				[g shake_slow_for:100 distance:10];
				[g add_ripple:ccp(g.player.position.x,0)];
			}
		break;
	}
}

-(void)update_dive:(GameEngineScene*)g {
	[self play_anim:@"swim" repeat:YES];
	CGPoint last_pos = self.position;
	switch (_underwater_params._current_mode) {
		case PlayerUnderwaterCombatMode_TransitionIn:;
			[g set_zoom:drp(g.get_zoom,1.1,20)];
			[self update_accel_x_position:g];
			self.position = ccp(self.position.x,clampf(self.position.y + _underwater_params._vy * dt_scale_get(),g.get_ground_depth,0));
			_underwater_params._tar_camera_offset = cubic_interp(_underwater_params._initial_camera_offset, _underwater_params.DEFAULT_OFFSET, 0, 1, _underwater_params._anim_ct);
			[g set_camera_height:self.position.y + _underwater_params._tar_camera_offset];
			_underwater_params._anim_ct += 0.025 * dt_scale_get();
			[self read_s_pos:g];
			if (_underwater_params._anim_ct >= 1) _underwater_params._current_mode = PlayerUnderwaterCombatMode_MainGame;
			
		break;
		case PlayerUnderwaterCombatMode_MainGame:;
			[g set_zoom:drp(g.get_zoom,1,20)];
			[self update_accel_x_position:g];
			self.position = ccp(self.position.x,clampf(self.position.y + _underwater_params._vy * dt_scale_get(),g.get_ground_depth,0));
			if (g.get_control_manager.is_touch_down) {
				if (self.position.y == g.get_ground_depth) {
					_underwater_params._vy = 0;
				} else {
					_underwater_params._vy = MAX(_underwater_params._vy-0.2*dt_scale_get(), -7);
				}
				_underwater_params._tar_camera_offset = _underwater_params.DEFAULT_OFFSET;
				[g set_camera_height:self.position.y + _underwater_params._tar_camera_offset + _underwater_params._remainder_camera_offset];
				_underwater_params._remainder_camera_offset = drp(_underwater_params._remainder_camera_offset, 0, 20);
				
			} else {
				_underwater_params._vy = MIN(_underwater_params._vy+0.2*dt_scale_get(), 7);
				_underwater_params._remainder_camera_offset = - ((self.position.y + _underwater_params._tar_camera_offset)-g.get_current_camera_center_y);
				if (g.player.position.y > g.get_viewbox.y2) {
					[self prep_dive_to_dive_return_mode:g];
				}
			}
			[self read_s_pos:g];
		break;
	}
	
	float tar_rotation = vec_ang_deg_lim180(vec_cons(low_filter(self.position.x - last_pos.x,0.25),low_filter(self.position.y - last_pos.y,0.25), 0),90);
	self.rotation += shortest_angle(self.rotation, tar_rotation) * 0.25;
}

-(void)update_dive_return:(GameEngineScene*)g {
	CGPoint last_pos = self.position;

	[self update_accel_x_position:g];
	_underwater_params._tar_camera_offset = drp(_underwater_params._tar_camera_offset, 0, 10);
	_underwater_params._remainder_camera_offset = drp(_underwater_params._remainder_camera_offset, 0, 10);
	[g set_camera_height:self.position.y + _underwater_params._tar_camera_offset + _underwater_params._remainder_camera_offset];
	[g set_zoom:drp(g.get_zoom,1.5,20)];
	_underwater_params._vy = MIN(_underwater_params._vy+0.6*dt_scale_get(), 14);
	self.position = ccp(self.position.x,self.position.y + _underwater_params._vy * dt_scale_get());
	
	float tar_rotation = vec_ang_deg_lim180(vec_cons(self.position.x - last_pos.x,self.position.y - last_pos.y, 0),90) + 15;
	self.rotation += shortest_angle(self.rotation, tar_rotation) * 0.25;
	if (self.position.y > 0) {
		[self prep_water_to_air_mode:g];
		[self play_anim:@"in air" repeat:YES];
		[g add_ripple:ccp(g.player.position.x,0)];
	}
	[self read_s_pos:g];
}

-(void)update_in_air:(GameEngineScene*)g {
	[g set_zoom:drp(g.get_zoom,1,20)];
	update_again:
	switch (_air_params._current_mode) {
		case PlayerAirCombatMode_InitialJumpOut:;
			_air_params._anim_ct = clampf(_air_params._anim_ct + 0.025 * dt_scale_get(), 0, 1);
			_s_pos = ccp(_s_pos.x,lerp(_s_pos.y, _air_params.DEFAULT_HEIGHT, _air_params._anim_ct));
			if (_air_params._anim_ct >= 1) {
				_air_params._current_mode = PlayerAirCombatMode_Combat;
			}
			[g set_zoom:drp(g.get_zoom,1,20)];
			
			if (g.get_control_manager.is_proc_swipe || g.get_control_manager.is_proc_tap) {
				_air_params._current_mode = PlayerAirCombatMode_Combat;
				goto update_again;
			}
		break;
		case PlayerAirCombatMode_Combat:;
			_air_params._w_upwards_vel *= powf(0.95, dt_scale_get());
			_air_params._s_vel = ccp(_air_params._s_vel.x,_air_params._s_vel.y - 0.1 * dt_scale_get());
			
			if (g.get_control_manager.is_proc_swipe) {
				[self play_anim:@"sword start" on_finish_anim:@"sword hold"];
				_air_params._sword_out = YES;
				_air_params._s_vel = ccp(0,-15);
			}
			
			if (!_air_params._sword_out && g.get_control_manager.is_proc_tap) {
				[self play_anim:@"bow attack" on_finish_anim:@"in air"];
				CGPoint tap = g.get_control_manager.get_proc_tap;
				CGPoint delta = CGPointSub(tap, _s_pos);
				[g add_player_projectile:[Arrow cons_pos:self.position dir:vec_cons_norm(delta.x, delta.y, 0)]];
				if (_air_params._arrow_throwback_ct > 0) {
					_air_params._s_vel = ccp(
						_air_params._s_vel.x,
						MAX(_air_params._arrow_throwback_ct, _air_params._s_vel.y)
					);
					_air_params._arrow_throwback_ct -= 0.1;
				}
			}
			
			for (BaseAirEnemy *itr in g.get_air_enemy_manager.get_enemies) {
				if (SAT_polyowners_intersect(self, itr)) {
					_air_params._s_vel = ccp(_air_params._s_vel.x,7);
					_air_params._w_upwards_vel = 4;
					_air_params._arrow_throwback_ct = 2.0;
					_air_params._sword_out = NO;
					[self play_anim:@"in air" repeat:YES];
					[itr hit_player_melee:g];
					break;
				}
			}
			
			_s_pos = ccp(
				_s_pos.x+_air_params._s_vel.x,
				clampf(_s_pos.y+_air_params._s_vel.y,-INFINITY,_air_params.DEFAULT_HEIGHT)
			);
			
		break;
		case PlayerAirCombatMode_RescueBackToTop:;
			_air_params._sword_out = NO;
		break;
		case PlayerAirCombatMode_FallToGround:;
			_air_params._sword_out = NO;
		break;
	}
	[self update_accel_x_position:g];
	_air_params._w_camera_center += _air_params._w_upwards_vel * dt_scale_get();
	[g set_camera_height:_air_params._w_camera_center];
	[self apply_s_pos:g];
	
	if (g.player.position.y < 0 && _air_params._current_mode != PlayerAirCombatMode_InitialJumpOut) {
		[self prep_transition_air_to_land_mode:g];
		[g.get_air_enemy_manager notify_enemies_leave:g];
	}
}

-(void)update_air_to_ground_transition:(GameEngineScene*)g {
	CGPoint last_pos = self.position;
	[self update_accel_x_position:g];
	if (g.player.position.y < 0) {
		[self play_anim:@"swim" repeat:YES];
		_land_params._vel = ccp(_land_params._vel.x,_land_params._vel.y + 0.4 * dt_scale_get());
		g.player.position = CGPointAdd(g.player.position, ccp(0,_land_params._vel.y*dt_scale_get()));
		if (g.player.position.y > 0) {
			[g add_ripple:ccp(g.player.position.x,0)];
		}
		[g set_camera_height:drp(g.get_current_camera_center_y,-50,20)];
		float tar_rotation = vec_ang_deg_lim180(vec_cons(self.position.x - last_pos.x,self.position.y - last_pos.y, 0),90);
		self.rotation += shortest_angle(self.rotation, tar_rotation) * 0.25;
		
	} else {
		[self play_anim:@"spin" repeat:YES];
		if (g.player.position.y > g.DOCK_HEIGHT) _land_params._vel = ccp(_land_params._vel.x,_land_params._vel.y - 0.4 * dt_scale_get());
		g.player.position = CGPointAdd(g.player.position, ccp(0,_land_params._vel.y*dt_scale_get()));
		if (_land_params._vel.y < 0 && g.player.position.y < g.DOCK_HEIGHT) {
			[self prep_transition_air_to_land_finish_mode:g];
			return;
		}
		[g set_camera_height:drp(g.get_current_camera_center_y,30,20)];
	}
}

-(BOOL)is_underwater:(GameEngineScene *)g {
	return self.position.y < 0;
}

-(CGPoint)get_size { return ccp(40,130); }
-(HitRect)get_hit_rect {
	return satpolyowner_cons_hit_rect(self.position, self.get_size.x, self.get_size.y);
}
-(void)get_sat_poly:(SATPoly*)in_poly {
	return satpolyowner_cons_sat_poly(in_poly, self.position, self.rotation, self.get_size.x, self.get_size.y, ccp(1,1));
}
@end
