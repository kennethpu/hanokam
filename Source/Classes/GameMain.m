#import "GameMain.h"
#import "GameEngineScene.h"
#import "MainMenuScene.h"
#import "ShopScene.h"
#import "DataStore.h"

#import "Resource.h"
#import "ShaderManager.h"

/*
TODO --
damage recoil player anim
enemies use spriter anims, pooled

ground mode, hold to completing circle ui jump
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
