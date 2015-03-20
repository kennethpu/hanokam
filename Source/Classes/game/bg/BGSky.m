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
#import "BGReflection.h"

@implementation BGSky {
	CCSprite *_sky_bg;
	
	CCSprite *_bldg_1, *_bldg_2;
	
	float _tick;
	
	NSMutableArray *_birds;
	
}
+(BGSky*)cons:(GameEngineScene *)g {
	return [[BGSky node] cons:g];
}

-(BGSky*)cons:(GameEngineScene *)g {
	_birds = [NSMutableArray array];
	_tick = 0;
	_sky_bg = (CCSprite*)[[CCSprite node] add_to:self z:0];
	[_sky_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_SKY]];
	[_sky_bg set_anchor_pt:ccp(0,0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_sky_bg.texture setTexParameters:&par];
	
	[self setPosition:ccp(0,g.HORIZON_HEIGHT)];
	
	_bldg_2 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_BLDG2]] add_to:self z:1];
	[_bldg_2 set_scale:0.5];
	[_bldg_2 set_pos:ccp(game_screen().width,-g.HORIZON_HEIGHT)];
	[_bldg_2 set_anchor_pt:ccp(1,0)];
	
	_bldg_1 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_BLDG1]] add_to:self z:2];
	[_bldg_1 set_scale:0.5];
	[_bldg_1 set_pos:ccp(0,-g.HORIZON_HEIGHT)];
	[_bldg_1 set_anchor_pt:ccp(0,0)];
	
	
	
	return self;
}

-(void)render_reflection:(GameEngineScene*)game {
	[BGReflection reflection_render:_bldg_2];
	[BGReflection reflection_render:_bldg_1];
}

-(void)set_bgobj_positions:(GameEngineScene*)game {
	HitRect _viewBox = [game get_viewbox];
	_bldg_1.position = ccp(_bldg_1.position.x,clampf(((_viewBox.y1 + _viewBox.y2) / 2) * .1 - game.HORIZON_HEIGHT,-game.HORIZON_HEIGHT,0));
	_bldg_2.position = ccp(_bldg_2.position.x,clampf(((_viewBox.y1 + _viewBox.y2) / 2) * .2 - game.HORIZON_HEIGHT,-game.HORIZON_HEIGHT,0));
}

-(void)i_update:(GameEngineScene*)game {
	_tick += dt_scale_get();
	
	
	[_sky_bg setTextureRect:CGRectMake(
		0,
		MAX(0, [game get_viewbox].y1),
		game_screen().width,
		MAX(0, [game get_viewbox].y2+game_screen().height)
	)];
	[self set_bgobj_positions:game];

	
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

-(Bird*)spawnBird {
	Bird * _new_bird;
	_new_bird = (Bird*)[[Bird cons] add_to:self z:3];
	[_birds addObject:_new_bird];
	_new_bird.position = ccp(-70, float_random(500,100));
	return _new_bird;
}

@end