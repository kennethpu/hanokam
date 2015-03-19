//
//  EnemyBasic.m
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpiritBasic.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "Common.h"
#import "SpiritManager.h"

#import "Player.h"

@implementation SpiritBasic {
	CCSprite *_obj_sprite;
	
	float _vx, _vy;
	float _aimDir;
	float _wave;
	int _followPos;
	BOOL _following;
}

+(SpiritBasic*) cons_posX:(float)posX {
	return [[SpiritBasic node] cons_posX:posX];
}

-(SpiritBasic*) cons_posX:(float)posX {
	_following = false;
	[self setPosition:ccp(posX, 0)];
	
	_obj_sprite = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_SPIRIT_FISH_1]] add_to:self z:0];
	[_obj_sprite set_anchor_pt:ccp(.5, .5)];
	[_obj_sprite set_scale:0.3];
	
	return self;
}


-(void)i_update_game:(GameEngineScene*)g manager:(SpiritManager*)manager{
	float _x = self.position.x;
	float _y = self.position.y;
	float _rotation = self.rotation * .0174532925;
	
	_wave += _vy / 50;
	
	if(!_following) {
		// RUNNER WAITING FOR PLAYER
		if(g.player.position.y < _y) {
			_following = true;
			_followPos = [SpiritManager followPos];
			[SpiritManager advanceFollowPos];
		}
	} else {
		if(_y < 0) {
			// UNDER WATER
			if(g.touchDown){
				float gotoY = g.player.position.y + _followPos * 20 + 100;
				if(_y > gotoY) {
					_aimDir = [self angle_towards_x:(g.player.position.x + sinf(_wave) * 30 + ((_followPos + 1) % 3 - 1) * 30) y:gotoY];
					_vx += (sinf(_aimDir) * 10 - _vx) * .02;
					_vy += (cosf(_aimDir) * 15 - _vy) * .1;
				} else {
					_vy *= .9;
				}
				
			} else {
				if(_y > g.player.position.y) {
					_vy += (-6 - _vx) * .07;
				} else {
					_aimDir = [self angle_towards_x:g.player.position.x y:g.player.position.y - _followPos * 50 - 100];
				
					_vx += (sinf(_aimDir) * 10 - _vx) * .02;
					_vy += (cosf(_aimDir) * 20 - _vy) * .1;
				}
			}
			_vx *= .95;
			_vy *= .95;
		} else {
			if(g.player.position.x > _x - 15 && g.player.position.x < _x + 15) {
				if(g.player.position.y < _y && g.player.position.y > _y - 20) {
					g.player._vy = 12;
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

-(float)angle_towards_x:(float)x y:(float)y {
	return atan2f(x - self.position.x, y - self.position.y);
}

@end