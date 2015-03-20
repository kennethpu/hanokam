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

static int _follow_pos;
static int _dive_y;
static int _spawned;
static NSMutableArray *_spirits;
static GameEngineScene *_game;

@implementation SpiritManager

+(int)follow_pos			{ return _follow_pos; }
+(void)advance_follow_pos	{
	for (SpiritBase *itr in _spirits) {
		itr._follow_pos ++;
	}
	//_follow_pos ++;
}
+(void)reset_follow_pos		{ _follow_pos = 0; }
+(float)dive_y				{ return _dive_y; }
+(void)set_dive_y:(float)y	{ _dive_y = y; }

+(void)cons:(GameEngineScene*)game {
	_game = game;
	_follow_pos = 0;
	_spirits = [NSMutableArray array];
}

+(void)i_update {
	[self update_spawn];
	for (SpiritBase *itr in _spirits) {
		[itr i_update_game:_game];
	}
}

+(void)update_spawn {
	if(_dive_y < -_spawned * 100)
		[self spawn_spirit];
}

+(void)spawn_spirit {
	Spirit_Fish_1 *_new_spirit;
	_new_spirit = (Spirit_Fish_1*)[[Spirit_Fish_1 cons_size:1] add_to:_game.spirit_anchor z:0];
	[_new_spirit setPosition:ccp(float_random(0, game_screen().width), _dive_y - 600)];
	[_spirits addObject:_new_spirit];
	_spawned ++;
}

@end
