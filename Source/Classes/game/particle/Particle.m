#import "Particle.h"
#import "Resource.h"
#import "Common.h"

@implementation Particle
@synthesize vx,vy;

-(void)i_update:(GameEngineScene*)g {}
-(BOOL)should_remove { return YES; }
-(int)get_render_ord { return 0; }

@end
