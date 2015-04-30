#import "CCNode.h"
@class GameEngineScene;
@interface GameUI : CCNode
+(GameUI*)cons:(GameEngineScene*)game;
-(void)i_update:(GameEngineScene*)game;

-(void)flash_red;
-(void)fadeout:(BOOL)tar;
-(BOOL)is_faded_out;
-(BOOL)is_faded_in;

-(void)pulse_heart_lastfill;

-(void)start_boss:(NSString*)title sub:(NSString*)sub;
@end
