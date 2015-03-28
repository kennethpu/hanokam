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
	int _left_to_toss;
	float _toss_countdown;
	NSMutableArray *_spirits;
	GameEngineScene *_game;
}

@synthesize _spawned;

-(float)dive_y				{ return _dive_y; }
-(void)set_dive_y:(float)y	{ _dive_y = y; }
-(NSMutableArray*)get_spirits { return _spirits; }

-(SpiritManager*)cons:(GameEngineScene*)game {
	_game = game;
	_spirits = [NSMutableArray array];
	
	return self;
}

-(void)i_update {
	[self update_spawn];
	
	if(_toss_countdown > 0)
		_toss_countdown -= dt_scale_get();
	
	if(_left_to_toss > 0 && _toss_countdown <= 0) {
		[self toss_now];
	}
	
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

-(int)count_alive {
	return _spirits.count;
}

-(void)update_spawn {
	if(_dive_y < (_spawned / 14) * -150 - 100){
		DO_FOR(14, [self spawn_spirit]);
	}
}

-(void)update_air_spawning {

}

-(void)kill_all {
	for (SpiritBase *itr in _spirits) {
		[itr removeFromParent];
	}
	[_spirits removeObjectsInArray:_spirits];
	[_spirits removeAllObjects];
	
	_left_to_toss = 0;
}

-(void)kill_all_with_spirit_state_waiting {
	
	NSMutableArray *spirits_to_remove = [NSMutableArray array];
	for (SpiritBase *itr in _spirits) {
		if (itr._state == spirit_state_waiting) {
			[spirits_to_remove addObject:itr];
			[itr removeFromParent];
		}
	}
	
	[_spirits removeObjectsInArray:spirits_to_remove];
	[spirits_to_remove removeAllObjects];
}

-(void)reset_dive {
	_spawned = 0;
	_dive_y = 0;
}

-(void)spawn_spirit {
	CCNode *_new_spirit;
	if(float_random(0, 1) < .8){
		_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_1 cons_size:1] add_to:[_game get_anchor] z:GameAnchorZ_Enemies_Air];
	} else if(float_random(0, 1) < .6) {
		_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_2 cons_size:1] add_to:[_game get_anchor] z:GameAnchorZ_Enemies_Air];
	} else {
		_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_3 cons_size:1] add_to:[_game get_anchor] z:GameAnchorZ_Enemies_Air];
	}
	[_new_spirit setPosition:ccp(float_random(0, game_screen().width), _dive_y - 600 + float_random(0, 50))];
	[_spirits addObject:_new_spirit];
	_spawned ++;
}

-(void)toss_spirit {
	_left_to_toss ++;
}

-(void)toss_now {
	_left_to_toss --;
	_toss_countdown = float_random(2, 20);

	for (SpiritBase *itr in _spirits) {
		if (itr._state != spirit_state_combat) {
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
