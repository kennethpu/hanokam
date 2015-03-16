#import "cocos2d.h"
#import "Common.h"
@class Player;
@class Island;
@class GameEngineScene;

@interface GameObject : CCSprite

-(void)i_update:(GameEngineScene *)g;
-(HitRect)get_hit_rect;
-(int)get_render_ord;
-(void)check_should_render:(GameEngineScene*)g;
@end
