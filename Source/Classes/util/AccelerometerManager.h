//
//  AccelerometerManager.h
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameEngineScene;
@interface AccelerometerManager : NSObject
+(AccelerometerManager*)cons;
-(void)accel_report_x:(float)x y:(float)y z:(float)z;
-(void)i_update:(GameEngineScene*)game;
@end
