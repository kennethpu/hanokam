#import "Particle.h"
@interface ParticleBubble : Particle
+(ParticleBubble*)cons_tex:(CCTexture*)tex rect:(CGRect)rect;
-(ParticleBubble*)explode_speed:(float)speed;
@end