#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "BGSky.h" 
#import "BGWater.h"
#import "BGFog.h"
#import "SpiritBase.h"
#import "Spirit_Fish_1.h"

#import "AccelerometerManager.h"
//#import "AccelerometerSimulation.h" 

#import "Resource.h"
#import "CCTexture_Private.h"

@implementation GameEngineScene {
	CGPoint _touch_position;
	BOOL _touch_down;
	BOOL _touch_tapped;
	BOOL _touch_released;
	
	float _tick;
	float _cam_y;
	float _cam_y_lirp;
	float _player_combat_top_y;

	Player *_player;
	
	CameraZoom _target_camera;
	CameraZoom _current_camera;
	
	CCNode *_game_anchor;
	CCNode *_spirit_anchor;
	
	CGPoint _camera_center_point;
	
	BGSky *_bg_sky;
	BGWater *_bg_water;
	BGFog *_bg_fog;
	NSArray *_bg_elements;
	
	CCDrawNode *_heightRefrence;
	
	AccelerometerManager *_accel;
	
	
	CCLabelTTF *_water_text;
}

-(Player*)player { return _player; }

-(CCNode*)spirit_anchor { return _spirit_anchor; }

-(float)tick {
	return _tick;
}

-(CGPoint)touch_position {
	return _touch_position;
}

-(BOOL)touch_down {
	return _touch_down;
}

-(BOOL)touch_tapped {
	return _touch_tapped;
}

-(BOOL)touch_released {
	return _touch_released;
}

@synthesize _water_num;

@synthesize _player_state;
-(PlayerState)get_player_state {
	return _player_state;
}

+(GameEngineScene*)cons {
	return [[GameEngineScene node] cons];
}

-(id)cons {
	self.userInteractionEnabled = YES;
	_accel = [AccelerometerManager cons];
	dt_unset();
	_current_camera = camerazoom_cons(0, 0, 0.1);
	
	_game_anchor = [[CCNode node] add_to:self];
	_spirit_anchor = [[CCNode node] add_to:_game_anchor z:1];
	
	_player = (Player*)[[Player cons] add_to:_game_anchor z:1];
	_player_state = PlayerState_WaveEnd;
	
	CCNode *bg_anchor = [[CCNode node] add_to:_game_anchor z:0];
	_bg_sky = (BGSky*)[[BGSky cons] add_to:bg_anchor z:0];
	_bg_water = (BGWater*)[[BGWater cons] add_to:bg_anchor z:0];
	_bg_fog = (BGFog*)[[BGFog cons] add_to:_game_anchor z:2];
	_bg_elements = @[_bg_sky, _bg_water];
	
	[SpiritManager cons:self];
	
	_water_text = label_cons(ccp(100, 300), ccc3(255, 255, 255), 25, @"");
	[_game_anchor addChild:_water_text z:99];
	_water_text.string = [NSString stringWithFormat:@"water %i", _water_num];
	
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
	
	_tick += dt_scale_get();
	
	
	[_accel i_update:self];
	[_player update_game:self];
	
	switch(_player_state) {
		case PlayerState_Dive:
			_cam_y += (_player._vy * 20 - 20 - _cam_y) * _cam_y_lirp * dt_scale_get();
			_cam_y_lirp += (.1 - _cam_y_lirp) * .1;
		break;
		case PlayerState_Return:
			_cam_y += (100 - _cam_y) * _cam_y_lirp * dt_scale_get();
			_cam_y_lirp += (.1 - _cam_y_lirp) * .1;
		break;
		case PlayerState_Combat:
			_cam_y += (-100 + _player._vy * 10 - _cam_y) * _cam_y_lirp * dt_scale_get();
			_cam_y_lirp += (.2 - _cam_y_lirp) * .1;
			if(_player_combat_top_y < _player.position.y)
				_player_combat_top_y = _player.position.y;
			
			if(_player.position.y < _player_combat_top_y - 300)
				_player_combat_top_y = _player.position.y + 300;
		break;
		case PlayerState_WaveEnd:
			_player_combat_top_y = 0;
			_cam_y += (130 - _cam_y) * _cam_y_lirp * dt_scale_get();
			_cam_y_lirp += (.02 - _cam_y_lirp) * .5;
		break;
	}
	if(_player_state == PlayerState_Combat) {
		[self center_camera_hei:_player_combat_top_y + _cam_y];
	} else {
		[self center_camera_hei:_player.position.y + _cam_y];
	}
	
	for (BGElement *itr in _bg_elements) {
		[itr i_update:self];
	}
	
	[SpiritManager i_update];
	
	_touch_tapped = _touch_released = false;
}

-(void)center_camera_hei:(float)hei {
	CGPoint pt = ccp(game_screen().width / 2, hei);
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
	_touch_tapped = _touch_down = true;
	_touch_position = [touch locationInWorld];
}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_position = [touch locationInWorld];
}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_released = true;
	_touch_down = false;
	_touch_position = [touch locationInWorld];
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
