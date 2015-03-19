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
	float _scrollX;
	float _scrollVel;
	float _scrollPrev;
	int _itemDistance;
	int _rowNum;
	
	BOOL _dragging;
	float _startDrag;
}

+(SHItemRow*)cons_rowNum:(int)rowNum {
	return [[SHItemRow node] cons_rowNum:rowNum];
}
-(SHItemRow*)cons_rowNum:(int)rowNum {
	_rowNum = rowNum;
	
	_itemDistance = 60;

	_items = [NSMutableArray array];
	for(int i = 0; i < 10; i++){
		[self create_item_pos:i];
	}
	
	_dragging = false;
	
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

	if(game.touchTap) {
		if(game.touchPosition.y < self.position.y + 20 && game.touchPosition.y > self.position.y - 20){
			_dragging = true;
			_startDrag = (-game.touchPosition.x - _scrollX);
			game.rowFocus = _rowNum;
		}
	}
	
	if(game.touchRelease) {
		_dragging = false;
	}
	
	if(_dragging) {
		_scrollPrev = _scrollX;
		if(_scrollX < 0){
			_scrollX = -(_startDrag + game.touchPosition.x) / 4;
		} else if (_scrollX > (_items.count-1) * _itemDistance){
			_scrollX = ((_items.count-1) * _itemDistance * 3 + -(_startDrag + game.touchPosition.x)) / 4;
		} else {
			_scrollX = -(_startDrag + game.touchPosition.x);
		}
		_scrollVel = _scrollX - _scrollPrev;
		_scrollVel = (_scrollVel < -20) ? -20 : (_scrollVel > 20) ? 20 : _scrollVel;
	} else {
		_scrollVel *= 0.95;
		if(_scrollX < 0){
			_scrollVel = 0;
			_scrollX += (-_scrollX) * .1 + 2;
		} else if (_scrollX > (_items.count-1) * _itemDistance){
			_scrollVel = 0;
			_scrollX += ((_items.count-1) * _itemDistance -_scrollX) * .1 - 2;
		} else {
			if(abs(_scrollVel) > 1) {
				_scrollX += _scrollVel;
			}
			
			_scrollX += ((roundf(_scrollX / _itemDistance) * _itemDistance) - _scrollX) * .2;
			
		}
	}
	
	[self setPosition:ccp(self.position.x, 300 + ((_rowNum - 1) * 70))];
	
	for (SHItem *item in _items) {
	
	
		
		if(game.rowFocus == _rowNum) {
			[item setPosition:ccp((([item pos] * _itemDistance) - _scrollX), 0)];
			
			if(roundf(_scrollX / _itemDistance) == item.pos) {
				[item setScale:item.scale + (1.2 - item.scale) * 0.6];
			} else {
				[item setScale:item.scale + (0.3 - item.scale) * 0.4];
			}
		} else {
			[item setPosition:ccp((([item pos] * _itemDistance) - (_scrollX)), 0)];
		
			if(roundf(_scrollX / _itemDistance) == item.pos) {
				[item setScale:item.scale + (0.5 - item.scale) * 0.6];
			} else {
				[item setScale:item.scale + (0.25 - item.scale) * 0.4];
			}
		}
	}
}
@end
