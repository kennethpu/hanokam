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
	_val = x;
}

-(void)i_update:(GameEngineScene*)game {
	//float playerX = game.player.position.x;
	//playerX += clampf(((160 + _val * 320) - playerX) * .1, - 7, 7) * dt_scale_get();
	game.player._accelerometer_x = _val;
	//game.player.position = ccp(playerX, game.player.position.y);
	
}

@end
