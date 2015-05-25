//
//  Arrow.m
//  hobobob
//
//  Created by spotco on 22/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PlayerProjectile.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "AirEnemyManager.h"

@implementation PlayerProjectile
-(HitRect)get_hit_rect { return hitrect_cons_xy_widhei(self.position.x, self.position.y, 1, 1); }
-(void)get_sat_poly:(SATPoly *)in_poly { SAT_cons_quad_buf(in_poly, CGPointZero, CGPointZero, CGPointZero, CGPointZero); }
-(BOOL)get_active { return YES; }
@end

@implementation Arrow {
	CCSprite *_sprite;
	CCSprite *_trail;
	Vec3D _dir;
	float _ct;
	float _trail_tar_alpha;
	
	BOOL _floating;
}

+(Arrow*)cons_pos:(CGPoint)pos dir:(Vec3D)dir {
	return [[Arrow node] cons_pos:pos dir:dir];
}

-(Arrow*)cons_pos:(CGPoint)pos dir:(Vec3D)dir {
	_floating = NO;
	[self setPosition:pos];
	[self setRotation:vec_ang_deg_lim180(dir, 0) + 180];
	_sprite = [CCSprite spriteWithTexture:[Resource get_tex:TEX_PARTICLES_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES_SPRITESHEET idname:@"arrow.png"]];
	[self addChild:_sprite];
	
	_trail = [CCSprite spriteWithTexture:[Resource get_tex:TEX_PARTICLES_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES_SPRITESHEET idname:@"arrow_trail.png"]];
	[_trail setAnchorPoint:ccp(1,0.5)];
	[_trail setPosition:pct_of_obj(_sprite, 0, 0.5)];
	[_trail setOpacity:0];
	[_sprite addChild:_trail];
	
	[_sprite set_anchor_pt:ccp(0.5, 0.5)];
	[_sprite set_scale:0.2];
	_dir = dir;
	vec_norm_m(&_dir);
	vec_scale_m(&_dir, 10);
	_ct = 100;
	
	_trail_tar_alpha = 0;
	
	return self;
}

-(void)i_update:(id)g {
	if (_floating) {
		[_trail setOpacity:0];
		if (_dir.x > 0) {
			[self setRotation:drp(self.rotation, 0, 50)];
		} else {
			[self setRotation:drp(self.rotation, 180, 50)];
		}
		[self setPosition:CGPointAdd(self.position, ccp(_dir.x*dt_scale_get()*0.1,-2*dt_scale_get()))];
		_ct-= dt_scale_get();
		[_sprite setOpacity:lerp(0, 1, _ct/50)];
		
	} else {
	
		if ([[g class] isSubclassOfClass:[GameEngineScene class]]) {
			GameEngineScene *game = (GameEngineScene*)g;
			for (BaseAirEnemy *itr in game.get_air_enemy_manager.get_enemies) {
				if (itr.is_alive && SAT_polyowners_intersect(self, itr)) {
					_ct = 0;
					[itr hit_projectile:g];
				}
			}
		}
	
		[self setPosition:CGPointAdd(self.position, ccp(_dir.x*dt_scale_get(),_dir.y*dt_scale_get()))];
		_ct -= dt_scale_get();
		if (_ct > 90) {
			_trail_tar_alpha = 0;
		} else {
			_trail_tar_alpha = 1;
		}
		[_trail setOpacity:drp(_trail.opacity,_trail_tar_alpha,10)];
		if (self.position.x < -50 || self.position.x > game_screen().width + 50) {
			_ct = 0;
		} else if (self.position.y <= 0) {
			_floating = YES;
			if ([[g class] isSubclassOfClass:[GameEngineScene class]]) {
				GameEngineScene *game = (GameEngineScene*)g;
				[game add_ripple:self.position];
				_ct = 50;
			}
		}
	}
}

-(BOOL)get_active {
	return !_floating;
}

-(int)get_render_ord {
	return GameAnchorZ_PlayerProjectiles;
}

-(BOOL)should_remove {
	return _ct <= 0;
}

-(HitRect)get_hit_rect {
	return satpolyowner_cons_hit_rect(self.position, _sprite.textureRect.size.width, _sprite.textureRect.size.height);
}
-(void)get_sat_poly:(SATPoly*)in_poly {
	return satpolyowner_cons_sat_poly(in_poly, self.position, self.rotation, _sprite.textureRect.size.width, _sprite.textureRect.size.height, ccp(1,1));
}

@end
