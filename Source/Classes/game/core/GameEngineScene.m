#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "BGSky.h" 
#import "BGWater.h"
#import "BGReflection.h"
#import "SpiritBase.h"
#import "Spirit_Fish_1.h"
#import "Particle.h"
#import "ParticlePhysical.h"
#import "RotateFadeOutParticle.h"
#import "ShaderManager.h"
#import "GameUI.h"
#import "Particle.h"
#import "TouchTrackingLayer.h"
#import "AirEnemyManager.h"
#import "Arrow.h" 

#import "CCTexture_Private.h"

#import "AccelerometerSimulation.h" 

#import "ControlManager.h"
#import "Resource.h"

@implementation RippleInfo {
	float _ct;
	CGPoint _reflected_pos;
	CGPoint _default_pos;
}

-(id)initWithPosition:(CGPoint)pos game:(GameEngineScene*)game {
	self = [super init];
	_ct = 0;
	_default_pos = pos;
	pos.y = (game.REFLECTION_HEIGHT - game.HORIZON_HEIGHT) + pos.y;
	float flip_axis = game.REFLECTION_HEIGHT - game.HORIZON_HEIGHT - 10;
	_reflected_pos = ccp(pos.x,flip_axis - (pos.y - flip_axis));
	return self;
}

-(void)render_reflected:(CCSprite*)proto offset:(CGPoint)offset scymult:(float)scymult {
	[self render:proto pos:CGPointAdd(_reflected_pos,offset) scymult:scymult];
}
-(void)render_default:(CCSprite*)proto offset:(CGPoint)offset scymult:(float)scymult {
	[self render:proto pos:CGPointAdd(_default_pos, offset) scymult:scymult];
}
-(void)render:(CCSprite*)proto pos:(CGPoint)pos scymult:(float)scymult {
	CGPoint pre = proto.position;
	[proto setPosition:pos];
	[proto setScale:lerp(0.55, 1.5, _ct)];
	[proto setScaleY:proto.scale*scymult];
	[proto setOpacity:lerp(1.0, 0, _ct)];
	[proto visit];
	proto.position = pre;
}

-(void)i_update {
	_ct += 0.015 * dt_scale_get();
}

-(BOOL)should_remove {
	return _ct >= 1.0;
}

@end

@implementation GameEngineScene {

	// UTILS
	float _tick;
	
	CGPoint _touch_position;
	BOOL _touch_down, _touch_tapped, _touch_released;
	
	ControlManager *_controls;
	
	// EFFECTS
	float _shake_rumble_time, _shake_rumble_total_time, _shake_rumble_distance;
	float _shake_rumble_slow_time, _shake_rumble_slow_total_time, _shake_rumble_slow_distance;
	float _freeze;
	
	
	ParticleSystem *_particles;
	
	CCSprite *_ripple_proto;
	NSMutableArray *_ripples;
	
	// CAM
	float _cam_y_lirp, _player_dive_bottom_y, _player_combat_top_y;
	CCNode *_zoom_node, *_game_anchor;
	float _zoom;
	CGPoint _camera_center_point;
	
	// WORLD
	Player *_player;
	ParticleSystem *_player_projectiles;
	
	BGSky *_bg_sky;
	BGWater *_bg_water;
	NSArray *_bg_elements;
	
	SpiritManager *_spirit_manager;
	AirEnemyManager *_air_enemy_manager;
	
	// GUI
	CCLabelTTF *_water_text;
	GameUI *_ui;
	
	TouchTrackingLayer *_touch_tracking;
}

-(Player*)player { return _player; }
-(float)tick { return _tick; }
-(CGPoint)touch_position { return _touch_position; }
-(BOOL)touch_down { return _touch_down; }
-(BOOL)touch_tapped { return _touch_tapped; }
-(BOOL)touch_released { return _touch_released; }
-(float)get_camera_y { return -_game_anchor.position.y; }
-(SpiritManager*)get_spirit_manager{ return _spirit_manager; }
-(AirEnemyManager*)get_air_enemy_manager { return _air_enemy_manager; }
-(ControlManager*)get_control_manager { return _controls; }

@synthesize _player_state;
-(PlayerState)get_player_state {
	return _player_state;
}

+(GameEngineScene*)cons {
	return [[GameEngineScene node] cons];
}

-(float) REFLECTION_HEIGHT { return 250; }
-(float) HORIZON_HEIGHT { return 100; }
-(float) DOCK_HEIGHT { return 48; }

