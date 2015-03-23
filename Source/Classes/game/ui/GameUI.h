#import "CCNode.h"
@class GameEngineScene;
@interface GameUI : CCNode
+(GameUI*)cons:(GameEngineScene*)game;
-(void)i_update:(GameEngineScene*)game;
-(void)start_boss:(NSString*)title sub:(NSString*)sub;
@end
