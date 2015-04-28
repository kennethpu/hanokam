#import "BGCharacterTest.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"
#import "Common.h"

#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"

@implementation BGCharacterTest {
	SpriterNode *_img;
	
	NSString *_current_playing;
	NSString *_on_finish_play_anim;
}


+(BGCharacterTest*)cons_pos:(CGPoint)pos {
	return [[BGCharacterTest node] cons_pos:pos];
}

-(BGCharacterTest*)cons_pos:(CGPoint)pos {
	[self setPosition:pos];
	
	[self setScale:0.45];
	
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"enemy_puffer.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_ENEMY_PUFFER] frames:frame_data scml:@"enemy_puffer.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[self play_anim:@"Idle" repeat:YES];
	[self addChild:_img];
	
	return self;
}

-(void)i_update:(GameEngineScene*)g {

}

-(void)play_anim:(NSString*)anim repeat:(BOOL)repeat {
	_on_finish_play_anim = NULL;
	if(_current_playing != anim) {
		_current_playing = anim;
		[_img playAnim:anim repeat:repeat];
	}
}
@end
