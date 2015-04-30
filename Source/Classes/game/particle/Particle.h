#import "CCSprite.h"

#import "Resource.h" 
#import "Common.h"
#import "FileCache.h"

@class GameEngineScene;

@interface Particle : CCSprite
-(void)i_update:(id)g;
-(BOOL)should_remove;
-(int)get_render_ord;
-(void)do_remove;
@end

@interface ParticleSystem : NSObject
+(ParticleSystem*)cons_anchor:(CCNode*)anchor;
-(void)add_particle:(Particle*)p;
-(void)update_particles:(id)parent;
-(NSArray*)list;
@end
