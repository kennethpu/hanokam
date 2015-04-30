#import "Particle.h"
#import "Resource.h"
#import "Common.h"

@implementation Particle
-(void)i_update:(id)g {}
-(BOOL)should_remove { return YES; }
-(int)get_render_ord { return 0; }
-(void)do_remove{}
@end

@implementation ParticleSystem {
	NSMutableArray *_particles, *_to_remove, *_particles_tba;
	CCNode *_game_anchor;
}
+(ParticleSystem*)cons_anchor:(CCNode*)anchor {
	return [[[ParticleSystem alloc] init] cons_anchor:anchor];
}
-(ParticleSystem*)cons_anchor:(CCNode*)anchor {
	_particles = [NSMutableArray array];
	_to_remove = [NSMutableArray array];
	_particles_tba = [NSMutableArray array];
	_game_anchor = anchor;
	return self;
}
-(void)add_particle:(Particle*)p {
    [_particles_tba addObject:p];
}
-(void)update_particles:(id)parent {
    for (Particle *p in _particles_tba) {
        [_particles addObject:p];
        [_game_anchor addChild:p z:[p get_render_ord]];
    }
    [_particles_tba removeAllObjects];
    for (Particle *i in _particles) {
        [i i_update:parent];
        if ([i should_remove]) {
			[i do_remove];
			[_game_anchor removeChild:i cleanup:YES];
            [_to_remove addObject:i];
        }
    }
    [_particles removeObjectsInArray:_to_remove];
	[_to_remove removeAllObjects];
}
-(NSArray*)list {
	return _particles;
}
@end
