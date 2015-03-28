//
//  BGReflection.m
//  hobobob
//
//  Created by spotco on 19/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGReflection.h"

@implementation BGReflection

+(void)above_water_below_render:(CCNode*)tar {
	float y = tar.position.y;
	tar.position = ccp(tar.position.x,0);
	[tar visit];
	tar.position = ccp(tar.position.x,y);
}

+(void)reflection_render:(CCNode*)tar g:(GameEngineScene *)g {
	[self reflection_render:tar offset:CGPointZero g:g];
}

+(void)reflection_render:(CCNode*)tar offset:(CGPoint)offset g:(GameEngineScene *)g {
	CGPoint pos_pre = tar.position;
	tar.position = CGPointAdd(ccp(tar.position.x,g.HORIZON_HEIGHT + tar.position.y),offset);
	[tar visit];
	tar.position = pos_pre;
}

+(void)bgobj_reflection_render:(CCNode*)tar offset:(CGPoint)offset g:(GameEngineScene *)g {
	float y = tar.position.y;
	tar.position = ccp(tar.position.x + offset.x,-y + offset.y + g.HORIZON_HEIGHT);
	[tar visit];
	tar.position = ccp(tar.position.x,y);
}

@end
