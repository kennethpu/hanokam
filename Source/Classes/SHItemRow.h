//
//  SHItemRow.h
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"
#import "ShopScene.h"

@interface SHItemRow : CCSprite
+(SHItemRow*)cons_row_num:(int)row_num;
-(void)i_update:(ShopScene*)game;
@end
