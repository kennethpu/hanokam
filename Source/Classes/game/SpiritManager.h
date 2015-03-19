//
//  SpiritManager.h
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpiritManager : CCNode

+(int)followPos;
+(void)advanceFollowPos;
+(void)resetFollowPos;
+(void)init;
@end
