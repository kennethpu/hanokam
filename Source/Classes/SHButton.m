//
//  SHButton.m
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SHButton.h"
#import "GameEngineScene.h"
#import "Resource.h"

@implementation SHButton {
	CCSprite *_but_left,*_but_middle,*_but_right;
}

+(SHButton*)cons_width:(float)width {
	return [[SHButton node] cons_width:width];
}

-(SHButton*)cons_width:(float)width {
	_but_left = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_SH_BUTTON_SIDE]] add_to:self z:0];
	[_but_left set_anchor_pt:ccp(0,0)];
	
	_but_middle = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_SH_BUTTON_MIDDLE]] add_to:self z:0];
	[_but_middle set_anchor_pt:ccp(0, 0)];
	[_but_middle setPosition:ccp(25, 0)];
	[_but_middle set_scale_x:(width - 50) / 25];
	
	_but_right = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_SH_BUTTON_SIDE]] add_to:self z:0];
	[_but_right set_anchor_pt:ccp(0,0)];
	[_but_right setPosition:ccp((width - 50) + 50, 0)];
	[_but_right set_scale_x:-1];
	return self;
}

@end
