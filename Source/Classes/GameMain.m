#import "GameMain.h"
#import "GameEngineScene.h"
#import "MainMenuScene.h"
#import "ShopScene.h"

#import "Resource.h"

@implementation GameMain
+(CCScene*)main; {
	[Resource load_all];
	NSLog(@"%@",cocos2dVersion());
	//return [MainMenuScene cons];
	return [GameEngineScene cons];
	//return [ShopScene cons];
}
+(void)to_scene:(CCScene*)tar {
	[[CCDirector sharedDirector] replaceScene:tar];
}
@end
