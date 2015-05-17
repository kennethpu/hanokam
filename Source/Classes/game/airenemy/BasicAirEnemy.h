//
//  BasicAirEnemy.h
//  hobobob
//
//  Created by spotco on 08/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "AirEnemyManager.h"

@interface BasicAirEnemy : BaseAirEnemy
-(BasicAirEnemy*)cons_g:(GameEngineScene*)g relstart:(CGPoint)relstart relend:(CGPoint)relend;
-(void)update_alive:(GameEngineScene*)g;
-(void)update_death:(GameEngineScene*)g;
@property(readwrite,assign) CGPoint _rel_pos;
@end
