//
//  SHItem.h
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"

@interface SHItem : CCSprite
	+(SHItem*)cons_item_id:(int)item_id pos:(int)pos;
	-(int) pos;
	-(void)set_darkness:(int)darkness;
@end
