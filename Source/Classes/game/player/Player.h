#import "CCSprite.h"
#import "Common.h"
#import "PolyLib.h" 
@class GameEngineScene;

@interface Player : CCSprite <SATPolyHitOwner>

+(Player*)cons_g:(GameEngineScene*)g;
-(void)i_update:(GameEngineScene*)g;
-(BOOL)is_underwater:(GameEngineScene*)g;
-(HitRect)get_hit_rect;
@end
