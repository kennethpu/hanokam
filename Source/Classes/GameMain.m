#import "GameMain.h"
#import "GameEngineScene.h"
#import "MainMenuScene.h"
#import "ShopScene.h"
#import "DataStore.h"

#import "Resource.h"
#import "ShaderManager.h"

/*
TODO --
spriter export or perf check
ground mode, hold to completing circle ui jump
after sword enemy invuln time
*/

@implementation GameMain
+(CCScene*)main; {
	[Resource load_all];
	[ShaderManager load_all];
	[DataStore cons];
	
	NSLog(@"%@",cocos2dVersion());
	//return [MainMenuScene cons];
	return [GameEngineScene cons];
	//return [ShopScene cons];
}
+(void)to_scene:(CCScene*)tar {
	[[CCDirector sharedDirector] replaceScene:tar];
}

@end
