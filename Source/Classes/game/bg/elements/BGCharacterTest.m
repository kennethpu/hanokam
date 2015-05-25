#import "BGCharacterTest.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"
#import "Common.h"
#import "ControlManager.h"

#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"

@implementation BGCharacterTest {
	SpriterNode *_img;
	CCSprite *_spr_img;
	
	NSString *_current_playing;
	NSString *_on_finish_play_anim;
}


+(BGCharacterTest*)cons_pos:(CGPoint)pos {
	return [[BGCharacterTest node] cons_pos:pos];
}

/*
Requirements:
1. All bones are children of a central "parent" bone.
2. All images have a bone parent.
3. Do not change the parent of a bone or image within an animation.

Try to avoid:
1. Rotating images (rotate the parent bone instead).

Remember:
1. Idle bob animation is about 600 frames long (scale everything to that).
2. Start animation names with capitals letters, and words with spaces "In Air"
*/

/*
todo:
--spriternode reduce allocations
*/
-(BGCharacterTest*)cons_pos:(CGPoint)pos {
	[self setPosition:pos];
	
	[self setScale:1];
	
	/*
	_img = [SpriterNode nodeFromData:[FileCache spriter_scml_data_from_file:@"spriter_test.scml" json:@"spriter_test.json" texture:[Resource get_tex:TEX_SPRITER_TEST]]];
	[self play_anim:@"Die" repeat:YES];
	[self addChild:_img];
	*/
	
	/*
	_spr_img = [CCSprite node];
	[self addChild:_spr_img];
	
	NSMutableArray *anim_strs = [NSMutableArray array];
	DO_FOR(27,
		[anim_strs addObject:strf("puffer_idle__%03d.png",i)];
	);
	CCAction *anim = animaction_cons(anim_strs, 0.055, TEX_ENEMY_PUFFER);
	[_spr_img runAction:anim];
	*/
	//animaction_cons(@[], 0.1, TEX_ENEMY_PUFFER);
	
	
	/*
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"spriter_test.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_TEST] frames:frame_data scml:@"spriter_test.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[self play_anim:@"Test" repeat:YES];
	[self addChild:_img];
	*/
	return self;
}

static int _test = 0;
static bool _last_touch_down = NO;
-(void)i_update:(GameEngineScene*)g {
	if (_last_touch_down == NO && [g.get_control_manager is_touch_down]) {
		_test = (_test+1)%5;
		if (_test == 0) {
			[self play_anim:@"Die" repeat:YES];
		} else if (_test == 1) {
			[self play_anim:@"Idle" repeat:YES];
		} else if (_test == 2) {
			[self play_anim:@"Attack" repeat:YES];
		} else if (_test == 3) {
			[self play_anim:@"Follow" repeat:YES];
		} else {
			[self play_anim:@"Hurt Sword" repeat:YES];
		}
	}
	_last_touch_down = [g.get_control_manager is_touch_down];
}

-(void)play_anim:(NSString*)anim repeat:(BOOL)repeat {
	_on_finish_play_anim = NULL;
	if(_current_playing != anim) {
		_current_playing = anim;
		[_img playAnim:anim repeat:repeat];
	}
}
@end
