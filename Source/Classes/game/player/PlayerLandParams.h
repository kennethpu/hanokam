//
//  PlayerLandParams.h
//  hobobob
//
//  Created by spotco on 08/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Player.h"

typedef enum _PlayerLandMode {
	PlayerLandMode_AirToGround_FadeIn,
	PlayerLandMode_AirToGround_FallToWater,
	PlayerLandMode_AirToGround_WaterDiveUp,
	PlayerLandMode_AirToGround_FlipToDock,

	PlayerLandMode_OnDock,
	PlayerLandMode_LandToWater
} PlayerLandMode;

@interface PlayerLandParams : NSObject
@property(readwrite,assign) CGPoint _vel;
@property(readwrite,assign) float _move_hold_ct, _prep_dive_hold_ct, _health_restore_ct;
@property(readwrite,assign) PlayerLandMode _current_mode;

-(float)MOVE_CUTOFF_VAL;
-(float)MOVE_HOLD_TIME;
-(float)PREP_DIVE_HOLD_TIME;
@end
