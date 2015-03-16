//
//  BGWater.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGWater.h"
#import "Common.h"
#import "Resource.h"
#import "CCTexture_Private.h"

@implementation BGWater {
	CCSprite *_water_bg;
}
+(BGWater*)cons {
	return [[BGWater node] cons];
}
-(BGWater*)cons {
	_water_bg = (CCSprite*)[[CCSprite node] add_to:self];
	[_water_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_WATER]];
	[_water_bg set_anchor_pt:ccp(0,0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_water_bg.texture setTexParameters:&par];
	
	return self;
}

-(void)i_update:(GameEngineScene*)game {
	[_water_bg setTextureRect:CGRectMake(0,MIN(0, [game get_viewbox].y2),game_screen().width,MIN(0, [game get_viewbox].y1))];
}

@end
