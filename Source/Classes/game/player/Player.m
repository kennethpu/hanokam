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

@implementation Player {
	CCAction *_anim_stand;
	CCAction *_current_anim;
	SpriterNode *_img;
	
	float _x_prev, _x_vel;
	float _rotate_vel;
	float _vel_lerp;
	
	float _aim_dir, _reload;
	float _salto;
	
	int combat_step;
	BOOL _state_waveEnd_jump_back;
	
	
	CCSprite *_bar1, *_bar2;
	
	NSMutableArray *_arrows;
	
}
@synthesize _vx,_vy;

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	_arrows = [NSMutableArray array];
	
	_bar1 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_AIMING_BAR]] add_to:self z:0];
	[_bar1 set_anchor_pt:ccp(0, 2)];
	[_bar1 set_scale:0.2];
	
	_bar2 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_AIMING_BAR]] add_to:self z:0];
	[_bar2 set_anchor_pt:ccp(0, -1)];
	[_bar2 set_scale_x:0.2];
	[_bar2 set_scale_y:-.2];
	
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"hanoka v0.01.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_CHAR_HANOKATEST] frames:frame_data scml:@"hanoka v0.01.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[_img playAnim:@"swim" repeat:YES];
	[self addChild:_img z:1];
	[self set_pos:game_screen_pct(0.5, 0.5)];
	[_img set_scale:0.2];
	
	_state_waveEnd_jump_back = false;
	
	_reload = 10;
	[_bar1 setOpacity:0];
	[_bar2 setOpacity:0];
	
	return self;
}

