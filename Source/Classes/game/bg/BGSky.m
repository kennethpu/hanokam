//
//  BGSky.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGSky.h"
#import "Common.h"
#import "Resource.h"
#import "CCTexture_Private.h"

@implementation BGSky {
	CCSprite *_sky_bg;
	
	CCSprite *_bldg_1, *_bldg_2, *_bg_fog;
	
	int _test;
}
+(BGSky*)cons {
	return [[BGSky node] cons];
}

-(id)cons {
	_sky_bg = (CCSprite*)[[CCSprite node] add_to:self z:0];
	[_sky_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_SKY]];
	[_sky_bg set_anchor_pt:ccp(0,0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_sky_bg.texture setTexParameters:&par];
	
	_bldg_2 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_BLDG2]] add_to:self z:1];
	[_bldg_2 set_scale:0.5];
	[_bldg_2 set_pos:game_screen_pct(1, 0)];
	[_bldg_2 set_anchor_pt:ccp(1,0)];
	
	_bldg_1 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_BLDG1]] add_to:self z:2];
	[_bldg_1 set_scale:0.5];
	[_bldg_1 set_anchor_pt:ccp(0,0)];
	
	_bg_fog = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_FOG]] add_to:self z:3];
	[_bg_fog set_anchor_pt:ccp(0,0)];
	[_bg_fog set_scale:0.5];
	scale_to_fit_screen_x(_bg_fog);
	
	return self;
}

-(void)i_update:(GameEngineScene*)game {
	[_sky_bg setTextureRect:CGRectMake(0,MAX(0, [game get_viewbox].y1),game_screen().width,MAX(0, [game get_viewbox].y2))];
}

@end