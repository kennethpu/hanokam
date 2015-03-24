//
//  Fish
//  hanoka
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Spirit_Fish_1.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "Common.h"
#import "SpiritManager.h"

#import "Player.h"

@implementation Spirit_Fish_1 {
	CCSprite *_obj_sprite;
	int _movement;
	float _vx, _vy;
}

+(SpiritBase*) cons_size:(float)size {
	return [[Spirit_Fish_1 node] cons_size:size];
}

-(Spirit_Fish_1*) cons_size:(float)size {
	_obj_sprite = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_SPIRIT_FISH_1]] add_to:self z:1];
	[_obj_sprite set_anchor_pt:ccp(.5, .5)];
	[_obj_sprite set_scale: 0.2 * size];
	_movement = int_random(0, 2);
	[super cons_size: size];
	
	return self;
}

-(void)water_behavior:(GameEngineScene *)g {
	switch (_movement) {
		case 0:
			if(self.position.x > 50) {
				_vx = 2;
				_vy = 1;
			} else {
				_movement = 1;
			}
		break;
		case 1:
			if(self.position.x < game_screen().width - 50) {
				_vx = -2;
				_vy = 1;
			} else {
				_movement = -1;
			}
		break;
		case 2:
		break;
		default:
		break;
	}
	
	super._vx = _vx;
	super._vy = _vy;
}

-(void)air_behavior:(GameEngineScene *)g {
}

@end