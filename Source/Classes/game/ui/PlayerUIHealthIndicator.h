#import "CCNode.h"

@class GameEngineScene;
@interface PlayerUIHealthIndicator : CCNode

+(PlayerUIHealthIndicator*)cons:(GameEngineScene*)g;
-(void)i_update:(GameEngineScene*)g;
-(void)pulse_heart_lastfill;
@end
