#import "MainMenuScene.h"
#import "Common.h"
#import "GameMain.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "WebRequest.h"

#import "TouchButton.h"

@implementation MainMenuScene {
	CCTextField *_entry_field;
	CCLabelTTF *_error_log;
	
	NSString *_web_load_key;
}
+(MainMenuScene*)cons {
	return [MainMenuScene node];
}

-(id)init {
	self = [super init];
	self.userInteractionEnabled = YES;
	
	[self addChild:[[CCLabelTTF labelWithString:@"Hobobob Mobile" fontName:@"" fontSize:24] set_pos:game_screen_pct(0.5, 0.9)]];
	
	
	[self addChild:
		[[[TouchButton cons_callback:callback_cons(self, @selector(play_default))] set_pos:game_screen_pct(0.25, 0.5)]
			add_on:label_cons(ccp(50,50), ccc3(0,0,0), 16, @"Play default")]
	];
	
	[self addChild:
		[[[TouchButton cons_callback:callback_cons(self, @selector(play_url))] set_pos:game_screen_pct(0.75, 0.5)]
			add_on:label_cons(ccp(50,50), ccc3(0,0,0), 16, @"Load URL")]
	];
	
	CGRect entry_field_rect = CGRectMake(0, 0, 200, 30);
	CGSize entry_field_size = CGSizeMake(200, 30);
	_entry_field = (CCTextField*)[[CCTextField textFieldWithSpriteFrame:
		[CCSpriteFrame frameWithTexture:[Resource get_tex:TEX_BLANK] rectInPixels:entry_field_rect]]
		set_pos:game_screen_pct(0.5, 0.3)];
	
	[_entry_field setAnchorPoint:ccp(0.5,1)];
	_entry_field.contentSize = entry_field_size;
	_entry_field.preferredSize = entry_field_size;
	_entry_field.fontSize = 16.0f;
	
	_entry_field.string = @"spotcos.com/hb.json";
	[self addChild:
		_entry_field
	];
	
	_error_log = (CCLabelTTF*)[label_cons(game_screen_pct(0.5, 0.75), ccc3(255,255,255), 13, @"") add_to:self];
	
	return self;
}

-(void)play_default {
	//[GameMain to_scene:[GameEngineScene cons_with_map_name:@"testlevel"]];
}

-(void)play_url {
}

-(void)update:(CCTime)delta {
	if (_web_load_key != NULL) {
		//[GameMain to_scene:[GameEngineScene cons_with_map_name:_web_load_key]];
		_web_load_key = NULL;
	}
}

@end
