#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "BGSky.h" 
#import "BGWater.h"

#import "Resource.h"
#import "CCTexture_Private.h"

@implementation GameEngineScene {
	Player *_player;
	
	CameraZoom _target_camera;
	CameraZoom _current_camera;
	
	CCNode *_game_anchor;
	
	CGPoint _last_follow_pt;
	
	BGSky *_bg_sky;
	BGWater *_bg_water;
}

+(GameEngineScene*)cons {
	return [[GameEngineScene node] cons];
}

-(id)cons {
	self.userInteractionEnabled = YES;
	dt_unset();
	_current_camera = camerazoom_cons(0, 0, 0.1);
	
	_game_anchor = [[CCNode node] add_to:self];
	_player = (Player*)[[Player cons] add_to:_game_anchor z:1];
	
	CCNode *bg_anchor = [[CCNode node] add_to:_game_anchor z:0];
	_bg_sky = (BGSky*)[[BGSky cons] add_to:bg_anchor];
	_bg_water = (BGWater*)[[BGWater cons] add_to:bg_anchor];
	/*
	CCSprite *bgsky = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_BACKGROUND_SKY]] set_anchor_pt:ccp(0,0)] add_to:self z:-1];
	scale_to_fit_screen_x(bgsky);
	scale_to_fit_screen_y(bgsky);
	
	CCSprite *bgbldgs = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_BACKGROUND_BUILDINGS]] set_anchor_pt:ccp(0,0)] add_to:self z:-1];
	scale_to_fit_screen_x(bgbldgs);
	scale_to_fit_screen_y(bgbldgs);
	bgbldgs.scaleY = bgbldgs.scaleY*0.75;
	
	_bgwindow = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_BACKGROUND_WINDOW]] set_anchor_pt:ccp(0,0)] add_to:self z:-1];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_bgwindow.texture setTexParameters:&par];
	[_bgwindow setTextureRect:CGRectMake(0, 0, game_screen().width, game_screen().height)];
	*/
	//_player = (Player*)[[[Player cons] add_to:_game_anchor] set_pos:_player_start_pt];
	return self;
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	
	[_player update_game:self];
	
	//[_bgwindow setTextureRect:CGRectMake([self get_follow_point].x*0.25, - [self get_follow_point].y*0.25, game_screen().width, game_screen().height)];
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}

-(BOOL)fullScreenTouch { return YES; }

-(void)add_particle:(Particle*)p{}
-(void)add_gameobject:(GameObject*)o{}
-(void)remove_gameobject:(GameObject*)o{}
-(void)set_target_camera:(CameraZoom)tar{}
-(void)shake_for:(float)ct intensity:(float)intensity{}
-(void)freeze_frame:(int)ct{}
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(_player.position.x-3000, _player.position.y-3000, 6000, 6000); }

@end
