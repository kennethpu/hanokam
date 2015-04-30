//
//  PlayerAirCombatParams.h
//  hobobob
//
//  Created by spotco on 08/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Player.h"

typedef enum _PlayerAirCombatMode {
	PlayerAirCombatMode_InitialJumpOut,
	PlayerAirCombatMode_Combat,
	PlayerAirCombatMode_RescueBackToTop,
	PlayerAirCombatMode_FallToGround
} PlayerAirCombatMode;

@interface PlayerAirCombatParams : NSObject
@property(readwrite,assign) CGPoint _s_vel;
@property(readwrite,assign) float _w_camera_center, _w_upwards_vel, _anim_ct;
@property(readwrite,assign) PlayerAirCombatMode _current_mode;

@property(readwrite,assign) BOOL _sword_out;
@property(readwrite,assign) float _arrow_throwback_ct;

@property(readwrite,assign) int __rescue_last_waypoint_ct;

-(float)DEFAULT_HEIGHT;
@end
