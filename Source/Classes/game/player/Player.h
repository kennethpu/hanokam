#import "CCSprite.h"
#import "Common.h" 
@class GameEngineScene;

@interface Player : CCSprite
@property(readwrite, assign) float _vx, _vy;
@property(readwrite, assign) BOOL _falling;

+(Player*)cons;
-(void)update_game:(GameEngineScene*)g;
-(BOOL)is_underwater:(GameEngineScene*)g;
-(HitRect)get_hit_rect;

-(int)stat_damage;
@end