-(void)update_game:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	
	_aim_dir = [self angle_towards_x:g.touch_position.x y:g.touch_position.y + g.get_camera_y - game_screen().height / 2] * (180 / M_PI) - 90;
	
	switch ([g get_player_state]) {
		case PlayerState_Dive:
			if ([self is_underwater]) {
				
				[g set_zoom:g.zoom + (1 - g.zoom) * .3];
				
				if(float_random(0, 1) < .1) {
					[g add_particle:(Particle*)[[[[ParticleBubble cons_tex:[Resource get_tex:TEX_PARTICLE_BUBBLE]
						rect:CGRectMake(0, 0, 55, 55)]
						explode_speed:1]
						set_pos:ccp(_x, _y)]
						set_scale:.5]];
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
					
					if(_vy < -5)
						_vy += (13 -_vy) * 0.004 * dt_scale_get();
					else
						_vy += (13 -_vy) * 0.02 * dt_scale_get();
				}
				
				if([g.get_spirit_manager dive_y] > _y && g.touch_down) {
					[g.get_spirit_manager set_dive_y: _y];
				}
				
				if(_y > [g.get_spirit_manager dive_y] + 100) {
					g._player_state = PlayerState_Return;
					//[g.get_spirit_manager set_dive_y: 0];
				}
				
			} else {
				_vy += .2;
			}
	
		break;
		case PlayerState_Return:
			[g set_zoom:g.zoom + (1.4 - g.zoom) * .05];
			_rotate_vel += (_x_vel / 9 - _rotate_vel) * .3 * dt_scale_get();
			_rotation = clampf(M_PI -_vy, 0, M_PI) + _rotate_vel;
		
			_vy += (17 -_vy) * 0.01 * dt_scale_get();
			if (![self is_underwater]) {
				g._player_state = PlayerState_Combat;
				_vy = 10;
				[_img playAnim:@"in air" repeat:YES];
				[g.get_spirit_manager reset_dive];
			}
		break;
		case PlayerState_Combat:
			[g set_zoom:g.zoom + (1 - g.zoom) * .1];
			_rotation = 0;
			
			_y += 5 * dt_scale_get();
			if(_vy < 3 && _vy > -2 && g.touch_down) {
				_vy -= 0.15 * dt_scale_get();
			} else {
				_vy -= 0.3 * dt_scale_get();
			}
			
			if (_salto > 1) {
				_salto -= .1 * dt_scale_get();
			} else if (_salto < -1) {
				_salto += .1 * dt_scale_get();
			}
			
			_salto -= _salto * .06 * dt_scale_get();

			_rotation += _salto;
			
			if(combat_step == 0 && self.position.y > 300) {
				[g.get_spirit_manager toss_spirit];
				[g.get_spirit_manager toss_spirit];
				[g.get_spirit_manager toss_spirit];
				combat_step ++;
			}
			
			if (_vy < 0 && _y + _vy * dt_scale_get() < 20) {
				_y = 20;
				_vy = 0;
				[g shake_slow_for:30 distance:30];
				g._player_state = PlayerState_WaveEnd;
				_state_waveEnd_jump_back = false;
				combat_step = 0;
			}
			
			if(g.touch_down && roundf(_salto) == 0) {
				if(_reload > 1) {
					_reload -= .4;
				}
				
				if(_bar1.opacity < 1)
						[_bar1 setOpacity:_bar1.opacity + .2];
					
					if(_bar2.opacity < 1)
						[_bar2 setOpacity:_bar1.opacity];
					
					[_bar1 setRotation:_aim_dir + _reload * 5];
					[_bar2 setRotation:_aim_dir - _reload * 5];
			}
			
			if(g.touch_released) {
				[self shoot_arrow:g];
			}
			
		break;
		case PlayerState_WaveEnd:
			
			if(!_state_waveEnd_jump_back) {
				_y = 20;
				_vy = 0;
				if(g.touch_tapped) {
					_state_waveEnd_jump_back = true;
					
					_vy = 5;
				}
			} else {
				_rotation += .1 * dt_scale_get();
			
				_vy -= .5 * dt_scale_get();
				if(_y < 0) {
					g._player_state = PlayerState_Dive;
					[g.get_spirit_manager set_dive_y:0];
					_vy = -10;
					[g shake_slow_for:100 distance:10];
					[_img playAnim:@"swim" repeat:YES];
					[g add_ripple:self.position];
				}
			}
		break;
	}
	
	if ([self is_underwater]) {
		_x += _vx * dt_scale_get();
		_y += _vy * dt_scale_get();
	} else {
		_x += _vx * dt_scale_get();
		/*
		if(_vy > 2)
			_vel_lerp += (1.3 - _vel_lerp) * .6 * dt_scale_get(); // going up
		else if (_vy > -2)
			_vel_lerp += (.4 - _vel_lerp) * .4 * dt_scale_get(); // hold at peek
		else
			_vel_lerp += (1.5 - _vel_lerp) * .3 * dt_scale_get(); // going down
		
		_y += _vy * _vel_lerp * dt_scale_get();
		*/
		_y += _vy / 2 + (_vy * ABS(_vy) / 15) * dt_scale_get();
	}
	
	_x_vel = _x - _x_prev;
	_x_prev = _x;
	
	
	NSMutableArray *arrows_to_remove = [NSMutableArray array];
	for (Arrow *arrow in _arrows) {
		[arrow i_update:g];
		if (arrow.position.x > game_screen().width + 100 || arrow.position.x < -100) {
			[arrows_to_remove addObject:arrow];
			[arrow removeFromParent];
		}
	}
	[_arrows removeObjectsInArray:arrows_to_remove];
	[arrows_to_remove removeAllObjects];
	
	[self setRotation:_rotation * 57.2957795];
	
	_x = clampf(_x, 0, game_screen().width);
	_y = clampf(_y, g.get_ground_depth, INFINITY);
	[self setPosition:ccp(_x,_y)];
}

-(Arrow*)shoot_arrow:(GameEngineScene*)g {
	Arrow *_new_arrow = (Arrow*)[[[[Arrow cons] add_to:g.get_anchor z:3]
		set_pos:self.position]
		set_rotation:_aim_dir + float_random(-_reload, _reload)];
	
	[_arrows addObject:_new_arrow];
	
	_reload = 10;
	[_bar1 setOpacity:0];
	[_bar2 setOpacity:0];
	return _new_arrow;
}

-(float)angle_towards_x:(float)x y:(float)y {
	return atan2f(x - self.position.x, y - self.position.y);
}

-(void)melee_spirit {
	_vy = 12;
	_salto = M_PI * 2 * signum(float_random(-100, 50));
	_reload = 10;
	[_bar1 setOpacity:0];
	[_bar2 setOpacity:0];
}

-(BOOL)is_underwater {
	return self.position.y < 0;
}

-(void)run_anim:(CCAction*)tar {
	if (_current_anim != tar) {
		_current_anim = tar;
		[_img stopAllActions];
		[_img runAction:_current_anim];
	}
}

-(HitRect)get_hit_rect {
	return hitrect_cons_xy_widhei(self.position.x-10, self.position.y, 20, 40);
}
@end
