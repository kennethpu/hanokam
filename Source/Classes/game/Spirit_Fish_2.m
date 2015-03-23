//
//  Fish
//  hanoka
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Spirit_Fish_2.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "Common.h"
#import "SpiritManager.h"

#import "Player.h"

@implementation Spirit_Fish_2 {
	CCSprite *_obj_sprite;
}

+(SpiritBase*) cons_size:(float)size {
	return [[Spirit_Fish_2 node] cons_size:size];
}

-(Spirit_Fish_2*) cons_size:(float)size {
	_obj_sprite = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_SPIRIT_FISH_2]] add_to:self z:1];
	[_obj_sprite set_anchor_pt:ccp(.5, .5)];
	[_obj_sprite set_scale: 0.2 * size];
	[super cons_size: size];
	
	return self;
}

-(void)water_behavior:(GameEngineScene *)g {
	[super water_behavior: g];
}

-(void)air_behavior:(GameEngineScene *)g {
}

@end