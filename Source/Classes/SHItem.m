//
//  SHItem.m
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SHItem.h"
#import "GameEngineScene.h"
#import "Resource.h"

@implementation SHItem {
	CCSprite *_item;
	int _pos;
}

+(SHItem*)cons_itemID:(int)itemID pos:(int)pos{
	return [[SHItem node] cons_itemID:itemID pos:pos];
}

-(SHItem*)cons_itemID:(int)itemID pos:(int)pos {
	_pos = pos;
	_item = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_SH_ITEM]] add_to:self z:0];
	//[_item setAnchorPoint:ccp(_item)]
	[_item setScale:0.2];
	return self;
}

-(int) pos {
	return _pos;
}

-(int) unlocked_after_level {
	return _pos;
}
@end
