//
//  SHItem.h
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"

@interface SHItem : CCSprite
	+(SHItem*)cons_itemID:(int)itemID pos:(int)pos;
	-(int) unlocked_after_level;
	-(int) pos;
@end