-(id)cons {
	self.userInteractionEnabled = YES;
	_controls = [ControlManager cons];
	dt_unset();
	
	_touch_tracking = [TouchTrackingLayer node];
	[super addChild:_touch_tracking z:99];
	
	_shake_rumble_total_time = _shake_rumble_time = _shake_rumble_distance = 1;
	_shake_rumble_slow_total_time = _shake_rumble_slow_time = _shake_rumble_slow_distance = 1;
	
	_zoom_node = [CCNode node];
	[super addChild:_zoom_node];
	[_zoom_node setPosition:game_screen_pct(.5, .5)];
	
	_game_anchor = [[CCNode node] add_to:_zoom_node];
	
	_particles = [ParticleSystem cons_anchor:_game_anchor];
	_player_projectiles = [ParticleSystem cons_anchor:_game_anchor];
	
	_player = (Player*)[[Player cons] add_to:_game_anchor z:GameAnchorZ_Player];
	_player_state = PlayerState_OnGround;
	
	_ripples = [NSMutableArray array];
	_ripple_proto = [CCSprite spriteWithTexture:[Resource get_tex:TEX_RIPPLE]];
	_ripple_proto.shader = [ShaderManager get_shader:SHADER_RIPPLE_FX];
	
	_bg_sky = [BGSky cons:self];
	_bg_water = [BGWater cons:self];
	_bg_elements = @[_bg_sky, _bg_water];
	
	_spirit_manager = [[[SpiritManager alloc] init] cons:self];
	_air_enemy_manager = [AirEnemyManager cons:self];
	
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.delegate = self;
	accel.updateInterval = 1.0f / 60.0f;
	
	_ui = [GameUI cons:self];
	[super addChild:_ui z:2];
	
	[self update:0];
	
	return self;
}

-(void)add_player_projectile:(PlayerProjectile*)tar {
	[_player_projectiles add_particle:tar];
}

-(void)addChild:(CCNode *)node { [NSException raise:@"Do not add children to GameEngineScene" format:@""]; }
-(NSArray*)get_ripple_infos { return _ripples; }
-(CCSprite*)get_ripple_proto { return _ripple_proto; }
-(NSNumber*)get_tick_mod_pi { return @(fmodf(_tick * 0.01,M_PI * 2)); }
-(BGSky*)get_bg_sky { return _bg_sky; }
-(float)get_cam_y_lirp_current { return _cam_y_lirp; }

-(void)add_ripple:(CGPoint)pos {
	if ([_ripples count] > 6) return;
	[_ripples addObject:[[RippleInfo alloc] initWithPosition:pos game:self]];
}

-(void)update_ripples {
	NSMutableArray *to_remove = [NSMutableArray array];
	for (RippleInfo *itr in _ripples) {
		if ([itr should_remove]) {
			[to_remove addObject:itr];
		} else {
			[itr i_update];
		}
	}
	[_ripples removeObjectsInArray:to_remove];
}

