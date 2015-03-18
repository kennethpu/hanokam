#import "Player.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"

#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"

#import "CCTexture_Private.h"

@implementation Player {
	CCAction *_anim_stand;
	CCAction *_current_anim;
	SpriterNode *_img;
}
@synthesize _vx,_vy;

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"hanoka v0.01.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_CHAR_HANOKATEST] frames:frame_data scml:@"hanoka v0.01.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[_img playAnim:@"test" repeat:YES];
	[self addChild:_img z:1];
	
	[self set_pos:game_screen_pct(0.5, 0.5)];
	[_img set_scale:0.5];
	
	return self;
}

static bool _test = YES;
-(void)test {
	if (_test) {
		[_img playAnim:@"in air" repeat:YES];
	} else {
		[_img playAnim:@"test" repeat:YES];
	}
	_test = !_test;
}

-(void)update_game:(GameEngineScene*)g {
	if ([self is_underwater]) {
		_vy += 0.1 * dt_scale_get();
	} else {
		_vy -= 0.1 * dt_scale_get();
		[self set_rotation:self.rotation + 5 * dt_scale_get()];
	}
	[self setPosition:ccp(
		clampf(self.position.x+_vx*dt_scale_get(), 0, game_screen().width),
		self.position.y+_vy*dt_scale_get()
	)];
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
