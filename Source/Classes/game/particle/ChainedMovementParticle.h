#import "Particle.h"

@interface ChainedMovementParticle : Particle
+(ChainedMovementParticle*)cons;
-(ChainedMovementParticle*)add_waypoint:(CGPoint)target speed:(float)speed;
-(ChainedMovementParticle*)add_playerx_waypoint:(float)target_y speed:(float)speed ;
-(ChainedMovementParticle*)set_relative;
-(int)waypoints_left;
@end
