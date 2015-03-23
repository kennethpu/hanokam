//
//  SpiritManager.m
//  hobobob
//
//  Created by spotco on 18/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpiritManager.h"
#import "GameEngineScene.h"
#import "SpiritBase.h"
#import "Spirit_Fish_1.h"
#import "Spirit_Fish_2.h"
#import "Spirit_Fish_3.h"

@implementation SpiritManager {
	int _dive_y;
	int _spawned;
	NSMutableArray *_spirits;
	GameEngineScene *_game;
}

-(float)dive_y				{ return _dive_y; }
-(void)set_dive_y:(float)y	{ _dive_y = y; }
-(NSMutableArray*)get_spirits { return _spirits; }

-(SpiritManager*)cons:(GameEngineScene*)game {
	_game = game;
	_spirits = [NSMutableArray array];
	
	Spirit_Fish_1 *_new_spirit;
	_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_1 cons_size:1] add_to:_game.spirit_anchor z:0];
	[_new_spirit setPosition:ccp(game_screen().width-50, -25)];
	[_spirits addObject:_new_spirit];
	
	_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_1 cons_size:1] add_to:_game.spirit_anchor z:0];
	[_new_spirit setPosition:ccp(50, 19)];
	[_spirits addObject:_new_spirit];
	
	return self;
}

-(void)i_update {
	[self update_spawn];
	
	NSMutableArray *spirits_to_remove = [NSMutableArray array];
	for (SpiritBase *itr in _spirits) {
		[itr i_update_game:_game];
		
		if (itr._remove_me == true) {
			[spirits_to_remove addObject:itr];
			[itr removeFromParent];
		}
	}
	
	[_spirits removeObjectsInArray:spirits_to_remove];
	[spirits_to_remove removeAllObjects];
	
}

-(void)update_spawn {
	if(_dive_y < -_spawned * 150){
		[self spawn_spirit];
		[self spawn_spirit];
		[self spawn_spirit];
		[self spawn_spirit];
	}
}

-(void)update_air_spawning {
	
}

-(void)spawn_spirit {
	CCNode *_new_spirit;
	if(float_random(0, 1) < .8){
		_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_1 cons_size:1] add_to:_game.spirit_anchor z:0];
	} else if(float_random(0, 1) < .6) {
		_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_2 cons_size:1] add_to:_game.spirit_anchor z:0];
	} else {
		_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_3 cons_size:1] add_to:_game.spirit_anchor z:0];
	}
	[_new_spirit setPosition:ccp(float_random(0, game_screen().width), _dive_y - 600 + float_random(0, 50))];
	[_spirits addObject:_new_spirit];
	_spawned ++;
}

-(void)toss_spirit {
	for (SpiritBase *itr in _spirits) {
		if (![itr _tossed]) {
			[itr toss:_game];
			return;
		}
	}
}

-(void)advance_follow_pos	{
	for (SpiritBase *itr in _spirits) {
		itr._follow_pos ++;
	}
}

@end
