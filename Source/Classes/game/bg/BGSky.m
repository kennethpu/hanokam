//
//  BGSky.m
//  hobobob
//
//  Created by spotco on 24/05/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGSky.h"
#import "Resource.h"
#import "CCTexture_Private.h"
#import "FileCache.h"
#import "Player.h"

@implementation BGSky {
	CCSprite *_bg_arcs, *_bg_islands;
	CCSprite *_bg_cliff_left, *_bg_cliff_right;
}

+(BGSky*)cons:(GameEngineScene *)g {
	return [[[BGSky alloc] init] cons:g];
}

-(BGSky*)cons:(GameEngineScene*)g {
	ccTexParams repeat_par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};

	_bg_arcs = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SKY_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_BG_SKY_SPRITESHEET idname:@"bg_sky_arcs.png"]];
	scale_to_fit_screen_x(_bg_arcs);
	[_bg_arcs setPosition:ccp(0,0)];
	[_bg_arcs setScaleY:_bg_arcs.scaleX];
	[_bg_arcs setAnchorPoint:ccp(0,0)];
	[_bg_arcs.texture setTexParameters:&repeat_par];
	[[g get_anchor] addChild:_bg_arcs z:GameAnchorZ_BGSky_Sky_Arcs];
	
	_bg_islands = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SKY_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_BG_SKY_SPRITESHEET idname:@"bg_sky_island.png"]];
	scale_to_fit_screen_x(_bg_islands);
	[_bg_islands setPosition:ccp(0,0)];
	[_bg_islands setScaleY:_bg_arcs.scaleX];
	[_bg_islands setAnchorPoint:ccp(0,0)];
	[_bg_islands.texture setTexParameters:&repeat_par];
	[[g get_anchor] addChild:_bg_islands z:GameAnchorZ_BGSky_Sky_Islands];
	
	_bg_cliff_left = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SKY_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_BG_SKY_SPRITESHEET idname:@"bg_sky_cliffs_left.png"]];
	scale_to_fit_screen_y(_bg_cliff_left);
	[_bg_cliff_left setScaleX:_bg_cliff_left.scaleY];
	[_bg_cliff_left setPosition:ccp(-200,0)];
	[_bg_cliff_left setAnchorPoint:ccp(0,0)];
	[_bg_cliff_left.texture setTexParameters:&repeat_par];
	[[g get_anchor] addChild:_bg_cliff_left z:GameAnchorZ_BGSky_Sky_SideCliffs];
	
	_bg_cliff_right = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SKY_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_BG_SKY_SPRITESHEET idname:@"bg_sky_cliffs_right.png"]];
	scale_to_fit_screen_y(_bg_cliff_right);
	[_bg_cliff_right setScaleX:_bg_cliff_left.scaleY];
	[_bg_cliff_right setPosition:ccp(game_screen().width+200,0)];
	[_bg_cliff_right setAnchorPoint:ccp(1,0)];
	[_bg_cliff_right.texture setTexParameters:&repeat_par];
	[[g get_anchor] addChild:_bg_cliff_right z:GameAnchorZ_BGSky_Sky_SideCliffs];
	
	
	return self;
}

-(void)update_scrolling_element:(CCSprite*)element g:(GameEngineScene*)g mult:(float)mult offset:(float)offset {
	[element setVisible:YES];
	[element setPosition:ccp(element.position.x,g.get_viewbox.y1)];
	
	float posy = -g.get_current_camera_center_y * mult;
	float m_ypos = ((int)(posy))%element.texture.pixelHeight + ((posy) - ((int)(posy)));
	
	[element setTextureRect:CGRectMake(
		element.textureRect.origin.x,
		m_ypos + offset,
		element.textureRect.size.width,
		element.textureRect.size.height
	)];
}

-(void)i_update:(GameEngineScene *)game {
	if (game.get_current_camera_center_y < 125) {
		[_bg_islands setVisible:NO];
		[_bg_arcs setVisible:NO];
	} else {
		[_bg_islands setVisible:YES];
		[_bg_arcs setVisible:YES];
		[self update_scrolling_element:_bg_islands g:game mult:0.6 offset:0];
		[self update_scrolling_element:_bg_arcs g:game mult:0.4 offset:0];
	}
	
	if ([game.player is_underwater:game]) {
		[_bg_cliff_left setVisible:NO];
		[_bg_cliff_right setVisible:NO];
	} else {
		[_bg_cliff_left setVisible:YES];
		[_bg_cliff_right setVisible:YES];
		[self update_scrolling_element:_bg_cliff_left g:game mult:4  offset:0];
		[self update_scrolling_element:_bg_cliff_right g:game mult:4  offset:0];
	}
	if (game.get_current_camera_center_y > 350) {
		[_bg_cliff_left setPosition:ccp(drp(_bg_cliff_left.position.x,0,10),_bg_cliff_left.position.y)];
		[_bg_cliff_right setPosition:ccp(drp(_bg_cliff_right.position.x,game_screen().width,10),_bg_cliff_left.position.y)];
	} else {
		[_bg_cliff_left setPosition:ccp(drp(_bg_cliff_left.position.x,-200,10),_bg_cliff_left.position.y)];
		[_bg_cliff_right setPosition:ccp(drp(_bg_cliff_right.position.x,game_screen().width+200,10),_bg_cliff_right.position.y)];
	}
}

@end
