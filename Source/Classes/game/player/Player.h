#import "CCSprite.h"
#import "Common.h" 
@class GameEngineScene;

@interface Player : CCSprite
+(Player*)cons;
-(void)update_game:(GameEngineScene*)g;
-(HitRect)get_hit_rect;
@end
