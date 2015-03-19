#import "Player.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"
#import "SpriterNode.h"
#import "SpriterData.h"
#import "SpiritManager.h"

#import "CCTexture_Private.h"

@implementation Player {
	CCAction *_anim_stand;
	CCAction *_current_anim;
	SpriterNode *_img;
	
	BOOL _state_waveEnd_jump_back;
	
	float _diveY;
}
@synthesize _vx,_vy;

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_CHAR_HANOKATEST] json:@"hanoka v0.01.json" scml:@"hanoka v0.01.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[_img playAnim:@"in air" repeat:YES];
	[self addChild:_img z:1];
	
	[self set_pos:game_screen_pct(0.5, 0.5)];
	[_img set_scale:0.3];
	
	_state_waveEnd_jump_back = false;
	
	return self;
}

-(void)update_game:(GameEngineScene*)g {
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	
	switch ([g get_player_state]) {
		case PlayerState_Dive:
			if ([self is_underwater]) {
				
				if(g.touchDown) {
					_vy += (-7 -_vy) * 0.018 * dt_scale_get();
				} else {
					_vy += (13 -_vy) * 0.01 * dt_scale_get();
				}
				
				if(_diveY > _y) {
					_diveY = _y;
				}
				
				if(_y > _diveY + 100) {
					g._playerState = PlayerState_Return;
				}
				
				_rotation = clampf(180 - _vy * 40, 0, 180);
			} else {
				g._playerState = PlayerState_Combat;
			}
	
		break;
		case PlayerState_Return:
			_vy += (17 -_vy) * 0.01 * dt_scale_get();
			if (![self is_underwater]) {
				g._playerState = PlayerState_Combat;
			}
		break;
		case PlayerState_Combat:
			if(_vy < 5 && _vy > 0)
				_vy -= 0.1 * dt_scale_get();
			else
				_vy -= 0.2 * dt_scale_get();
			
			if (_y < 20) {
				_y = 20;
				_vy = 0;
				g._playerState = PlayerState_WaveEnd;
				_state_waveEnd_jump_back = false;
			}
		break;
		case PlayerState_WaveEnd:
			
			if(!_state_waveEnd_jump_back) {
				_y = 20;
				_vy = 0;
				if(g.touchTap) {
					_state_waveEnd_jump_back = true;
					_vy = 5;
				}
			} else {
				_vy -= .5;
				if(_y < 0) {
					g._playerState = PlayerState_Dive;
					_diveY = 0;
					_vy = -10;
					[SpiritManager resetFollowPos];
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
			_y += _vy * dt_scale_get() * 1;
		else
			_y += _vy * dt_scale_get() * 2;
	}
	
	
	[self setPosition:ccp(clampf(_x, 0, game_screen().width),_y)];
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
