#import "Particle.h"
@interface ParticlePhysical : Particle
+(ParticlePhysical*)cons_tex:(CCTexture*)tex rect:(CGRect)rect;
-(ParticlePhysical*)explode_speed:(float)speed;
@end