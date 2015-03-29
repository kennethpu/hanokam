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
#import "FileCache.h"
#import "SpiritBase.h"

@implementation BGSky {
	CCSprite *_sky_bg;
	CCSprite *_docks,*_bldg_1, *_bldg_2, *_bldg_3;
	float _tick;
	NSMutableArray *_birds;
	
	CCSprite *_surface_gradient;
	
	NSMutableArray *_above_water_elements, *_below_water_elements;
	CCRenderTexture *_above_water_belowreflection;
	CCRenderTexture *_water_surface_ripples;
}
+(BGSky*)cons:(GameEngineScene *)g {
	return [[[BGSky alloc] init] cons:g];
}

-(BGSky*)cons:(GameEngineScene *)g {
	_above_water_elements = [NSMutableArray array];
	_below_water_elements = [NSMutableArray array];

	_birds = [NSMutableArray array];
	_tick = 0;
	_sky_bg = [CCSprite node];
	[[g get_anchor] addChild:_sky_bg z:GameAnchorZ_BGSky_RepeatBG];
	[_above_water_elements addObject:_sky_bg];
	[_sky_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_SKY]];
	[_sky_bg set_anchor_pt:ccp(0,0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_sky_bg.texture setTexParameters:&par];
	
	_bldg_3 = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"bg_3.png"]];
	[[g get_anchor] addChild:_bldg_3 z:GameAnchorZ_BGSky_BackgroundElements];
	[_above_water_elements addObject:_bldg_3];
	[_bldg_3 set_scale:0.5];
	[_bldg_3 set_pos:ccp(game_screen().width,0)];
	[_bldg_3 set_anchor_pt:ccp(1,0)];
	
	_bldg_2 = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"bg_2.png"]];
	[[g get_anchor] addChild:_bldg_2 z:GameAnchorZ_BGSky_Elements];
	[_above_water_elements addObject:_bldg_2];
	[_bldg_2 set_scale:0.5];
	[_bldg_2 set_pos:ccp(game_screen().width,0)];
	[_bldg_2 set_anchor_pt:ccp(1,0)];
	
	_bldg_1 = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"bg_1.png"]];
	[[g get_anchor] addChild:_bldg_1 z:GameAnchorZ_BGSky_Elements];
	[_above_water_elements addObject:_bldg_1];
	[_bldg_1 setScale:0.5];
	[_bldg_1 set_pos:ccp(0,0)];
	[_bldg_1 set_anchor_pt:ccp(0,0)];
	
	_docks = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"pier_top.png"]];
	[[g get_anchor] addChild:_docks z:GameAnchorZ_BGSky_Docks];
	[_above_water_elements addObject:_docks];
	[_docks setScale:0.5];
	[_docks set_pos:ccp(0,0)];
	[_docks set_anchor_pt:ccp(0,0)];
	
	CCSprite *docks_front = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"pier_top_front_pillars.png"]];
	[[g get_anchor] addChild:docks_front z:GameAnchorZ_BGSky_Docks_Pillars_Front];
	[_above_water_elements addObject:docks_front];
	[docks_front setScale:0.5];
	[docks_front set_pos:ccp(0,0)];
	[docks_front set_anchor_pt:ccp(0,0)];
	
	_surface_gradient = [CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_BG_UNDERWATER_SURFACE_GRADIENT]];
	[[g get_anchor] addChild:_surface_gradient z:GameAnchorZ_BGSky_SurfaceGradient];
	[_below_water_elements addObject:_surface_gradient];
	[_surface_gradient setOpacity:1];
	[_surface_gradient setTextureRect:CGRectMake(0, 0, game_screen().width, _surface_gradient.texture.pixelHeight)];
	[_surface_gradient setAnchorPoint:ccp(0,0)];
	[_surface_gradient setPosition:ccp(0,0)];
	[_surface_gradient setScaleY:1];
	
	int reflection_height = 600;
	_water_surface_ripples = [CCRenderTexture renderTextureWithWidth:game_screen().width height:reflection_height];
	[_above_water_belowreflection setPosition:ccp(game_screen().width / 2, reflection_height/2)];
	[_water_surface_ripples clear:0 g:0 b:0 a:0];
	
	_above_water_belowreflection = [CCRenderTexture renderTextureWithWidth:game_screen().width height:reflection_height];
	[_above_water_belowreflection setPosition:ccp(game_screen().width / 2, reflection_height/2)];
	[_below_water_elements addObject:_above_water_belowreflection];
	[[g get_anchor] addChild:_above_water_belowreflection z:GameAnchorZ_BGSky_SurfaceReflection];
	_above_water_belowreflection.sprite.shader = [CCShader shaderNamed:SHADER_ABOVEWATER_AM_UP];
	_above_water_belowreflection.sprite.shaderUniforms[@"testTime"] = [g get_tick_mod_pi];
	_above_water_belowreflection.sprite.shaderUniforms[@"rippleTexture"] = _water_surface_ripples.sprite.texture;
	
	_above_water_belowreflection.sprite.blendMode = [CCBlendMode alphaMode];
	
	return self;
}