-(void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler {
	[_controls accel_report_x:aceler.x y:aceler.y z:aceler.z];
}

static bool TEST_HAS_ACTIVATED_BOSS = false;
-(void)update:(CCTime)delta {
	dt_set(delta);
	if (!TEST_HAS_ACTIVATED_BOSS && _player.position.y <= self.get_ground_depth + 50) {
		TEST_HAS_ACTIVATED_BOSS = YES;
		[_ui start_boss:@"Big Bad Boss" sub:@"This guy mad."];
	}
	
	_tick += dt_scale_get();
	
	[self update_shake];
	
	if(_freeze > 0) {
		_freeze -= dt_scale_get();
		return;
	}
	
	[_controls i_update:self];
	[_player update_game:self];
	[_particles update_particles:self];
	[_player_projectiles update_particles:self];
	
	// CAMERA
	switch(_player_state) {
		case PlayerState_Dive:
			if(self.touch_down == false) {
				if(_player.position.y > _player_dive_bottom_y + 200)
					_player_state = PlayerState_DiveReturn;
			}
			
			_player_dive_bottom_y = [self get_spirit_manager].dive_y - 200;
			
			_cam_y_lirp += (_player_dive_bottom_y - _cam_y_lirp) * .06 * dt_scale_get();
			[self center_camera_hei:_cam_y_lirp];
			
		break;
		case PlayerState_DiveReturn:
			_cam_y_lirp += (_player.position.y + 100 - _cam_y_lirp) * .1 * dt_scale_get();
			[self center_camera_hei:_cam_y_lirp];
			
		break;
		case PlayerState_InAir:
			_cam_y_lirp = _camera_center_point.y;
			break;
		case PlayerState_AirToGroundTransition:
			_cam_y_lirp = _camera_center_point.y;
			break;
			
		case PlayerState_OnGround:
			_player_combat_top_y = 0;
			_cam_y_lirp += (150 - _cam_y_lirp) * .05 * dt_scale_get();
			[self center_camera_hei:_cam_y_lirp];
			
		break;
	}
	
	for (BGElement *itr in _bg_elements) {
		[itr i_update:self];
	}
	
	[_spirit_manager i_update];
	[_air_enemy_manager i_update:self];
	[self update_ripples];
	
	_touch_tapped = _touch_released = false;
	[_ui i_update:self];
}

-(void)update_shake {
	[_zoom_node setPosition:game_screen_pct(.5, .5)];

	if(_shake_rumble_time > 0)
		_shake_rumble_time -= dt_scale_get();
	else
		_shake_rumble_time = 0;
	
	float _rumble_dist = _shake_rumble_distance * (_shake_rumble_time / _shake_rumble_total_time);
	
	[_zoom_node setPosition:CGPointAdd(_zoom_node.position, ccp(sinf(_tick * 1.2) * _rumble_dist, cosf(_tick * 1.2) * _rumble_dist))];
	
	
	if(_shake_rumble_slow_time > 0)
		_shake_rumble_slow_time -= dt_scale_get();
	else
		_shake_rumble_slow_time = 0;
	
	float _rumble_slow_dist = _shake_rumble_slow_distance * (_shake_rumble_slow_time / _shake_rumble_slow_total_time);
	
	[_zoom_node setPosition:CGPointAdd(_zoom_node.position, ccp(sinf(_tick / 3) * _rumble_slow_dist / 2, cosf(_tick / 3) * _rumble_slow_dist))];
}

-(void)set_zoom:(float)val {
	[_zoom_node setScale:clampf(val, 1, INFINITY)];
	_zoom = val;
}

-(float)player_combat_top_y { return _player_combat_top_y; }

-(float)zoom {return _zoom;}

-(float)get_ground_depth {
	return -2000;
}

-(void)add_particle:(Particle*)p {
	[_particles add_particle:p];
}

-(void)center_camera_hei:(float)hei {
	CGPoint pt = ccp(game_screen().width / 2, hei);
	_camera_center_point = pt;
	CGSize s = [CCDirector sharedDirector].viewSize;
	[_game_anchor setScale:1];
	CGPoint halfScreenSize = ccp(s.width / 2, s.height / 2);
	[_game_anchor setPosition:CGPointAdd(
		game_screen_pct(-.5, -.5),
	ccp(
		 halfScreenSize.x - pt.x,
		 halfScreenSize.y - pt.y
	))];
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_tapped = _touch_down = true;
	_touch_position = [touch locationInWorld];
	[_touch_tracking touch_begin:_touch_position];
	[_controls touch_begin:_touch_position];
}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_position = [touch locationInWorld];
	[_touch_tracking touch_move:_touch_position];
	[_controls touch_move:_touch_position];
}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_released = true;
	_touch_down = false;
	_touch_position = [touch locationInWorld];
	[_touch_tracking touch_end:_touch_position];
	[_controls touch_end:_touch_position];
}

-(void)shake_for:(float)ct distance:(float)distance{
	_shake_rumble_time = _shake_rumble_total_time = ct;
	_shake_rumble_distance = distance;
}

-(void)shake_slow_for:(float)ct distance:(float)distance{
	_shake_rumble_slow_time = _shake_rumble_slow_total_time = ct;
	_shake_rumble_slow_distance = distance;
}

-(void)freeze_frame:(int)ct{
	_freeze = ct;
}
-(HitRect)get_viewbox{return hitrect_cons_xy_widhei(_camera_center_point.x - game_screen().width / 2, _camera_center_point.y - game_screen().height / 2, game_screen().width, game_screen().height); }
-(CGPoint)camera_center_point { return _camera_center_point; }
-(CCNode*)get_anchor { return _game_anchor; }
-(BOOL)fullScreenTouch { return YES; }
@end

@implementation BGElement
-(void)i_update:(GameEngineScene*)game{}
@end
