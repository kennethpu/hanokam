//
//  PlayerUnderwaterCombatParams.m
//  hobobob
//
//  Created by spotco on 08/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PlayerUnderwaterCombatParams.h"

@implementation PlayerUnderwaterCombatParams
@synthesize _current_mode;
@synthesize _vy, _tar_camera_offset, _remainder_camera_offset;

@synthesize _initial_camera_offset;
-(float)DEFAULT_OFFSET {
	return -game_screen().height/2 * 0.5;
}
@end