-(void)render_reflection:(GameEngineScene*)game {
	[BGReflection bgobj_reflection_render:_bldg_3 offset:ccp(0,5) g:game];
	[BGReflection bgobj_reflection_render:_bldg_2 offset:ccp(0,0) g:game];
	[BGReflection bgobj_reflection_render:_bldg_1 offset:ccp(0,0) g:game];
	[BGReflection reflection_render:_docks offset:ccp(0,game.HORIZON_HEIGHT/2) g:game];
}

-(void)set_bgobj_positions:(GameEngineScene*)game {
	float camera_y = [game get_camera_y];
	_bldg_1.position = ccp(_bldg_1.position.x,clampf(camera_y*.1, 0, game.HORIZON_HEIGHT));
	_bldg_2.position = ccp(_bldg_2.position.x,clampf(camera_y*.2, 0, game.HORIZON_HEIGHT));
	_bldg_3.position = ccp(_bldg_3.position.x,camera_y*.25);
}

-(void)above_water_root_set_visible:(BOOL)tar {
	for(CCNode *itr in _above_water_elements) [itr setVisible:tar];
 }
-(void)below_water_root_set_visible:(BOOL)tar { for(CCNode *itr in _below_water_elements) [itr setVisible:tar]; }

-(void)i_update:(GameEngineScene*)g {
	_tick += dt_scale_get();
	
	if ([g.player is_underwater:g] && g.get_camera_y > -game_screen().height) {
		[_water_surface_ripples clear:0 g:0 b:0 a:0];
		[_water_surface_ripples begin];
		CCSprite *proto = g.get_ripple_proto;
		for (RippleInfo *itr in g.get_ripple_infos) {
			[itr render_default:proto offset:ccp(0,65) scymult:0.35];
		}
		[_water_surface_ripples end];
		
		[self above_water_root_set_visible:YES];
		[_above_water_belowreflection beginWithClear:0 g:0 b:0 a:0];
		[BGReflection above_water_below_render:_sky_bg];
		[BGReflection above_water_below_render:_bldg_3];
		[BGReflection above_water_below_render:_bldg_2];
		[BGReflection above_water_below_render:_bldg_1];
		[BGReflection above_water_below_render:_docks];
		
		{
			CGPoint player_pre = g.player.position;
			float player_scale_pre = g.player.scaleY;
			g.player.position = ccp(player_pre.x,-player_pre.y);
			g.player.scaleY = -player_scale_pre;
			[g.player visit];
			g.player.position = player_pre;
			g.player.scaleY = player_scale_pre;
		}
		
		[_above_water_belowreflection end];
		_above_water_belowreflection.sprite.shaderUniforms[@"testTime"] = [g get_tick_mod_pi];
		
		float view_top = g.get_viewbox.y2;
		if (view_top > 0) {
			_surface_gradient.scaleY = view_top/_surface_gradient.texture.pixelHeight;
		}
		
		[self above_water_root_set_visible:NO];
		[self below_water_root_set_visible:YES];
		
	} else {
		[self above_water_root_set_visible:YES];
		[self below_water_root_set_visible:NO];
	}
	
	
	[_sky_bg setTextureRect:CGRectMake(
		0,
		MAX(0, [g get_viewbox].y1),
		game_screen().width,
		MAX(0, [g get_viewbox].y2 + game_screen().height)
	)];
	[self set_bgobj_positions:g];

	
	// birds!
	if(int_random(0, 40) == 0 && g.get_camera_y > 300) [self spawnBird_y:g.get_camera_y g:g];
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
}

-(Bird*)spawnBird_y:(float)y g:(GameEngineScene*)g {
	Bird * _new_bird;
	_new_bird = (Bird*)[[Bird cons] add_to:[g get_anchor] z:3];
	[_birds addObject:_new_bird];
	_new_bird.position = ccp(-70, y + float_random(300,-300));
	return _new_bird;
}

@end