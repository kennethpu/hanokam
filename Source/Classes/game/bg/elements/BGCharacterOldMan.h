//
//  BGCharacterOldMan.h
//  hobobob
//
//  Created by spotco on 12/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@class GameEngineScene;
@interface BGCharacterOldMan : CCSprite

+(BGCharacterOldMan*)cons_pos:(CGPoint)pos;
-(void)i_update:(GameEngineScene*)g;

@end
