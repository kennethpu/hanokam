#import "Player.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"

#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"
#import "SpiritManager.h"

#import "Arrow.h"
#import "ParticleBubble.h"

#import "CCTexture_Private.h"
#import "ControlManager.h"

typedef enum _PlayerAirCombatMode {
	PlayerAirCombatMode_InitialJumpOut,
	PlayerAirCombatMode_Combat,
	PlayerAirCombatMode_RescueBackToTop,
	PlayerAirCombatMode_FallToGround
} PlayerAirCombatMode;

@interface PlayerAirCombatParams : NSObject
@property(readwrite,assign) CGPoint _s_pos, _s_vel;
@property(readwrite,assign) float _w_camera_center, _w_upwards_vel, _anim_ct;
@property(readwrite,assign) PlayerAirCombatMode _current_mode;

@property(readwrite,assign) BOOL _sword_out;
@property(readwrite,assign) float _arrow_throwback_ct;
@end

@implementation PlayerAirCombatParams
@synthesize _s_pos,_s_vel;
@synthesize _w_camera_center, _w_upwards_vel, _anim_ct;
@synthesize _current_mode;
@synthesize _sword_out;
@synthesize _arrow_throwback_ct;
-(void)set_player_s_pos:(GameEngineScene*)g {
	g.player.position = CGPointAdd(_s_pos, ccp(g.get_viewbox.x1,g.get_viewbox.y1));
}
-(float)DEFAULT_HEIGHT {
	return game_screen().height * 0.8;
}
@end

@implementation Player {
	SpriterNode *_img;
	
	NSString *_current_playing;
	NSString *_on_finish_play_anim;
	
	float _x_prev, _x_vel, _x_deck;
	float _rotate_vel;
	float _vel_lerp;
	
	float _aim_dir, _reload;
	float _salto;
	
	int combat_step;
	BOOL _state_waveEnd_jump_back, _small_jump_back;
	
	int _birds_left;
	
	PlayerAirCombatParams *_air_params;
}
@synthesize _vx, _vy;
@synthesize _falling;

-(int)stat_damage { return 1; }

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	_air_params = [[PlayerAirCombatParams alloc] init];
	
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"hanokav2.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_CHAR_HANOKA_V2] frames:frame_data scml:@"hanokav2.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[self goto_anim:@"idle"];
	[self addChild:_img z:1];
	[self set_pos:game_screen_pct(0.5, 0.5)];
	[_img set_scale:0.25];
	
	_state_waveEnd_jump_back = false;
	
	return self;
}

