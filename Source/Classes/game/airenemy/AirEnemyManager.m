//
//  AirEnemyManager.m
//  hobobob
//
//  Created by spotco on 27/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "AirEnemyManager.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "FileCache.h"
#import "PufferBasicAirEnemy.h"


@implementation BaseAirEnemy
-(void)i_update:(GameEngineScene*)game{
	[self setZOrder:self.position.y<0?GameAnchorZ_Enemies_Underwater:GameAnchorZ_Enemies_Air];
}
-(BOOL)should_remove{ return YES; }
-(void)do_remove:(GameEngineScene *)g{ }
-(HitRect)get_hit_rect{ return hitrect_cons_xy_widhei(self.position.x, self.position.y, 0, 0); }
-(void)get_sat_poly:(SATPoly *)in_poly { }
-(void)hit_projectile:(GameEngineScene*)g{}
-(void)hit_player_melee:(GameEngineScene*)g{}
-(BOOL)is_alive{ return YES; }
@end

@implementation AirEnemyManager {
	NSMutableArray *_enemies;
}
+(AirEnemyManager*)cons:(GameEngineScene*)g {
	return [[[AirEnemyManager alloc] init] cons:g];
}
-(AirEnemyManager*)cons:(GameEngineScene*)game {
	_enemies = [NSMutableArray array];
	return self;
}

-(void)test_spawn_enemies:(GameEngineScene*)game {
	if ([game get_player_state] == PlayerState_InAir) {
		if (_enemies.count == 0 || float_random(0, 50) < 1) {
			CGPoint start_pos = game_screen_pct(float_random(0.15, 0.85), 0);
			start_pos.y -= 50;
			
			CGPoint end_pos;
			if (float_random(0, 2) < 1) {
				end_pos = game_screen_pct(0, float_random(0.15, 0.85));
				end_pos.x -= 50;
			} else {
				end_pos = game_screen_pct(1, float_random(0.15, 0.85));
				end_pos.x += 50;
			}
			
			
			[self add_enemy:[PufferBasicAirEnemy cons_g:game relstart:start_pos relend:end_pos] game:game];
		}
	}
}

-(void)i_update:(GameEngineScene*)game {
	[self test_spawn_enemies:game];

	NSMutableArray *do_remove = [NSMutableArray array];
	for (int i = _enemies.count-1; i >= 0; i--) {
		BaseAirEnemy *itr = [_enemies objectAtIndex:i];
		[itr i_update:game];
		if ([itr should_remove]) {
			[itr do_remove:game];
			[[game get_anchor] removeChild:itr];
			[do_remove addObject:itr];
		}
	}
	[_enemies removeObjectsInArray:do_remove];
	[do_remove removeAllObjects];
}
-(void)add_enemy:(BaseAirEnemy*)enemy game:(GameEngineScene*)game {
	[[game get_anchor] addChild:enemy z:GameAnchorZ_Enemies_Air];
	[_enemies addObject:enemy];
}

-(NSArray*)get_enemies {
	return _enemies;
}
-(void)remove_all_enemies:(GameEngineScene*)g {
	for (BaseAirEnemy *itr in _enemies) {
		[itr do_remove:g];
		[[g get_anchor] removeChild:itr];
	}
	[_enemies removeAllObjects];
}
@end
