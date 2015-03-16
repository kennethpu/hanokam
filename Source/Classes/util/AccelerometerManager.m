//
//  AccelerometerManager.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "AccelerometerManager.h"
#import "GameEngineScene.h"
#import "Player.h"

@implementation AccelerometerManager {
	float _x;
	float _last_x;
	float _avg_x;
	
	float _val;
}

+(AccelerometerManager*)cons {
	return [[AccelerometerManager alloc] init];
}

-(void)accel_report_x:(float)x y:(float)y z:(float)z {
	
	float filter = 0.7;
	float ratio = 75;
	
    if(ABS(x) < 0.032) {
		UIAccelerationValue rollingX = 0;
		rollingX = (x * filter) + (rollingX * (1.0 - filter));
		float accelX = x - rollingX;
		float pointsPerSec = ratio * accelX;
		_val = pointsPerSec;
    } else {
        _val = 0;
    }
}

-(void)i_update:(GameEngineScene*)game {
	if (_val == 0) {
		game.player._vx *= 0.9;
	} else {
		game.player._vx = _val;
	}
}

@end
