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
-(void)do_remove;
-(HitRect)get_hit_rect;
-(void)get_sat_poly:(SATPoly *)in_poly;
-(void)hit_projectile:(GameEngineScene*)g;
-(void)hit_player_melee:(GameEngineScene*)g;
-(void)notify_leave:(GameEngineScene*)g;
@end

@interface AirEnemyManager : NSObject
+(AirEnemyManager*)cons:(GameEngineScene*)g;
-(void)i_update:(GameEngineScene*)game;
-(void)add_enemy:(BaseAirEnemy*)enemy game:(GameEngineScene*)game;
-(NSArray*)get_enemies;
-(void)notify_enemies_leave:(GameEngineScene*)g;
@end
