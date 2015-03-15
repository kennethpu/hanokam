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
}

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	_img = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_TEST_CHAR_HANOKA]]
					   set_anchor_pt:ccp(0.5,0.5)] add_to:self];
	
	[self set_pos:game_screen_pct(0.5, 0.5)];
	
	
	return self;
}

-(void)update_game:(GameEngineScene*)g {
	[self set_rotation:self.rotation + 5];
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
