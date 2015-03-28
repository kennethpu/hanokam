#import "TouchTrackingLayer.h"
#import "Resource.h"
#import "FileCache.h"
#import "Common.h"

@implementation TouchTrackingLayer {
    CCMotionStreak *_motion_streak;
    CCSprite *_touch_button;
	BOOL _is_touch_down;
	int _ct;
}

-(id)init{
    self=[super init];
	_motion_streak = [CCMotionStreak streakWithFade:0.4 minSeg:10 width:10 color:[CCColor whiteColor] texture:[Resource get_tex:TEX_BLANK]];
	[self addChild:_motion_streak];
	
	_touch_button = [CCSprite spriteWithTexture:[Resource get_tex:TEX_PARTICLES_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES_SPRITESHEET idname:@"grey_particle"]];
    [self addChild:_touch_button];
    [_touch_button setOpacity:0];
	
    return self;
}


-(void)update:(CCTime)delta {
	_ct++;
	if (_is_touch_down) {
		_touch_button.scale = drp(_touch_button.scale, 1, 30.0);
		_touch_button.opacity = drp(_touch_button.opacity, 0.25, 30.0);
		if (_ct % 20 == 0) {
			_touch_button.opacity = 1;
			_touch_button.scale = 6;
		}
	} else {
		_touch_button.scale = drp(_touch_button.scale, 1, 20.0);
		_touch_button.opacity = drp(_touch_button.opacity, 0, 20.0);
	}
}

-(void)touch_begin:(CGPoint)pt {
	_is_touch_down = YES;
	[_motion_streak reset];
	_touch_button.opacity = 1;
	_touch_button.scale = 6;
	[_touch_button setPosition:pt];
	[_motion_streak setPosition:pt];
}
-(void)touch_move:(CGPoint)pt {
	_ct = 1;
	_is_touch_down = YES;
	_touch_button.opacity = 1;
	[_touch_button setPosition:pt];
	[_motion_streak setPosition:pt];
	//[_motion_streak setVisible:YES];
}
-(void)touch_end:(CGPoint)pt {
	_is_touch_down = NO;
	[_motion_streak reset];
	//[_motion_streak setVisible:NO];
}

@end
