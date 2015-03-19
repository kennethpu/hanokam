#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "BGSky.h" 
#import "BGWater.h"
#import "BGFog.h"
#import "SpiritBase.h"
#import "SpiritBasic.h"

#import "AccelerometerManager.h"
//#import "AccelerometerSimulation.h" 

#import "Resource.h"
#import "CCTexture_Private.h"

@implementation GameEngineScene {
	CGPoint _touchPosition;
	BOOL _touchDown;
	BOOL _touchTap;
	BOOL _touchRelease;
	
	float _tick;
	float _camY;

	Player *_player;
	NSMutableArray *_spirits;
	
	CameraZoom _target_camera;
	CameraZoom _current_camera;
	
	CCNode *_game_anchor;
	
	CGPoint _camera_center_point;
	
	BGSky *_bg_sky;
	BGWater *_bg_water;
	BGFog *_bg_fog;
	NSArray *_bg_elements;
	
	CCDrawNode *_heightRefrence;
	
	AccelerometerManager *_accel;
}

-(float)tick {
	return _tick;
}

-(CGPoint)touchPosition {
	return _touchPosition;
}

-(BOOL)touchDown {
	return _touchDown;
}

-(BOOL)touchTap {
	return _touchTap;
}

-(BOOL)touchRelease {
	return _touchRelease;
}

-(Player*)player { return _player; }

+(GameEngineScene*)cons {
	return [[GameEngineScene node] cons];
}

-(id)cons {
	self.userInteractionEnabled = YES;
	_accel = [AccelerometerManager cons];
	dt_unset();
	_current_camera = camerazoom_cons(0, 0, 0.1);
	
	_game_anchor = [[CCNode node] add_to:self];
	_player = (Player*)[[Player cons] add_to:_game_anchor z:1];
	_spirits = [NSMutableArray array];
	
	CCNode *bg_anchor = [[CCNode node] add_to:_game_anchor z:0];
	_bg_sky = (BGSky*)[[BGSky cons] add_to:bg_anchor z:0];
	_bg_water = (BGWater*)[[BGWater cons] add_to:bg_anchor z:0];
	_bg_fog = (BGFog*)[[BGFog cons] add_to:_game_anchor z:2];
	_bg_elements = @[_bg_sky,_bg_water];
	
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.delegate = self;
	accel.updateInterval = 1.0f/60.0f;
	
	_heightRefrence = [[CCDrawNode node] add_to:_game_anchor z:99];
	for(int i = 0; i < 400; i++){
		[_heightRefrence drawSegmentFrom:ccp(0, (i - 200) * 200) to: ccp(100, (i - 200) * 200) radius:1 color:[CCColor blackColor]];
	}
	
	return self;
}

-(void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler {
	[_accel accel_report_x:aceler.x y:aceler.y z:aceler.z];
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	
	_tick ++;//= dt_scale_get();
	
	if(fmodf(_tick, 40) == 0) {
		[self spawn_spirit];
	}
	
	[_accel i_update:self];
	[_player update_game:self];
	if(_player.position.y > 0) {
		_camY += (_player.position.y - 40 - _camY) * .2;
	} else {
		_camY += (_player.position.y + _player._vy * 10 - _camY) * .3;
	}
	[self center_camera_hei:_camY];
	
	for (BGElement *itr in _bg_elements) {
		[itr i_update:self];
	}
	
	for (SpiritBase *itr in _spirits) {
		[itr i_update_game:self manager:nil];
	}
	
	_touchTap = _touchRelease = false;
}

-(void)spawn_spirit {
	SpiritBasic *_new_spirit;
	_new_spirit = (SpiritBasic*)[[SpiritBasic cons_posX:100] add_to:_game_anchor z:0];
	[_new_spirit setPosition:ccp(100, -100)];
	[_spirits addObject:_new_spirit];
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

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touchTap = _touchDown = true;
	_touchPosition = [touch locationInWorld];
}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touchPosition = [touch locationInWorld];
}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touchRelease = true;
	_touchDown = false;
	_touchPosition = [touch locationInWorld];
}

@synthesize _playerState;
-(PlayerState)get_player_state {
	return _playerState;
}

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
