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
#import "Player.h"
#import "ShaderManager.h"

@implementation BGSky {
	CCSprite *_sky_bg;
	CCSprite *_bldg_1, *_bldg_2, *_bldg_3;
	float _tick;
	NSMutableArray *_birds;
	
	CCSprite *_surface_gradient;
	
	CCNode *_above_water_root, *_below_water_root;
	CCRenderTexture *_above_water_belowreflection;
	
	NSMutableArray *_water_lights;
}
+(BGSky*)cons:(GameEngineScene *)g {
	return [[BGSky node] cons:g];
}

-(BGSky*)cons:(GameEngineScene *)g {
	_above_water_root = [[CCNode node] add_to:self];
	_below_water_root = [[CCNode node] add_to:self];

	_birds = [NSMutableArray array];
	_tick = 0;
	_sky_bg = (CCSprite*)[[CCSprite node] add_to:_above_water_root z:0];
	[_sky_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_SKY]];
	[_sky_bg set_anchor_pt:ccp(0,0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_sky_bg.texture setTexParameters:&par];
	
	[self setPosition:ccp(0,g.HORIZON_HEIGHT)];
	
	_bldg_3 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_BLDG3]] add_to:_above_water_root z:1];
	[_bldg_3 set_scale:0.1];
	[_bldg_3 set_pos:ccp(0,-g.HORIZON_HEIGHT)];
	[_bldg_3 set_anchor_pt:ccp(0,0)];
	
	_bldg_2 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_BLDG2]] add_to:_above_water_root z:1];
	[_bldg_2 set_scale:0.08];
	[_bldg_2 set_pos:ccp(game_screen().width,-g.HORIZON_HEIGHT)];
	[_bldg_2 set_anchor_pt:ccp(1,0)];
	
	_bldg_1 = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_BLDG1]] add_to:_above_water_root z:2];
	[_bldg_1 set_scale:0.09];
	[_bldg_1 set_pos:ccp(0,-g.HORIZON_HEIGHT)];
	[_bldg_1 set_anchor_pt:ccp(0,0)];
	
	[_bldg_1 setVisible:YES];
	[_bldg_2 setVisible:YES];
	[_bldg_3 setVisible:YES];
	
	_surface_gradient = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_UNDERWATER_SURFACE_GRADIENT]] add_to:_below_water_root z:99];
	[_surface_gradient setOpacity:0.65];
	[_surface_gradient setTextureRect:CGRectMake(0, 0, game_screen().width, _surface_gradient.texture.pixelHeight)];
	[_surface_gradient setAnchorPoint:ccp(0,0)];
	[_surface_gradient setPosition:ccp(0,-g.HORIZON_HEIGHT)];
	[_surface_gradient setScaleY:1];
	
	_above_water_belowreflection = [CCRenderTexture renderTextureWithWidth:game_screen().width height:600];
	[_above_water_belowreflection setPosition:ccp(game_screen().width / 2, 600/2 - g.HORIZON_HEIGHT)];
	[_below_water_root addChild:_above_water_belowreflection];
	_above_water_belowreflection.sprite.shader = [CCShader shaderNamed:SHADER_ABOVEWATER_AM_UP];
	_above_water_belowreflection.sprite.shaderUniforms[@"testTime"] = [g get_tick_mod_pi];
	_above_water_belowreflection.sprite.shaderUniforms[@"rippleTexture"] = [g get_ripple_texture];
	
	
	_water_lights = [NSMutableArray array];
	for(int i = 0; i < 10; i++) {
		CCSprite * _water_light;
		_water_light = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_WATER_SHINE]] add_to:g.get_bg_anchor z:0];
		[_water_lights addObject: _water_light];
		_water_light.position = ccp(float_random(-400, game_screen().width + 100), 0);
		[_water_light set_scale: .5 + (float)i / 10];
		[_water_light set_anchor_pt: ccp(0, 1)];
	}
	return self;
}

-(void)render_reflection:(GameEngineScene*)game {
	[BGReflection reflection_render:_bldg_3 offset:ccp(0,-5)];
	[BGReflection reflection_render:_bldg_2 offset:ccp(0,-3)];
	[BGReflection reflection_render:_bldg_1 offset:ccp(0,-3)];
}

-(void)set_bgobj_positions:(GameEngineScene*)game {
	HitRect _viewBox = [game get_viewbox];
	_bldg_1.position = ccp(_bldg_1.position.x,clampf(((_viewBox.y1 + _viewBox.y2) / 2) * .1 - game.HORIZON_HEIGHT, -game.HORIZON_HEIGHT,0));
	_bldg_2.position = ccp(_bldg_2.position.x,clampf(((_viewBox.y1 + _viewBox.y2) / 2) * .2 - game.HORIZON_HEIGHT, -game.HORIZON_HEIGHT,0));
	_bldg_3.position = ccp(_bldg_3.position.x,clampf(((_viewBox.y1 + _viewBox.y2) / 2) * .25 - game.HORIZON_HEIGHT, -game.HORIZON_HEIGHT,0));
}

-(void)i_update:(GameEngineScene*)g {
	_tick += dt_scale_get();
	
	[_above_water_belowreflection beginWithClear:0 g:0 b:0 a:0];
	[BGReflection above_water_below_render:_sky_bg];
	[BGReflection above_water_below_render:_bldg_3];
	[BGReflection above_water_below_render:_bldg_2];
	[BGReflection above_water_below_render:_bldg_1];
	[_above_water_belowreflection end];
	_above_water_belowreflection.sprite.shaderUniforms[@"testTime"] = [g get_tick_mod_pi];
	
	
	if (g.player.position.y < 0) {
		[_above_water_root setVisible:NO];
		[_below_water_root setVisible:YES];
	} else {
		[_above_water_root setVisible:YES];
		[_below_water_root setVisible:NO];
	}
	
	
	[_sky_bg setTextureRect:CGRectMake(
		0,
		MAX(0, [g get_viewbox].y1),
		game_screen().width,
		MAX(0, [g get_viewbox].y2 + game_screen().height)
	)];
	[self set_bgobj_positions:g];

	
	// birds!
	if(int_random(0, 40) == 0 && g.get_camera_y > 300) [self spawnBird_y:g.get_camera_y];
	NSMutableArray *birds_to_remove = [NSMutableArray array];
	for (Bird *bird in _birds) {
		[bird i_update:g];
		if (bird.position.x > game_screen().width + 100) {
			[birds_to_remove addObject:bird];
			[bird removeFromParent];
		}
	}
	[_birds removeObjectsInArray:birds_to_remove];
	[birds_to_remove removeAllObjects];
	
	for (CCSprite *itr in _water_lights) {
		if(itr.position.x > game_screen().width + 100)
			itr.position = ccp(- 400, 0);
		float new_x = itr.position.x + (sinf(_tick * itr.scale * .01) + sinf(_tick * itr.scale * .0002) + .05) * itr.scale * dt_scale_get() * .3;
		[itr setPosition:ccp(new_x, -(itr.scaleX - 1) * g.get_camera_y * .8)];
	}
	
}

-(Bird*)spawnBird_y:(float)y {
	Bird * _new_bird;
	_new_bird = (Bird*)[[Bird cons] add_to:self z:3];
	[_birds addObject:_new_bird];
	_new_bird.position = ccp(-70, y + float_random(300,-300));
	return _new_bird;
}

@end