//
//  SpriterNode.h
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
@class SpriterData;
@interface SpriterNode : CCNode
+(SpriterNode*)nodeFromData:(SpriterData*)data;
-(void)playAnim:(NSString*)anim repeat:(BOOL)repeat;
-(BOOL)current_anim_repeating;
-(BOOL)current_anim_finished;
@end
