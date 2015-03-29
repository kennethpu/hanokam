//
//  Arrow.m
//  hobobob
//
//  Created by spotco on 22/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Arrow.h"
#import "GameEngineScene.h"
#import "Resource.h"

@implementation PlayerProjectile
-(HitRect)get_hit_rect { return hitrect_cons_xy_widhei(self.position.x, self.position.y, 1, 1); }
@end

@implementation Arrow {
	CCSprite *_sprite;
	Vec3D _dir;
	float _ct;
}

+(Arrow*)cons_pos:(CGPoint)pos dir:(Vec3D)dir {
	return [[Arrow node] cons_pos:pos dir:dir];
}

-(Arrow*)cons_pos:(CGPoint)pos dir:(Vec3D)dir {
	[self setPosition:pos];
	[self setRotation:vec_ang_deg_lim180(dir, 0) + 180];
	_sprite = (CCSprite*)[[CCSprite spriteWithTexture:[Resource get_tex:TEX_ARROW]] add_to:self z:0];
	[_sprite set_anchor_pt:ccp(0.7, 0.5)];
	[_sprite set_scale:0.2];
	_dir = dir;
	vec_norm_m(&_dir);
	vec_scale_m(&_dir, 10);
	_ct = 40;
	return self;
}

-(void)i_update:(id)g {
	[self setPosition:CGPointAdd(self.position, ccp(_dir.x*dt_scale_get(),_dir.y*dt_scale_get()))];
	_ct -= dt_scale_get();
}

-(int)get_render_ord {
	return GameAnchorZ_PlayerProjectiles;
}

-(BOOL)should_remove {
	return _ct <= 0;
}

@end
