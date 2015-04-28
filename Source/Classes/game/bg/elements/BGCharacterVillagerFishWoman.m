#import "BGCharacterVillagerFishWoman.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"
#import "Common.h"

#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"

@implementation BGCharacterVillagerFishWoman {
	SpriterNode *_img;
	
	NSString *_current_playing;
	NSString *_on_finish_play_anim;
}


+(BGCharacterVillagerFishWoman*)cons_pos:(CGPoint)pos {
	return [[BGCharacterVillagerFishWoman node] cons_pos:pos];
}

-(BGCharacterVillagerFishWoman*)cons_pos:(CGPoint)pos {
	[self setPosition:pos];
	
	[self setScale:0.45];
	_img = [SpriterNode nodeFromData:[FileCache spriter_scml_data_from_file:@"villager_fishwoman.scml" json:@"villager_fishwoman.json" texture:[Resource get_tex:TEX_SPRITER_CHAR_VILLAGER_FISHWOMAN]]];
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
