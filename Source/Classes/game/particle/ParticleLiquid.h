#import "Particle.h"
@interface ParticleLiquid : Particle
+(ParticleLiquid*)cons_tex:(CCTexture*)tex rect:(CGRect)rect;
-(ParticleLiquid*)explode_speed:(float)speed;
@end