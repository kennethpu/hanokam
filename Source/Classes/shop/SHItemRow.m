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
	float _scroll_y;
	float _scroll_vel;
	float _scroll_y_prev;
	int _item_distance_between;
	int _row_num;
	
	BOOL _dragging;
	float _dragging_start_x;
}

+(SHItemRow*)cons_row_num:(int)row_num {
	return [[SHItemRow node] cons_row_num:row_num];
}
-(SHItemRow*)cons_row_num:(int)row_num {
	
	_row_num = row_num;
	
	_item_distance_between = 60;

	_items = [NSMutableArray array];
	for(int i = 0; i < 10; i++){
		[self create_item_pos:i];
	}
	
	_dragging = false;
	
	return self;
}

-(SHItem*)create_item_pos:(int)pos{
	SHItem * _new_item;
	_new_item = (SHItem*)[[SHItem cons_item_id:1 pos:pos] add_to:self];
	[_new_item set_scale:0.5];
	[_new_item set_anchor_pt:ccp(1,0)];
	
	[_items addObject:_new_item];
	
	return _new_item;
}

-(void)i_update:(ShopScene*)game {
	if(game.touch_tapped) {
		if(game.touch_position.y < self.position.y + 20 && game.touch_position.y > self.position.y - 20){
			_dragging = true;
			_dragging_start_x = (-game.touch_position.x - _scroll_y);
			game.row_focussing = _row_num;
		}
	}
	
	if(game.touch_released) {
		_dragging = false;
	}
	
	if(_dragging) {
		_scroll_y_prev = _scroll_y;
		if(_scroll_y < 0){
			// Left bound reached.
			_scroll_y = -(_dragging_start_x + game.touch_position.x) / 4;
		} else if (_scroll_y > (_items.count-1) * _item_distance_between){
			// Right bound reached.
			_scroll_y = ((_items.count-1) * _item_distance_between * 3 + -(_dragging_start_x + game.touch_position.x)) / 4;
		} else {
			_scroll_y = -(_dragging_start_x + game.touch_position.x);
		}
		_scroll_vel = _scroll_y - _scroll_y_prev;
		_scroll_vel = (_scroll_vel < -20) ? -20 : (_scroll_vel > 20) ? 20 : _scroll_vel;
	} else {
		_scroll_vel *= 0.95;
		if(_scroll_y < 0){
			// Left bound reached.
			_scroll_vel = 0;
			_scroll_y += (-_scroll_y) * .1 + 2;
		} else if (_scroll_y > (_items.count-1) * _item_distance_between){
			// Right bound reached.
			_scroll_vel = 0;
			_scroll_y += ((_items.count-1) * _item_distance_between -_scroll_y) * .1 - 2;
		} else {
			if(abs(_scroll_vel) > 1) {
			// Scroll has velocity.
				_scroll_y += _scroll_vel;
				_scroll_y += ((roundf(_scroll_y / _item_distance_between) * _item_distance_between) - _scroll_y) * .1;
			} else {
				_scroll_y += ((roundf(_scroll_y / _item_distance_between) * _item_distance_between) - _scroll_y) * .2;
			}
		}
	}
	
	[self setPosition:ccp(self.position.x, 300 + ((_row_num - 1) * 70))];
	
	for (SHItem *item in _items) {
		if(game.row_focussing == _row_num) {
			[item setPosition:ccp((([item pos] * _item_distance_between) - _scroll_y), 0)];
			[item set_darkness:0];
			if(roundf(_scroll_y / _item_distance_between) == item.pos) {
				[item setScale:item.scale + (1.2 - item.scale) * 0.5];
			} else {
				[item setScale:item.scale + (0.3 - item.scale) * 0.3];
			}
		} else {
			[item setPosition:ccp((([item pos] * _item_distance_between) - (_scroll_y)), 0)];
			[item set_darkness:1];
			if(roundf(_scroll_y / _item_distance_between) == item.pos) {
				[item setScale:item.scale + (0.5 - item.scale) * 0.5];
			} else {
				[item setScale:item.scale + (0.25 - item.scale) * 0.3];
			}
		}
	}
}
@end
