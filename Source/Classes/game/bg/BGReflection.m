//
//  BGReflection.m
//  hobobob
//
//  Created by spotco on 19/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGReflection.h"

@implementation BGReflection

+(void)reflection_render:(CCNode *)tar {
	[self reflection_render:tar offset:CGPointZero];
}

+(void)reflection_render:(CCNode*)tar offset:(CGPoint)offset {
	float y = tar.position.y;
	tar.position = ccp(tar.position.x + offset.x,-y + offset.y);
	[tar visit];
	tar.position = ccp(tar.position.x,y);
}

@end
