//
//  Bird.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bird.h"
#import "GameEngineScene.h"
#import "Resource.h"

@implementation Bird {
	CCSprite *_obj_bird;
}

+(Bird*)cons {
	return [[Bird node] cons];
}

-(Bird*)cons {
	_obj_bird = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_OBJ_BIRD]] add_to:self z:0];
	[_obj_bird set_anchor_pt:ccp(0,0)];
	[_obj_bird set_scale:0.5];
	return self;
}

@end
