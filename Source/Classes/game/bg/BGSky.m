//
//  BGSky.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGSky.h"
#import "Bird.h"
#import "Common.h"
#import "Resource.h"
#import "CCTexture_Private.h"

@implementation BGSky {
	CCSprite *_sky_bg;
	
	CCSprite *_bldg_1, *_bldg_2;
	
	float _tick;
	
	NSMutableArray *_birds;
	
}
+(BGSky*)cons {
	return [[BGSky node] cons];
}

-(Bird*)spawnBird {
	Bird * _new_bird;
	_new_bird = (Bird*)[[Bird cons] add_to:self z:3];
	[_birds addObject:_new_bird];
	_new_bird.position = ccp(-70, float_random(500,100));
	return _new_bird;
}

-(BGSky*)cons {
	_birds = [NSMutableArray array];
	_tick = 0;
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
	
	//game_screen().width, 0
	
	return self;
}

-(void)i_update:(GameEngineScene*)game {
	_tick += dt_scale_get();
	
	//NSLog(@"tick %f", _tick);

	[_sky_bg setTextureRect:CGRectMake(0,MAX(0, [game get_viewbox].y1),game_screen().width,MAX(0, [game get_viewbox].y2+game_screen().height))];
	HitRect _viewBox = [game get_viewbox];
	_bldg_1.position = ccp(_bldg_1.position.x,((_viewBox.y1 + _viewBox.y2) / 2) * .1);
	_bldg_2.position = ccp(_bldg_2.position.x,((_viewBox.y1 + _viewBox.y2) / 2) * .2);
	
	// birds!
	if(int_random(0, 50) == 0) [self spawnBird];
	
	NSMutableArray *birds_to_remove = [NSMutableArray array];
	for (Bird *bird in _birds) {
		[bird i_update:game];
		if (bird.position.x > game_screen().width + 100) {
			[birds_to_remove addObject:bird];
			[bird removeFromParent];
		}
	}
	[_birds removeObjectsInArray:birds_to_remove];
	[birds_to_remove removeAllObjects];
}

@end