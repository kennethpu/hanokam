//
//  Arrow.h
//  hobobob
//
//  Created by spotco on 22/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "cocos2d.h"
#import "Particle.h"
#import "Vec3D.h"
#import "PolyLib.h"

@class GameEngineScene;

@interface PlayerProjectile : Particle <SATPolyHitOwner>
-(HitRect)get_hit_rect;
-(void)get_sat_poly:(SATPoly *)in_poly;
-(BOOL)get_active;
@end

@interface Arrow : PlayerProjectile
+(Arrow*)cons_pos:(CGPoint)pos dir:(Vec3D)dir;
@end
