//
//  BGSky.h
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"
#import "GameEngineScene.h"

@interface BGSky : BGElement
+(BGSky*)cons:(GameEngineScene*)g;

-(void)render_reflection:(GameEngineScene*)game;

@end
