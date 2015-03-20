//
//  BGReflection.h
//  hobobob
//
//  Created by spotco on 19/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameEngineScene.h"

@interface BGReflection : BGElement

+(void)reflection_render:(CCNode*)tar;
+(void)reflection_render:(CCNode*)tar offset:(CGPoint)offset;
@end