-(void)update_game:(GameEngineScene*)g {
	if (g.get_player_state == PlayerState_OnGround && !_state_waveEnd_jump_back) {
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

-(void)goto_anim:(NSString*)anim {
	_on_finish_play_anim = NULL;
	if(_current_playing != anim) {
		_current_playing = anim;
		[_img playAnim:anim repeat:YES];
	}
}

-(void)play_anim:(NSString*)anim1 on_finish_anim:(NSString*)anim2 {
	_current_playing = anim1;
	[_img playAnim:anim1 repeat:NO];
	_on_finish_play_anim = anim2;
}

-(void)prep_air_mode:(GameEngineScene*)g {
	g._player_state = PlayerState_InAir;
	_air_params._w_camera_center = [g get_cam_y_lirp_current];
	_air_params._w_upwards_vel = 6;
	_air_params._s_pos = CGPointSub(g.player.position, ccp(g.get_viewbox.x1,g.get_viewbox.y1));
	_air_params._s_vel = ccp(0,0);
	_air_params._current_mode = PlayerAirCombatMode_InitialJumpOut;
	_air_params._anim_ct = 0;
	_air_params._sword_out = NO;
	_air_params._arrow_throwback_ct = 2;
	_vy = 0;
	_vx = 0;
	if (_air_params._s_pos.y > 250) {
		_air_params._anim_ct = clampf((_air_params._s_pos.y - 250)/400.0,0,0.5);
	}
}

-(void)update_in_air:(GameEngineScene*)g {
	update_again:
	switch (_air_params._current_mode) {
		case PlayerAirCombatMode_InitialJumpOut:;
			_air_params._anim_ct = clampf(_air_params._anim_ct + 0.025 * dt_scale_get(), 0, 1);
			_air_params._s_pos = ccp(_air_params._s_pos.x,lerp(_air_params._s_pos.y, _air_params.DEFAULT_HEIGHT, _air_params._anim_ct));
			if (_air_params._anim_ct >= 1) {
				_air_params._current_mode = PlayerAirCombatMode_Combat;
			}
			[g set_zoom:drp(g.zoom, 1, 4)];
			
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
				CGPoint delta = CGPointSub(tap, _air_params._s_pos);
				[g add_player_projectile:[Arrow cons_pos:self.position dir:vec_cons_norm(delta.x, delta.y, 0)]];
				if (_air_params._arrow_throwback_ct > 0) {
					_air_params._s_vel = ccp(
						_air_params._s_vel.x,
						MAX(_air_params._arrow_throwback_ct, _air_params._s_vel.y)
					);
					_air_params._arrow_throwback_ct -= 0.1;
				}
			}
			
			_air_params._s_pos = ccp(
				_air_params._s_pos.x+_air_params._s_vel.x,
				clampf(_air_params._s_pos.y+_air_params._s_vel.y,-INFINITY,_air_params.DEFAULT_HEIGHT)
			);
			
		break;
		case PlayerAirCombatMode_RescueBackToTop:;
			_air_params._sword_out = NO;
		break;
		case PlayerAirCombatMode_FallToGround:;
			_air_params._sword_out = NO;
		break;
	}
	_air_params._s_pos = ccp(
		clampf(_air_params._s_pos.x + clampf(((160 + g.get_control_manager.get_accel_x * 320) - _air_params._s_pos.x) * .07, - 7, 7) * dt_scale_get(),0,game_screen().width),
		_air_params._s_pos.y
	);
	_air_params._w_camera_center += _air_params._w_upwards_vel * dt_scale_get();
	[g center_camera_hei:_air_params._w_camera_center];
	[_air_params set_player_s_pos:g];
	if (g.player.position.y < 0 && _air_params._current_mode != PlayerAirCombatMode_InitialJumpOut) {
		g._player_state = PlayerState_AirToGroundTransition;
		g.player._vy = clampf(_air_params._w_upwards_vel + _air_params._s_vel.y,-15,-5);
		[g add_ripple:ccp(g.player.position.x,0)];
	}
}

-(void)update_air_to_ground_transition:(GameEngineScene*)g {
	g.player.position = ccp(
		clampf(g.player.position.x + clampf(((160 + g.get_control_manager.get_accel_x * 320) - _air_params._s_pos.x) * .07, - 7, 7) * dt_scale_get(), 0, game_screen().width),
		g.player.position.y
	);
	if (g.player.position.y < 0) {
		[self goto_anim:@"swim"];
		g.player._vy += 0.4 * dt_scale_get();
		g.player.position = CGPointAdd(g.player.position, ccp(0,g.player._vy*dt_scale_get()));
		float _rotation = self.rotation * .0174532925;
		_rotate_vel += (_x_vel / 9 - _rotate_vel) * .3 * dt_scale_get();
		_rotation = clampf(M_PI -_vy, 0, M_PI) - _rotate_vel;
		[self setRotation:_rotation * 57.2957795];
		if (g.player.position.y > 0) {
			[g add_ripple:ccp(g.player.position.x,0)];
		}
		[g center_camera_hei:drp(g.camera_center_point.y, -50, 10)];
		
	} else {
		[self goto_anim:@"spin"];
		if (g.player.position.y > g.DOCK_HEIGHT) g.player._vy -= 0.4 * dt_scale_get();
		g.player.position = CGPointAdd(g.player.position, ccp(0,g.player._vy*dt_scale_get()));
		if (g.player._vy < 0 && g.player.position.y < g.DOCK_HEIGHT) {
			g.player.position = ccp(g.player.position.x,g.DOCK_HEIGHT);
			_vy = 0;
			_falling = false;
			_small_jump_back = false;
			combat_step = 0;
			_state_waveEnd_jump_back = false;
			self.rotation = 0;
			g._player_state = PlayerState_OnGround;
			return;
		}
		[g center_camera_hei:drp(g.camera_center_point.y, 30, 10)];
		
	}
	

	_x_vel = self.position.x - _x_prev;
	_x_prev = self.position.x;
	
}

-(void)update_dive:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	_aim_dir = [self angle_towards_x:g.touch_position.x y:g.touch_position.y + g.get_camera_y - game_screen().height / 2] * (180 / M_PI) - 90;

    _x += clampf(((160 + g.get_control_manager.get_accel_x * 320) - _x) * .1, - 7, 7) * dt_scale_get();
    
    if(_x < game_screen().width / 2) {
        [_img set_scale_x:-0.25];
    } else {
        [_img set_scale_x: 0.25];
    }
    
    if ([self is_underwater:g]) {
        
        [g set_zoom: g.zoom + (1 - g.zoom) * .3];
        
        if(float_random(0, 1) < .1) {
            [g add_particle: (Particle*)[[[[ParticleBubble cons_tex:[Resource get_tex:TEX_PARTICLE_BUBBLE]
                                                               rect: CGRectMake(0, 0, 20, 20)]
                                           explode_speed: 1]
                                          set_pos: ccp(_x, _y)]
                                         set_scale: .5]];
        }
        
        _rotate_vel += (_x_vel / 9 - _rotate_vel) * .3 * dt_scale_get();
        _rotation = clampf(M_PI -_vy, 0, M_PI) - _rotate_vel;
        
        if(g.touch_down) {
            _vy += (-5 -_vy) * 0.025 * dt_scale_get();
        } else {
            if(g.touch_released) {
                if(_vy > - 8)
                    _vy *= 1.3;
                else if (_vy > 0) {
                    _vy *= .1;
                }
            }
            
            _vy += (5 -_vy) * 0.02 * dt_scale_get();
            
            /*
             if(_vy < -5)
             _vy += (13 -_vy) * 0.004 * dt_scale_get();
             else
             _vy += (13 -_vy) * 0.02 * dt_scale_get();
             */
        }
        
        if([g.get_spirit_manager dive_y] > _y && g.touch_down) {
            [g.get_spirit_manager set_dive_y: _y];
        }
        
        if(_y > [g.get_spirit_manager dive_y] + 100) {
            g._player_state = PlayerState_DiveReturn; // <--
        }
        
    } else {
        _vy += .2;
    }

	if ([self is_underwater:g]) {
		_x += _vx * dt_scale_get();
		_y += _vy * dt_scale_get();
	} else {
		_x += _vx * dt_scale_get();
		_y += _vy / 2 + (_vy * ABS(_vy) / 15) * dt_scale_get();
	}
	_x_vel = _x - _x_prev;
	_x_prev = _x;
	[self setRotation:_rotation * 57.2957795];
	_x = clampf(_x, 0, game_screen().width);
	_y = clampf(_y, g.get_ground_depth, INFINITY);
	[self setPosition:ccp(_x,_y)];
}

