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
	int _test;
}
+(BGSky*)cons {
	return [[BGSky node] cons];
}

-(id)cons {
	_sky_bg = (CCSprite*)[[CCSprite node] add_to:self];
	[_sky_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_SKY]];
	[_sky_bg set_anchor_pt:ccp(0,0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_sky_bg.texture setTexParameters:&par];
	[_sky_bg setTextureRect:CGRectMake(0,0,game_screen().width,game_screen().height)];
	
	return self;
}

@end