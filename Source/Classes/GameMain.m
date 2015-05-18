#import "GameMain.h"
#import "GameEngineScene.h"
#import "MainMenuScene.h"
#import "ShopScene.h"
#import "DataStore.h"

#import "Resource.h"
#import "ShaderManager.h"
#import "SpriterUtil.h"

/*
TODO --
ground mode, hold to completing circle ui jump
after sword enemy invuln time

PERF --
make TGSpriter classes structs instead
*/

@implementation GameMain
+(CCScene*)main; {
	calc_table_scubic_point_for_t();
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
