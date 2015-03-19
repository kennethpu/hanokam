//
//  EnemyBasic.m
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpiritBasic.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "Common.h"
#import "SpiritManager.h"

#import "Player.h"

@implementation SpiritBasic {
	CCSprite *_obj_sprite;
}

+(SpiritBasic*) cons_pos_x:(float)pos_x {
	return [[SpiritBasic node] cons_pos_x:pos_x];
}

-(SpiritBasic*) cons_pos_x:(float)pos_x {
	_obj_sprite = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_SPIRIT_FISH_1]] add_to:self z:0];
	[_obj_sprite set_anchor_pt:ccp(.5, .5)];
	[_obj_sprite set_scale:0.3];
	
	[super cons_pos_x:pos_x];
	
	return self;
}

-(void)water_behavior:(GameEngineScene *)g {
	[super water_behavior:g];
}

@end