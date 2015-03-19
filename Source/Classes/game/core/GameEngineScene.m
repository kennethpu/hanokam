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
	
	CCRenderTexture *_reflection_texture;
}

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
	_player_state = PlayerState_WaveEnd;
	_spirits = [NSMutableArray array];
	
	CCNode *bg_anchor = [[CCNode node] add_to:_game_anchor z:0];
	_bg_sky = (BGSky*)[[BGSky cons] add_to:bg_anchor z:0];
	_bg_water = (BGWater*)[[BGWater cons] add_to:bg_anchor z:0];
	_bg_fog = (BGFog*)[[BGFog cons] add_to:_game_anchor z:2];
	_bg_elements = @[_bg_sky, _bg_water];
	
	//
	
	/*
	[self center_camera_hei:0];
	for (BGElement *itr in _bg_elements) {
		[itr i_update:self];
	}
	*/
	
	float reflection_height = 150;
	_reflection_texture = [CCRenderTexture renderTextureWithWidth:game_screen().width height:reflection_height];
	[self render_reflection_texture];
	[_reflection_texture setPosition:ccp(game_screen().width/2,-(reflection_height)/2)];
	_reflection_texture.scaleY = -1;
	[_game_anchor addChild:_reflection_texture z:10];
	
	CCShader *shader = [CCShader shaderNamed:@"alpha_gradient_mask"];
	_reflection_texture.sprite.blendMode = [CCBlendMode alphaMode];
	_reflection_texture.sprite.shader = shader;
	
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.delegate = self;
	accel.updateInterval = 1.0f/60.0f;
	
	_heightRefrence = [[CCDrawNode node] add_to:_game_anchor z:99];
	for(int i = 0; i < 400; i++){
		[_heightRefrence drawSegmentFrom:ccp(0, (i - 200) * 200) to: ccp(100, (i - 200) * 200) radius:1 color:[CCColor blackColor]];
	}
	
	return self;
}

-(void)render_reflection_texture {
	[_reflection_texture clear:0 g:0 b:0 a:0];
	[_reflection_texture begin];
	[_bg_sky visit];
	[_bg_fog visit];
	[_player visit];
	[_reflection_texture end];
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
	
	[self render_reflection_texture];
	
	[_accel i_update:self];
	[_player update_game:self];
	
	switch(_player_state) {
		case PlayerState_Dive:
			_cam_y += (_player._vy * 20 - 50 - _cam_y) * _cam_y_lirp * dt_scale_get();
			_cam_y_lirp += (.1 - _cam_y_lirp) * .1;
		break;
		case PlayerState_Return:
			_cam_y += (150 - _cam_y) * _cam_y_lirp * dt_scale_get();
			_cam_y_lirp += (.1 - _cam_y_lirp) * .1;
		break;
		case PlayerState_Combat:
			_cam_y += (-100 + _player._vy * 10 - _cam_y) * _cam_y_lirp * dt_scale_get();
			_cam_y_lirp += (.2 - _cam_y_lirp) * .1;
			if(_player_combat_top_y < _player.position.y)
				_player_combat_top_y = _player.position.y;
		break;
		case PlayerState_WaveEnd:
			_player_combat_top_y = 0;
			_cam_y += (150 - _cam_y) * _cam_y_lirp * dt_scale_get();
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
	
	for (SpiritBase *itr in _spirits) {
		[itr i_update_game:self];
	}
	
	_touch_tapped = _touch_released = false;
}

-(void)spawn_spirit {
	SpiritBasic *_new_spirit;
	_new_spirit = (SpiritBasic*)[[SpiritBasic cons_pos_x:100] add_to:_game_anchor z:0];
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

@synthesize _player_state;
-(PlayerState)get_player_state {
	return _player_state;
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
