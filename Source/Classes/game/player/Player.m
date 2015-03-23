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

#import "CCTexture_Private.h"

@implementation Player {
	CCAction *_anim_stand;
	CCAction *_current_anim;
	SpriterNode *_img;
	
	float _x_prev;
	float _x_vel;
	float _rotate_vel;
	
	int combat_step;
	BOOL _state_waveEnd_jump_back;
	
	NSMutableArray *_arrows;
	
}
@synthesize _vx,_vy;

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"hanoka v0.01.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_CHAR_HANOKATEST] frames:frame_data scml:@"hanoka v0.01.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[_img playAnim:@"swim" repeat:YES];
	[self addChild:_img z:1];
	[self set_pos:game_screen_pct(0.5, 0.5)];
	[_img set_scale:0.2];
	
	_state_waveEnd_jump_back = false;
	
	return self;
}

-(void)update_game:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	
	//_x += (g.touch_position.x - _x) * .4;
	
	switch ([g get_player_state]) {
		case PlayerState_Dive:
			if ([self is_underwater]) {
				_rotate_vel += (_x_vel / 9 * signum(_vy) - _rotate_vel) * .3 * dt_scale_get();
				_rotation = clampf(M_PI -_vy, 0, M_PI) + _rotate_vel;
				
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
					[g.get_spirit_manager set_dive_y: 0];
				}
				
			} else {
				_vy += .2;
			}
	
		break;
		case PlayerState_Return:
		
			_rotate_vel += (_x_vel / 9 * signum(_vy) - _rotate_vel) * .3 * dt_scale_get();
			_rotation = clampf(M_PI -_vy, 0, M_PI) + _rotate_vel;
		
			_vy += (17 -_vy) * 0.01 * dt_scale_get();
			if (![self is_underwater]) {
				g._player_state = PlayerState_Combat;
				_vy = 10;
				[_img playAnim:@"in air" repeat:YES];
			}
		break;
		case PlayerState_Combat:
			_rotation = 0;
			
			_y += 5 * dt_scale_get();
			if(_vy < 5 && _vy > 0) // hold at peek
				_vy -= 0.2 * dt_scale_get();
			else
				_vy -= 0.3 * dt_scale_get();
			
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
				}
			}
			
		break;
	}
	
	if ([self is_underwater]) {
		_x += _vx * dt_scale_get();
		_y += _vy * dt_scale_get();
	} else {
		_x += _vx * dt_scale_get();
		if(_vy > .7)
			_y += _vy * dt_scale_get() * 1.5;
		else if (_vy > 0)
			_y += _vy * dt_scale_get() * 0.5;
		else
			_y += _vy * dt_scale_get() * 1;
	}
	
	_x_vel = _x - _x_prev;
	_x_prev = _x;
	
	/*
	NSMutableArray *birds_to_remove = [NSMutableArray array];
	for (Bird *bird in _birds) {
		[bird i_update:g];
		if (bird.position.x > game_screen().width + 100) {
			[birds_to_remove addObject:bird];
			[bird removeFromParent];
		}
	}
	[_birds removeObjectsInArray:birds_to_remove];
	[birds_to_remove removeAllObjects];
	*/
	
	[self shoot_arrow];
	
	[self setRotation:_rotation * 57.2957795];
	[self setPosition:ccp(clampf(_x, 0, game_screen().width),_y)];
}

-(Arrow*)shoot_arrow {
	Arrow *_new_arrow = (Arrow*)[[[Arrow cons] add_to:self z:3]set_pos:self.position];
	
	[_arrows addObject:_new_arrow];
	return _new_arrow;

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
