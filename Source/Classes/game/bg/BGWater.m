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

@implementation BGWater {
	CCSprite *_water_bg;
	CCSprite *_ground, *_ground_fill;
}
+(BGWater*)cons:(GameEngineScene *)g {
	return [[BGWater node] cons:g];
}
-(BGWater*)cons:(GameEngineScene *)g {
	//[self setPosition:ccp(0,g.HORIZON_HEIGHT)];

	_water_bg = (CCSprite*)[[CCSprite node] add_to:self z:0];
	[_water_bg setTexture:[Resource get_tex:TEX_TEST_BG_TILE_WATER]];
	[_water_bg set_anchor_pt:ccp(0,0)];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_water_bg.texture setTexParameters:&par];
	
	_ground = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SPRITESHEET_1] rect:[FileCache get_cgrect_from_plist:TEX_BG_SPRITESHEET_1 idname:@"bg_lake_ground_1.png"]];
	scale_to_fit_screen_x(_ground);
	[_ground setAnchorPoint:ccp(0,0.2)];
	[_ground setPosition:ccp(0,0)];
	[self addChild:_ground z:1];
	
	_ground_fill = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BLANK]];
	[_ground_fill setColor:[CCColor colorWithCcColor3b:ccc3(1, 22, 45)]];
	[_ground_fill setAnchorPoint:ccp(0,1)];
	[self addChild:_ground_fill];
	return self;
}

-(void)i_update:(GameEngineScene*)game {
	[_water_bg setTextureRect:CGRectMake(0,MIN(0, [game get_viewbox].y2 - game.HORIZON_HEIGHT),game_screen().width,MIN(0, [game get_viewbox].y1))];
	[_ground setPosition:ccp(0,game.get_ground_depth)];
	[_ground_fill setPosition:ccp(0,game.get_ground_depth-_ground.textureRect.size.height*_ground.anchorPoint.y)];
	[_ground_fill setTextureRect:CGRectMake(0, 0, game_screen().width,game_screen().height)];
}

@end
