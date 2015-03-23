#import "RotateFadeOutParticle.h"

@implementation RotateFadeOutParticle {
	float _ct, _ctmax;
	float _vr;
}

+(RotateFadeOutParticle*)cons_tex:(CCTexture*)tex rect:(CGRect)rect {
	return [RotateFadeOutParticle spriteWithTexture:tex rect:rect];
}

-(RotateFadeOutParticle*)set_ctmax:(float)ctmax {
	_ctmax = ctmax;
	_ct = _ctmax;
	return self;
}

-(RotateFadeOutParticle*)set_vr:(float)vr {
	_vr = vr;
	return self;
}

-(void)i_update:(id)g {
	float pct = _ct/_ctmax;
	_ct -= dt_scale_get();
	[self setOpacity:255 * pct];
	[self setRotation:self.rotation + _vr * dt_scale_get()];
}

-(BOOL)should_remove {
	return _ct <= 0;
}

-(int)get_render_ord {
	return 50;
}



@end
