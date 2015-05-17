//
//  PufferBasicAirEnemy.m
//  hobobob
//
//  Created by spotco on 17/05/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PufferBasicAirEnemy.h"
#import "Resource.h" 
#import "FileCache.h"

@implementation PufferBasicAirEnemy {
	CCSprite_Animated *_img;
	
	CCAction *_anim_idle, *_anim_attack, *_anim_die, *_anim_follow, *_anim_hurt;
}

+(PufferBasicAirEnemy*)cons_g:(GameEngineScene*)g relstart:(CGPoint)relstart relend:(CGPoint)relend {
	return (PufferBasicAirEnemy*)[[PufferBasicAirEnemy node] cons_g:g relstart:relstart relend:relend];
}

-(BasicAirEnemy*)cons_g:(GameEngineScene*)g relstart:(CGPoint)relstart relend:(CGPoint)relend {
	[super cons_g:g relstart:relstart relend:relend];
	
	[self cons_anims];
	_img = [CCSprite_Animated node];
	[self addChild:_img];
	[_img update_playAnim:_anim_idle];
	[_img setScale:0.35];
	
	return self;
}

-(void)update_death:(GameEngineScene *)g {
	[_img update_playAnim:_anim_die];
}

-(void)cons_anims {
	NSMutableArray *anim_strs = [NSMutableArray array];
	float anim_interval = 0.055;
	
	DO_FOR(27, [anim_strs addObject:strf("puffer_idle__%03d.png",i)]; );
	_anim_idle = animaction_cons(anim_strs, anim_interval, TEX_ENEMY_PUFFER);
	[anim_strs removeAllObjects];
	
	DO_FOR(5, [anim_strs addObject:strf("puffer_attack__%03d.png",i)]; );
	_anim_attack = animaction_cons(anim_strs, anim_interval, TEX_ENEMY_PUFFER);
	[anim_strs removeAllObjects];
	
	DO_FOR(14, [anim_strs addObject:strf("puffer_die__%03d.png",i)]; );
	_anim_die = animaction_nonrepeating_cons(anim_strs, anim_interval, TEX_ENEMY_PUFFER);
	[anim_strs removeAllObjects];
	
	DO_FOR(5, [anim_strs addObject:strf("puffer_follow__%03d.png",i)]; );
	_anim_follow = animaction_cons(anim_strs, anim_interval, TEX_ENEMY_PUFFER);
	[anim_strs removeAllObjects];
	
	DO_FOR(5, [anim_strs addObject:strf("puffer_hurt__%03d.png",i)]; );
	_anim_hurt = animaction_cons(anim_strs, anim_interval, TEX_ENEMY_PUFFER);
	[anim_strs removeAllObjects];
}

-(HitRect)get_hit_rect {
	CGRect rect = [FileCache get_cgrect_from_plist:TEX_ENEMY_PUFFER idname:@"puffer_idle__000.png"];
	return satpolyowner_cons_hit_rect(self.position, rect.size.width, rect.size.height);
}
-(void)get_sat_poly:(SATPoly*)in_poly {
	CGRect rect = [FileCache get_cgrect_from_plist:TEX_ENEMY_PUFFER idname:@"puffer_idle__000.png"];
	return satpolyowner_cons_sat_poly(in_poly, self.position, self.rotation, rect.size.width, rect.size.height, ccp(0.5,0.9));
}

@end
