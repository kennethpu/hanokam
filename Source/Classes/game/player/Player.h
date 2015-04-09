#import "CCSprite.h"
#import "Common.h" 
@class GameEngineScene;

@interface Player : CCSprite

+(Player*)cons_g:(GameEngineScene*)g;
-(void)i_update:(GameEngineScene*)g;
-(BOOL)is_underwater:(GameEngineScene*)g;
-(HitRect)get_hit_rect;
@end
