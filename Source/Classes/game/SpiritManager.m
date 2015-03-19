//
//  SpiritManager.m
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpiritManager.h"

static int _followPos;

@implementation SpiritManager


+(int)followPos {
	return _followPos;
}

+(void)advanceFollowPos {
	_followPos ++;
}

+(void)resetFollowPos {
	_followPos = 0;
}

+(void)init {
	_followPos = 0;
}
@end
