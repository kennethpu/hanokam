#import "CCSprite.h"

@class GameEngineScene;

@interface Particle : CCSprite {
    float vx,vy;
}

@property(readwrite,assign) float vx,vy;

-(void)i_update:(GameEngineScene*)g;
-(BOOL)should_remove;
-(int)get_render_ord;

@end
