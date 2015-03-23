#import "UIBossIntroParticle.h"

typedef enum _UIBossIntroParticleMode {
	UIBossIntroParticleMode_In,
	UIBossIntroParticleMode_InWait,
	UIBossIntroParticleMode_HeaderWait,
	UIBossIntroParticleMode_SubWait,
	UIBossIntroParticleMode_FadeOut,
	UIBossIntroParticleMode_End
} UIBossIntroParticleMode;

@implementation UIBossIntroParticle {
	CCSprite *_splash;
	CCLabelTTF *_header,*_sub;
	UIBossIntroParticleMode _current_mode;
	float _ct;
}
+(UIBossIntroParticle*)cons_header:(NSString*)header sub:(NSString*)sub {
	return [[UIBossIntroParticle node] cons_header:header sub:sub];
}

-(UIBossIntroParticle*)cons_header:(NSString*)header sub:(NSString*)sub {
	_splash = [CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"splatter.png"]];
	[_splash setScale:0.5];
	[_splash setPosition:game_screen_pct(-0.1, 0.5)];
	[_splash setAnchorPoint:ccp(0,0.5)];
	[self addChild:_splash];
	
	_header = label_cons(pct_of_obj(_splash, 0.35, 0.525), ccc3(255, 255, 255), 25, header);
	[_splash addChild:_header];
	
	_sub = label_cons(pct_of_obj(_splash, 0.5, 0.375), ccc3(255,255,255), 10, sub);
	[_splash addChild:_sub];
	
	_current_mode = UIBossIntroParticleMode_In;
	_ct = 0;
	
	[_splash setTextureRect:CGRectZero];
	
	return self;
}

-(void)i_update:(id)g {
	switch (_current_mode) {
		case UIBossIntroParticleMode_In:;
			CGRect tar_rect = [FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"splatter.png"];
			_ct = clampf(_ct+0.2 * dt_scale_get(),0,1);
			tar_rect.size.width *= _ct;
			[_splash setTextureRect:tar_rect];
			[_header setVisible:NO];
			[_sub setVisible:NO];
			if (_ct >= 1) {
				_current_mode = UIBossIntroParticleMode_InWait;
				_ct = 0;
				
			}
		break;
		case UIBossIntroParticleMode_InWait:;
			_ct += 0.05 * dt_scale_get();
			if (_ct >= 1) {
				_current_mode = UIBossIntroParticleMode_HeaderWait;
				_ct = 0;
				[_header setVisible:YES];
			}
		break;
		case UIBossIntroParticleMode_HeaderWait:;
			_ct += 0.05 * dt_scale_get();
			if (_ct >= 1) {
				_current_mode = UIBossIntroParticleMode_SubWait;
				_ct = 0;
				[_sub setVisible:YES];
			}
		break;
		case UIBossIntroParticleMode_SubWait:;
			_ct += 0.01 * dt_scale_get();
			if (_ct >= 1) {
				_current_mode = UIBossIntroParticleMode_FadeOut;
				_ct = 1;
			}
		break;
		case UIBossIntroParticleMode_FadeOut:;
			_ct -= 0.1 * dt_scale_get();
			[_splash setOpacity:_ct];
			[_header setOpacity:_ct];
			[_sub setOpacity:_ct];
			
			[_header set_pos:ccp(_header.position.x + 1, _header.position.y)];
			[_sub set_pos:ccp(_sub.position.x - 1, _sub.position.y)];
			
			if (_ct <= 0) _current_mode = UIBossIntroParticleMode_End;
		break;
		case UIBossIntroParticleMode_End:;
		break;
	}
	[_header set_pos:ccp(_header.position.x + .2, _header.position.y)];
	[_sub set_pos:ccp(_sub.position.x - .2, _sub.position.y)];
}
-(BOOL)should_remove {
	return _current_mode == UIBossIntroParticleMode_End;
}
@end
