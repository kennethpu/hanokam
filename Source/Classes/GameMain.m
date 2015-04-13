#import "GameMain.h"
#import "GameEngineScene.h"
#import "MainMenuScene.h"
#import "ShopScene.h"
#import "DataStore.h"

#import "Resource.h"
#import "ShaderManager.h"

/*
TODO --
dive lock y downwards no return
air phase after fall off pull back + health
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
