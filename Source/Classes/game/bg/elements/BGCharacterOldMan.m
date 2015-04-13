#import "BGCharacterOldMan.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"
#import "Common.h"

#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"

@implementation BGCharacterOldMan {
	SpriterNode *_img;
	CCSprite *_thoughtbubble;
	NSString *_current_playing;
	NSString *_on_finish_play_anim;
}

+(BGCharacterOldMan*)cons_pos:(CGPoint)pos {
	return [[BGCharacterOldMan node] cons_pos:pos];
}

-(BGCharacterOldMan*)cons_pos:(CGPoint)pos {
	[self setPosition:pos];
	
	[self setScale:0.45];
	[self setScaleX:self.scale*-1];
	
	SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"oldman_ss.json"];
	SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:[Resource get_tex:TEX_SPRITER_CHAR_OLDMAN] frames:frame_data scml:@"oldman.scml"];
	_img = [SpriterNode nodeFromData:spriter_data];
	[self play_anim:@"idle" repeat:YES];
	[self addChild:_img];
	
	_thoughtbubble = [CCSprite node];
	[_thoughtbubble runAction:animaction_cons(@[@"thought_cloud_0.png",@"thought_cloud_1.png"], 0.5, TEX_HUD_SPRITESHEET)];
	[_thoughtbubble setPosition:ccp(-280,200)];
	[self addChild:_thoughtbubble];
	
	[_thoughtbubble addChild:flipper_cons_for(
		label_cons(ccp(-150,100), ccc3(0, 0, 0), 20, @"who is\nthis scrub"),
		-1,1
	)];
	[_thoughtbubble setOpacity:0.85];
	
	return self;
}

-(void)i_update:(GameEngineScene *)g {

}

-(void)play_anim:(NSString*)anim repeat:(BOOL)repeat {
	_on_finish_play_anim = NULL;
	if(_current_playing != anim) {
		_current_playing = anim;
		[_img playAnim:anim repeat:repeat];
	}
}

-(void)play_anim:(NSString*)anim1 on_finish_anim:(NSString*)anim2 {
	_current_playing = anim1;
	[_img playAnim:anim1 repeat:NO];
	_on_finish_play_anim = anim2;
}

@end