-(void)update_dive_return:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	_aim_dir = [self angle_towards_x:g.touch_position.x y:g.touch_position.y + g.get_camera_y - game_screen().height / 2] * (180 / M_PI) - 90;

	_x += clampf(((160 + g.get_control_manager.get_accel_x * 320) - _x) * .08, -6, 6) * dt_scale_get();

	if(_x < game_screen().width / 2) {
		[_img set_scale_x: 0.25];
	} else {
		[_img set_scale_x:-0.25];
	}

	[g set_zoom:g.zoom + (1.5 - g.zoom) * .05];
	_rotate_vel += (_x_vel / 9 - _rotate_vel) * .3 * dt_scale_get();
	_rotation = clampf(M_PI -_vy, 0, M_PI) + _rotate_vel;

	_vy += (17 -_vy) * 0.01 * dt_scale_get();
	if (![self is_underwater:g]) {
		[g add_ripple:CGPointAdd(self.position, ccp(0,-20))];
		if(g.get_spirit_manager.dive_y < -200) {
			_vy = 10;
		} else {
			_vy = 5;
			_small_jump_back = true;
		}
		_birds_left = 3;
		
		[self goto_anim:@"in air"];
		[g.get_spirit_manager reset_dive];
		[g.get_spirit_manager kill_all_with_spirit_state_waiting];
		
		//g._player_state = PlayerState_InAir; // <--
		[self prep_air_mode:g];
	}
	if ([self is_underwater:g]) {
		_x += _vx * dt_scale_get();
		_y += _vy * dt_scale_get();
	} else {
		_x += _vx * dt_scale_get();
		_y += _vy / 2 + (_vy * ABS(_vy) / 15) * dt_scale_get();
	}
	_x_vel = _x - _x_prev;
	_x_prev = _x;
	[self setRotation:_rotation * 57.2957795];
	_x = clampf(_x, 0, game_screen().width);
	_y = clampf(_y, g.get_ground_depth, INFINITY);
	[self setPosition:ccp(_x,_y)];
}

