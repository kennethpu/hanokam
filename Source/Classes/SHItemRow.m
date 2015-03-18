//
//  SHItemRow.m
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SHItemRow.h"
#import "SHItem.h"
#import "Common.h"

@implementation SHItemRow {
	NSMutableArray *_items;
	float scrollX;
}

+(SHItemRow*)cons {
	return [[SHItemRow node] cons];
}
-(SHItemRow*)cons {
	_items = [NSMutableArray array];
	for(int i = 0; i < 10; i++){
		[self create_item_pos:i];
	}
	return self;
}

-(SHItem*)create_item_pos:(int)pos{
	SHItem * _new_item;
	_new_item = (SHItem*)[[SHItem cons_itemID:1 pos:pos] add_to:self];
	[_new_item set_scale:0.5];
	[_new_item set_anchor_pt:ccp(1,0)];
	
	[_items addObject:_new_item];
	
	return _new_item;
}

-(void)i_update:(ShopScene*)game {
	scrollX += .1;
	
	for (SHItem *item in _items) {
		[item setPosition:ccp(([item pos ] * 20) + scrollX, 0)];
	}
}
@end
