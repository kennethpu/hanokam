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
	
	CGPoint _camera_center_point;
	
	BGSky *_bg_sky;
	BGWater *_bg_water;
	NSArray *_bg_elements;
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
	_bg_elements = @[_bg_sky,_bg_water];
	
	return self;
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	
	[_player update_game:self];
	[self center_camera_hei:_player.position.y];
	
	for (BGElement *itr in _bg_elements) {
		[itr i_update:self];
	}
}

-(void)center_camera_hei:(float)hei {
	CGPoint pt = ccp(game_screen().width/2,hei);
	_camera_center_point = pt;
	CGSize s = [CCDirector sharedDirector].viewSize;
	CGPoint halfScreenSize = ccp(s.width/2,s.height/2);
	[_game_anchor setScale:1];
	[_game_anchor setPosition:CGPointAdd(
	 ccp(
		 clampf(halfScreenSize.x-pt.x,-999999,999999) * [self scale],
		 clampf(halfScreenSize.y-pt.y,-999999,999999) * [self scale]),
	 ccp(_current_camera.x,_current_camera.y))];
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
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(_camera_center_point.x-game_screen().width/2,_camera_center_point.y-game_screen().height/2,game_screen().width,game_screen().height); }

@end

@implementation BGElement
-(void)i_update:(GameEngineScene*)game{}
@end
