//
//  PlayerLandParams.m
//  hobobob
//
//  Created by spotco on 08/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PlayerLandParams.h"

@implementation PlayerLandParams
@synthesize _vel;
@synthesize _move_hold_ct, _prep_dive_hold_ct;
@synthesize _current_mode;
-(float)MOVE_CUTOFF_VAL { return 0.3; }
-(float)MOVE_HOLD_TIME { return 2.0; }
-(float)PREP_DIVE_HOLD_TIME { return 30.0; }
@end
