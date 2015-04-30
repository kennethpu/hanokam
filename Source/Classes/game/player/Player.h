#import "CCSprite.h"
#import "Common.h"
#import "PolyLib.h" 
@class GameEngineScene;

@interface Player : CCSprite <SATPolyHitOwner>

+(Player*)cons_g:(GameEngineScene*)g;
-(void)i_update:(GameEngineScene*)g;
-(BOOL)is_underwater:(GameEngineScene*)g;
-(HitRect)get_hit_rect;

-(void)add_health:(float)val g:(GameEngineScene*)g;
-(void)set_health:(float)val;
-(int)get_max_health;
-(float)get_current_health;
@end
