//
//  EnemyBase.m
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpiritBase.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "SpiritManager.h"

@implementation SpiritBase {
}

-(void)i_update_game:(GameEngineScene*)g manager:(SpiritManager*)manager {}
/*
+(SHItem*)cons:(int)itemID pos:(int)pos{
	return [[SHItem node] cons_itemID:itemID pos:pos];
}

-(SHItem*)cons_itemID:(int)itemID pos:(int)pos {
	_itemID = itemID;
	_pos = pos;
	_item = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_SH_ITEM]] add_to:self z:0];
	//[_item setAnchorPoint:ccp(_item)]
	[_item setScale:0.2];
	
	return self;
}
*/
@end
