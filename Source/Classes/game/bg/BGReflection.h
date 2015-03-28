//
//  BGReflection.h
//  hobobob
//
//  Created by spotco on 19/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameEngineScene.h"

@interface BGReflection : NSObject
+(void)reflection_render:(CCNode*)tar g:(GameEngineScene*)g;
+(void)reflection_render:(CCNode*)tar offset:(CGPoint)offset g:(GameEngineScene*)g;
+(void)above_water_below_render:(CCNode*)tar;
+(void)bgobj_reflection_render:(CCNode*)tar offset:(CGPoint)offset g:(GameEngineScene*)g;
@end
