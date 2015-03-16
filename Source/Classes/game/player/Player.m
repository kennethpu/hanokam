#import "Player.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"

#import "CCTexture_Private.h"

@implementation Player {
	CCAction *_anim_stand;
	CCAction *_current_anim;
	CCSprite *_img;
	
	CGPoint _velocity;
}

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	_img = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_CHAR_HANOKA]]
					   set_anchor_pt:ccp(0.5,0.5)] add_to:self];
	
	[self set_pos:game_screen_pct(0.5, 0.5)];
	[_img set_scale:0.5];
	
	return self;
}

-(void)update_game:(GameEngineScene*)g {
	[self set_rotation:self.rotation + 5 * dt_scale_get()];
	if ([self is_underwater]) {
		_velocity.y += 0.1 * dt_scale_get();
	} else {
		_velocity.y -= 0.1 * dt_scale_get();
	}
	[self setPosition:ccp(self.position.x+_velocity.x*dt_scale_get(),self.position.y+_velocity.y*dt_scale_get())];
}

-(BOOL)is_underwater {
	return self.position.y < 0;
}

-(void)run_anim:(CCAction*)tar {
	if (_current_anim != tar) {
		_current_anim = tar;
		[_img stopAllActions];
		[_img runAction:_current_anim];
	}
}

-(HitRect)get_hit_rect {
	return hitrect_cons_xy_widhei(self.position.x-10, self.position.y, 20, 40);
}
@end
