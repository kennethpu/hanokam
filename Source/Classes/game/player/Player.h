#import "CCSprite.h"
#import "Common.h" 
@class GameEngineScene;

@interface Player : CCSprite
+(Player*)cons;
-(void)update_game:(GameEngineScene*)g;

-(BOOL)is_underwater;


-(HitRect)get_hit_rect;
@end
