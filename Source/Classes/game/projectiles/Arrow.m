//
//  Arrow.m
//  hobobob
//
//  Created by spotco on 22/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Arrow.h"
#import "GameEngineScene.h"
#import "Resource.h"

@implementation Arrow {
	CCSprite *_sprite;
}

+(Arrow*)cons{
	return [[Arrow node] cons];
}

-(Arrow*)cons{
	_sprite = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_ARROW]] add_to:self z:0];
	[_sprite set_anchor_pt:ccp(0.7, 0.5)];
	[_sprite set_scale:0.2];
	return self;
}

-(void)i_update:(GameEngineScene*)g {
	float _shoot_speed = 20;
	[self setPosition:CGPointAdd(self.position, ccp(sinf((self.rotation + 90) * (M_PI / 180)) * _shoot_speed, cosf((self.rotation + 90) * (M_PI / 180)) * _shoot_speed))];
}
@end
