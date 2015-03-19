//
//  SpiritManager.m
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpiritManager.h"

static int _follow_pos;
static int _dive_y;

@implementation SpiritManager


+(int)follow_pos {
	return _follow_pos;
}

+(float)dive_y {
	return _dive_y;
}

+(void)set_dive_y:(float)y {
	_dive_y = y;
}

+(void)advance_follow_pos {
	_follow_pos ++;
}

+(void)reset_follow_pos {
	_follow_pos = 0;
}

+(void)init {
	_follow_pos = 0;
}

@end
