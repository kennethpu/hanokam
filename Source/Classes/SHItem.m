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
	int _item_id;
	
}

+(SHItem*)cons_item_id:(int)item_id pos:(int)pos{
	return [[SHItem node] cons_item_id:item_id pos:pos];
}

-(SHItem*)cons_item_id:(int)item_id pos:(int)pos {
	_item_id = item_id;
	_pos = pos;
	_item = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_SH_ITEM]] add_to:self z:0];
	[_item setAnchorPoint:ccp(.5, .5)];
	[_item setScale:0.2];
	return self;
}

-(void)set_darkness:(int)darkness {
	switch (darkness) {
		case 0:
			[_item setColor:[CCColor whiteColor]];
		break;
		case 1:
			[_item setColor:[CCColor grayColor]];
		break;
		case 2:
			[_item setColor:[CCColor blackColor]];
		break;
	}
}

-(int) pos {
	return _pos;
}

@end