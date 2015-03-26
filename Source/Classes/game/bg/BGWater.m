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
#import "FileCache.h"
#import "GameEngineScene.h"
#import "Player.h"
#import "ShaderManager.h"
#import "BGSky.h"
#import "SpiritBase.h"

@implementation BGWater {
	CCSprite *_water_bg;
	CCSprite *_ground, *_ground_fill;
	CCSprite *_top_cliff;
	
	CCRenderTexture *_reflection_texture, *_ripple_texture;
}
+(BGWater*)cons:(GameEngineScene *)g {
	return [[BGWater node] cons:g];
}
-(BGWater*)cons:(GameEngineScene *)g {
	_water_bg = (CCSprite*)[[CCSprite node] add_to:self z:0];
	[_water_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_WATER]];
	[_water_bg set_anchor_pt:ccp(0, 0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_water_bg.texture setTexParameters:&par];
	[_water_bg setPosition:ccp(0,0)];
	[_water_bg setTextureRect:CGRectMake(0, 0, game_screen().width, game_screen().height)];
	
	_ground = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"bg_lake_ground_1.png"]];
	scale_to_fit_screen_x(_ground);
	[_ground setAnchorPoint:ccp(0,0.2)];
	[_ground setPosition:ccp(0,0)];
	[self addChild:_ground z:1];
	
	_ground_fill = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BLANK]];
	[_ground_fill setColor:[CCColor colorWithCcColor3b:ccc3(1, 22, 45)]];
	[_ground_fill setAnchorPoint:ccp(0,1)];
	[self addChild:_ground_fill];
	
	[self initialize_reflection_and_ripples:g];
	
	_top_cliff = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"pier_bottom_cliff.png"]];
	scale_to_fit_screen_x(_top_cliff);
	[_top_cliff setPosition:ccp(0,2)];
	[_top_cliff setScaleY:_top_cliff.scaleX];
	[_top_cliff setAnchorPoint:ccp(0,1)];
	[self addChild:_top_cliff];
	
	return self;
}

-(void)initialize_reflection_and_ripples:(GameEngineScene*)game {
	_reflection_texture = [CCRenderTexture renderTextureWithWidth:game_screen().width height:game.REFLECTION_HEIGHT];
	[_reflection_texture setPosition:ccp(game_screen().width / 2, -(game.REFLECTION_HEIGHT) / 2 + game.HORIZON_HEIGHT)];
	_reflection_texture.scaleY = -1;
	[game.get_bg_anchor addChild:_reflection_texture z:2];
	_reflection_texture.sprite.blendMode = [CCBlendMode alphaMode];
	_reflection_texture.sprite.shader = [ShaderManager get_shader:SHADER_REFLECTION_AM_DOWN];
	_ripple_texture = [CCRenderTexture renderTextureWithWidth:game_screen().width height:game.REFLECTION_HEIGHT];
	[_ripple_texture clear:0 g:0 b:0 a:0];
	_reflection_texture.sprite.shaderUniforms[@"rippleTexture"] = _ripple_texture.sprite.texture;
}

-(void)render_ripple_texture:(GameEngineScene*)game {
	[_ripple_texture clear:0 g:0 b:0 a:0];
	[_ripple_texture begin];
	for (RippleInfo *itr in game.get_ripple_infos) {
		[itr render_reflected:game.get_ripple_proto scymult:0.5];
	}
	[_ripple_texture end];
	
}

-(void)render_reflection_texture:(GameEngineScene*)game {
	[_reflection_texture clear:0 g:0 b:0 a:0];
	[_reflection_texture begin];
	[game.get_bg_sky render_reflection:game];
	
	if (game.player.position.y > -10) {
		CGPoint player_pos = game.player.position;
		game.player.position = ccp(game.player.position.x, game.HORIZON_HEIGHT + game.player.position.y);
		[game.player visit];
		game.player.position = player_pos;
	}
	
	game.spirit_anchor.position = ccp(0,game.HORIZON_HEIGHT);
	for (SpiritBase *itr in game.get_spirit_manager.get_spirits) if (itr.position.y < 0) itr.visible = NO;
	[game.spirit_anchor visit];
	for (SpiritBase *itr in game.get_spirit_manager.get_spirits) itr.visible = YES;
	game.spirit_anchor.position = CGPointZero;
	
	[_reflection_texture end];
}

-(void)i_update:(GameEngineScene*)g {
	[_water_bg setPosition:ccp(0, g.get_camera_y - game_screen().height / 2)];
	
	[_ground setPosition:ccp(0, g.get_ground_depth)];
	[_ground_fill setPosition:ccp(0, g.get_ground_depth - _ground.textureRect.size.height * _ground.anchorPoint.y)];
	[_ground_fill setTextureRect:CGRectMake(0, 0, game_screen().width, game_screen().height)];
	
	if (g.player.position.y > 0) {
		if ([g get_viewbox].y1 < g.HORIZON_HEIGHT && [g get_viewbox].y2 > -g.REFLECTION_HEIGHT) {
			[self render_ripple_texture:g];
			[self render_reflection_texture:g];
			_reflection_texture.sprite.shaderUniforms[@"testTime"] = [g get_tick_mod_pi];
		}
		[_reflection_texture setVisible:YES];
	} else {
		[_reflection_texture setVisible:NO];
	}
}

@end
