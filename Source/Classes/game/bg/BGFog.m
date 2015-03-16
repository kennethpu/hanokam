//
//  BGFog.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGFog.h"

@implementation BGFog {
	CCSprite *_bg_fog;
	
	int _test;
}

+(BGFog*)cons {
	return [[BGFog node] cons];
}

-(BGFog*)cons {
	_bg_fog = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_FOG]] add_to:self z:3];
	[_bg_fog set_anchor_pt:ccp(0,0)];
	[_bg_fog set_scale:0.5];
	scale_to_fit_screen_x(_bg_fog);
	
	return self;
}
@end
