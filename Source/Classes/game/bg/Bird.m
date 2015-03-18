//
//  Bird.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bird.h"

@implementation Bird {
	CCSprite *_obj_bird;
	float _ct;
}

+(Bird*)cons {
	return [[Bird node] cons];
}

-(Bird*)cons {
	_obj_bird = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_OBJ_BIRD]] add_to:self z:0];
	[_obj_bird set_anchor_pt:ccp(0,0)];
	[_obj_bird set_scale:0.5];
	_ct = float_random(0, 10);
	return self;
}

-(void)i_update:(GameEngineScene *)game {
	self.position = CGPointAdd(ccp(3,0), self.position);
	_obj_bird.position = ccp(0,sinf(_ct) * 10);
	_ct += 0.1;
}

@end
