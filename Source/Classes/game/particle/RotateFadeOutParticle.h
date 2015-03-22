#import "Particle.h"
@interface RotateFadeOutParticle : Particle
+(RotateFadeOutParticle*)cons_tex:(CCTexture*)tex rect:(CGRect)rect;
-(RotateFadeOutParticle*)set_ctmax:(float)ctmax;
-(RotateFadeOutParticle*)set_vr:(float)vr;
@end
