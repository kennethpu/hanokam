//
//  BasicAirEnemy.m
//  hobobob
//
//  Created by spotco on 08/04/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicAirEnemy.h"
#import "Resource.h" 
#import "FileCache.h"
#import "GameEngineScene.h"
#import "Common.h"
#import "Vec3D.h"

@implementation BasicAirEnemy {
	CGPoint _rel_start,_rel_end;
	float _anim_t;
	BOOL _notify_leave;
}
@synthesize _rel_pos;
+(BasicAirEnemy*)cons_g:(GameEngineScene*)g relstart:(CGPoint)relstart relend:(CGPoint)relend {
	return [[BasicAirEnemy node] cons_g:g relstart:relstart relend:relend];
}
-(BasicAirEnemy*)cons_g:(GameEngineScene*)g relstart:(CGPoint)relstart relend:(CGPoint)relend  {
	_rel_start = relstart;
	_rel_end = relend;
	_rel_pos = _rel_start;
	[self update_rel_pos:g];
	_anim_t = 0;
	_notify_leave = NO;
	[self setTexture:[Resource get_tex:TEX_ENEMIES_SPRITESHEET]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMIES_SPRITESHEET idname:@"spirit_fish_1.png"]];
	[self setScale:0.25];
	return self;
}

-(void)update_rel_pos:(GameEngineScene*)g {
	CGPoint lcorner = ccp(g.get_viewbox.x1,g.get_viewbox.y1);
	self.position = CGPointAdd(_rel_pos, lcorner);
}

-(void)i_update:(GameEngineScene *)game {
	if (_notify_leave) {
		_anim_t += 0.05 * dt_scale_get();
	} else {
		_anim_t += 0.004 * dt_scale_get();
	}
	
	CGPoint bez_ctrl1 = ccp(_rel_start.x,_rel_end.y + 100);
	CGPoint bez_ctrl2 = CGPointMid(bez_ctrl1, _rel_end);
	CGPoint next_rel_pos = bezier_point_for_t(_rel_start, bez_ctrl1, bez_ctrl2, _rel_end, _anim_t);
	Vec3D dir = vec_cons(next_rel_pos.x - _rel_pos.x, next_rel_pos.y - _rel_pos.y, 0);
	self.rotation = vec_ang_deg_lim180(dir,90);
	_rel_pos = next_rel_pos;
	[self update_rel_pos:game];
}

-(BOOL)should_remove{ return _anim_t >= 1; }

-(HitRect)get_hit_rect {
	return satpolyowner_cons_hit_rect(self.position, self.textureRect.size.width, self.textureRect.size.height);
}
-(void)get_sat_poly:(SATPoly*)in_poly {
	return satpolyowner_cons_sat_poly(in_poly, self.position, self.rotation, self.textureRect.size.width, self.textureRect.size.height, ccp(0.5,0.9));
}

-(void)hit_projectile:(GameEngineScene*)g { _anim_t = 1; }
-(void)hit_player_melee:(GameEngineScene*)g { _anim_t = 1; }

-(void)notify_leave:(GameEngineScene *)g {
	_rel_start = _rel_pos;
	_rel_end = ccp(_rel_end.x,_rel_start.y);
	_notify_leave = YES;
	_anim_t = 0;
}

@end
