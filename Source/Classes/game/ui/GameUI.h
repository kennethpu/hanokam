#import "CCNode.h"
@class GameEngineScene;
@interface GameUI : CCNode
+(GameUI*)cons:(GameEngineScene*)game;
-(void)i_update:(GameEngineScene*)game;
@end
