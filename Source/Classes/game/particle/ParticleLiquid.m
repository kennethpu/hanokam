#import "ParticleLiquid.h"
#import "Common.h"
#import	"GameEngineScene.h"

@implementation ParticleLiquid {
	float _vr;
	float _vx, _vy;
}

+(ParticleLiquid*)cons_tex:(CCTexture*)tex rect:(CGRect)rect {
	return [ParticleLiquid spriteWithTexture:tex rect:rect];
}

-(ParticleLiquid*)set_vr:(float)vr {
	_vr = vr;
	return self;
}

-(ParticleLiquid*)explode_speed:(float)speed {
	_vx = sinf(float_random(0, M_PI * 2)) * speed;
	_vy = cosf(float_random(0, M_PI * 2)) * speed;
	return self;
}

-(void)i_update:(id)g {
	float _x = self.position.x;
	float _y = self.position.y;
	
	if(_y > 0)
		_vy -= .2 * dt_scale_get();
	else {
		[g add_ripple:self.position];
	}
	
	
	_vx -= (_vx * .04) * dt_scale_get();
	
	_x += _vx * dt_scale_get();
	_y += _vy * dt_scale_get();

	[self setPosition:ccp(_x, _y)];
	[self setRotation:self.rotation + _vr * dt_scale_get()];
}

-(BOOL)should_remove {
	return (self.position.x < -30 || self.position.x > game_screen().width + 30 || self.position.y < 0);
}

-(int)get_render_ord {
	return 50;
}



@end
