//
//  BGWater.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BGWater.h"

@implementation BGWater
+(BGWater*)cons {
	return [[BGWater node] cons];
}
-(id)cons {
	
	return self;
}
@end
