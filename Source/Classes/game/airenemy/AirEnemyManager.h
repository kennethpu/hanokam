//
//  AirEnemyManager.h
//  hobobob
//
//  Created by spotco on 27/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "PolyLib.h"
@class GameEngineScene;

@interface BaseAirEnemy : CCSprite <SATPolyHitOwner>
-(void)i_update:(GameEngineScene*)game;
-(BOOL)should_remove;
-(void)do_remove:(GameEngineScene*)g;
-(HitRect)get_hit_rect;
-(void)get_sat_poly:(SATPoly *)in_poly;
-(void)hit_projectile:(GameEngineScene*)g;
-(void)hit_player_melee:(GameEngineScene*)g;
-(BOOL)is_alive;
@end

@interface AirEnemyManager : NSObject
+(AirEnemyManager*)cons:(GameEngineScene*)g;
-(void)i_update:(GameEngineScene*)game;
-(void)add_enemy:(BaseAirEnemy*)enemy game:(GameEngineScene*)game;
-(NSArray*)get_enemies;
-(void)remove_all_enemies:(GameEngineScene*)g;
@end
