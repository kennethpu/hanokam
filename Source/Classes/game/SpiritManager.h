//
//  SpiritManager.h
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameEngineScene.h"

@interface SpiritManager : NSObject

-(SpiritManager*)cons:(GameEngineScene*)g;

-(int)follow_pos;
-(void)advance_follow_pos;
-(void)reset_follow_pos;

-(float)dive_y;
-(void)set_dive_y:(float)y;

-(void)i_update;
@end
