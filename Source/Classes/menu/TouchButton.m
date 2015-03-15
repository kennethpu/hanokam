#import "TouchButton.h"
#import "Resource.h"

@implementation TouchButton {
	CallBack *_callback;
	BOOL _pressed;
}
+(TouchButton*)cons_callback:(CallBack *)cb {
	return [[TouchButton node] cons_callback:cb];
}
-(TouchButton*)cons_callback:(CallBack*)cb {
	_callback = cb;
	[self setTexture:[Resource get_tex:TEX_BLANK]];
	[self setTextureRect:CGRectMake(0, 0, 100, 100)];
	self.userInteractionEnabled = YES;
	_pressed = NO;
	return self;
}
-(void)update:(CCTime)delta {
	[self setScale:drp(self.scale, _pressed?1.5:1, 10)];
}

-(BOOL)touch_on_self:(CCTouch*)touch {
	CGPoint worldTouchLocation = [[CCDirector sharedDirector] convertToGL:[touch locationInView:(CCGLView*)[CCDirector sharedDirector].view]];
	float pre_scale = [self scale];
	[self setScale:1];
	BOOL rtv = [self hitTestWithWorldPos:worldTouchLocation];
	[self setScale:pre_scale];
	return rtv;
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_pressed = YES;
}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	if (![self touch_on_self:touch]) {
		_pressed = NO;
	}
}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	if (_pressed && [self touch_on_self:touch]) {
		callback_run(_callback);
	}
	_pressed = NO;
}
@end
