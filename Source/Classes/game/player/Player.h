#import "CCSprite.h"
#import "Common.h" 
@class GameEngineScene;

@interface Player : CCSprite
@property(readwrite,assign) float _vx, _vy;
+(Player*)cons;
-(void)update_game:(GameEngineScene*)g;
-(BOOL)is_underwater;
-(HitRect)get_hit_rect;
-(void)melee_spirit;
@end