-(void)update_on_ground:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	_aim_dir = [self angle_towards_x:g.touch_position.x y:g.touch_position.y + g.get_camera_y - game_screen().height / 2] * (180 / M_PI) - 90;
	if(!_state_waveEnd_jump_back) {
		[g set_zoom:g.zoom + (1.1 - g.zoom) * .2];
		
		if(160 + g.get_control_manager.get_accel_x * 320 < _x - 25) {
			[_img set_scale_x:-0.25];
			_vx += (-3 - _vx) * .2 * dt_scale_get();
		} else if(160 + g.get_control_manager.get_accel_x * 320 > _x + 25) {
			[_img set_scale_x: 0.25];
			_vx += (3 - _vx) * .2 * dt_scale_get();
		} else {
			_vx -= _vx * .07 * dt_scale_get();
		}
		
		if(ABS(_vx) > .5) {
			[self goto_anim:@"run"];
		} else {
			[self goto_anim:@"idle"];
		}

		_y = [g DOCK_HEIGHT];
		_vy = 0;
		if(g.touch_tapped) {
			_state_waveEnd_jump_back = true;
			_vy = 10;
			
			[self goto_anim:@"in air"];
			
			if(_x < game_screen().width / 2) {
				[_img set_scale_x: 0.25];
			} else {
				[_img set_scale_x:-0.25];
			}
		}
	} else {
		_x += clampf(((160 + g.get_control_manager.get_accel_x * 320) - _x) * .07, - 7, 7) * dt_scale_get();
		
		[g set_zoom:g.zoom + (1 - g.zoom) * .1];
		_rotation += .08 * dt_scale_get() * signum(_img.scaleX);

		_vy -= .5 * dt_scale_get();
		if(_y < 0) {
			g._player_state = PlayerState_Dive; // <--
			[g.get_spirit_manager set_dive_y:0];
			if(g.touch_down){
				_vy = -10;
			} else {
				_vy = -6;
			}
			[g shake_slow_for:100 distance:10];
			[self goto_anim:@"swim"];
			[g add_ripple:self.position];
		}
	}
	if ([self is_underwater:g]) {
		_x += _vx * dt_scale_get();
		_y += _vy * dt_scale_get();
	} else {
		_x += _vx * dt_scale_get();
		_y += _vy / 2 + (_vy * ABS(_vy) / 15) * dt_scale_get();
	}
	_x_vel = _x - _x_prev;
	_x_prev = _x;
	[self setRotation:_rotation * 57.2957795];
	_x = clampf(_x, 0, game_screen().width);
	_y = clampf(_y, g.get_ground_depth, INFINITY);
	[self setPosition:ccp(_x,_y)];
}

-(float)angle_towards_x:(float)x y:(float)y {
	return atan2f(x - self.position.x, y - self.position.y);
}

-(BOOL)is_underwater:(GameEngineScene *)g {
	return self.position.y < 0;
}

-(HitRect)get_hit_rect {
	return hitrect_cons_xy_widhei(self.position.x-6, self.position.y-12, 12, 24);
}
@end
