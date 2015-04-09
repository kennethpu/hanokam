//
//  PlayerUnderwaterCombatParams.h
//  hobobob
//
//  Created by spotco on 08/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Player.h"

typedef enum _PlayerUnderwaterCombatMode {
	PlayerUnderwaterCombatMode_TransitionIn,
	PlayerUnderwaterCombatMode_MainGame
} PlayerUnderwaterCombatMode;

@interface PlayerUnderwaterCombatParams : NSObject
@property(readwrite,assign) PlayerUnderwaterCombatMode _current_mode;
@property(readwrite,assign) float _vy, _tar_camera_offset, _remainder_camera_offset, _anim_ct;

@property(readwrite,assign) float _initial_camera_offset;
-(float)DEFAULT_OFFSET;
@end