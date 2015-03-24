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

@property(readwrite, assign) int _spawned;

-(void)advance_follow_pos;

-(float)dive_y;
-(void)set_dive_y:(float)y;
-(void)toss_spirit;
-(void)reset_dive;

-(NSMutableArray*)get_spirits;

-(void)i_update;
@end
