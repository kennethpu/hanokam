#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "BGSky.h" 
#import "BGWater.h"
#import "BGFog.h"
#import "BGReflection.h"
#import "SpiritBase.h"
#import "Spirit_Fish_1.h"
#import "Particle.h"
#import "RotateFadeOutParticle.h"
#import "ShaderManager.h"

#import "CCTexture_Private.h"

#import "AccelerometerManager.h"
//#import "AccelerometerSimulation.h"
#import "Resource.h"

@interface RippleInfo : NSObject
@end
@implementation RippleInfo {
	float _ct;
	CGPoint _pos;
}
-(id)initWithPosition:(CGPoint)pos game:(GameEngineScene*)game {
	self = [super init];
	_ct = 0;
	pos.y = (game.REFLECTION_HEIGHT - game.HORIZON_HEIGHT) + pos.y;
	float flip_axis = game.REFLECTION_HEIGHT - game.HORIZON_HEIGHT - 25;
	_pos = ccp(pos.x,flip_axis - (pos.y - flip_axis));
	return self;
}
-(void)render:(CCSprite*)proto {
	CGPoint pre = proto.position;
	[proto setPosition:_pos];
	[proto setScale:lerp(0.55, 1.5, _ct)];
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
	CGPoint _touch_position;
	BOOL _touch_down;
	BOOL _touch_tapped;
	BOOL _touch_released;
	
	float _tick;
	float _cam_y;
	float _cam_y_lirp;
	float _player_dive_bottom_y;
	float _player_combat_top_y;
	
	float _shake_rumble_time;
	float _shake_rumble_total_time;
	float _shake_rumble_distance;
	
	float _shake_rumble_slow_time;
	float _shake_rumble_slow_total_time;
	float _shake_rumble_slow_distance;

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
	
	CCRenderTexture *_reflection_texture;
	CCRenderTexture *_ripple_texture;
	CCSprite *_ripple_proto;
	NSMutableArray *_ripples;
	
	SpiritManager *_spirit_manager;
	
	NSMutableArray *_particles,*_particles_tba;
}

-(Player*)player { return _player; }
-(CCNode*)spirit_anchor { return _spirit_anchor; }
-(float)tick { return _tick; }
-(CGPoint)touch_position { return _touch_position; }
-(BOOL)touch_down { return _touch_down; }
-(BOOL)touch_tapped { return _touch_tapped; }
-(BOOL)touch_released { return _touch_released; }
-(float)get_camera_y { return -_game_anchor.position.y + game_screen().height / 2; }
-(SpiritManager*)get_spirit_manager{ return _spirit_manager; }

@synthesize _water_num;

@synthesize _player_state;
-(PlayerState)get_player_state {
	return _player_state;
}

+(GameEngineScene*)cons {
	return [[GameEngineScene node] cons];
}

-(float) REFLECTION_HEIGHT { return 250; }
-(float) HORIZON_HEIGHT { return 100; }

-(id)cons {
	self.userInteractionEnabled = YES;
	_particles = [NSMutableArray array];
	_particles_tba = [NSMutableArray array];
	_accel = [AccelerometerManager cons];
	dt_unset();
	_current_camera = camerazoom_cons(0, 0, 0.1);
	_shake_rumble_total_time = _shake_rumble_time = _shake_rumble_distance = 1;
	_shake_rumble_slow_total_time = _shake_rumble_slow_time = _shake_rumble_slow_distance = 1;
	
	_game_anchor = [[CCNode node] add_to:self];
	_spirit_anchor = [[CCNode node] add_to:_game_anchor z:1];
	
	_player = (Player*)[[Player cons] add_to:_game_anchor z:5];
	_player_state = PlayerState_WaveEnd;
	
	CCNode *bg_anchor = [[CCNode node] add_to:_game_anchor z:0];
	_bg_sky = (BGSky*)[[BGSky cons:self] add_to:bg_anchor z:1];
	_bg_water = (BGWater*)[[BGWater cons:self] add_to:bg_anchor z:-1];
	_bg_fog = (BGFog*)[[BGFog cons] add_to:_game_anchor z:10];
	_bg_elements = @[_bg_sky, _bg_water,_bg_fog];
	
	_spirit_manager = [[[SpiritManager alloc] init] cons:self];
	
	_water_text = label_cons(ccp(100, 300), ccc3(255, 255, 255), 25, @"");
	[_game_anchor addChild:_water_text z:99];
	_water_text.string = [NSString stringWithFormat:@"water %i", _water_num];
	
	_reflection_texture = [CCRenderTexture renderTextureWithWidth:game_screen().width height:self.REFLECTION_HEIGHT];
	[_reflection_texture setPosition:ccp(game_screen().width / 2, -(self.REFLECTION_HEIGHT) / 2 + self.HORIZON_HEIGHT)];
	_reflection_texture.scaleY = -1;
	[bg_anchor addChild:_reflection_texture z:0];
	_reflection_texture.sprite.blendMode = [CCBlendMode alphaMode];
	_reflection_texture.sprite.shader = [ShaderManager get_shader:SHADER_ALPHA_GRADIENT_MASK];
	_ripples = [NSMutableArray array];
	_ripple_texture = [CCRenderTexture renderTextureWithWidth:game_screen().width height:self.REFLECTION_HEIGHT];
	[_ripple_texture clear:0 g:0 b:0 a:0];
	_ripple_proto = [CCSprite spriteWithTexture:[Resource get_tex:TEX_RIPPLE]];
	_ripple_proto.shader = [ShaderManager get_shader:SHADER_RIPPLE_FX];
	_reflection_texture.sprite.shaderUniforms[@"rippleTexture"] = _ripple_texture.sprite.texture;
	
	
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.delegate = self;
	accel.updateInterval = 1.0f / 60.0f;
	
	_heightRefrence = (CCDrawNode*)[[CCDrawNode node] add_to:_game_anchor z:99];
	for(int i = 0; i < 400; i++){
		[_heightRefrence drawSegmentFrom:ccp(0, (i - 200) * 200) to: ccp(100, (i - 200) * 200) radius:1 color:[CCColor blackColor]];
	}
	
	return self;
}

-(void)add_ripple:(CGPoint)pos {
	[_ripples addObject:[[RippleInfo alloc] initWithPosition:pos game:self]];
}

-(void)render_ripple_texture {
	[_ripple_texture clear:0 g:0 b:0 a:0];
	[_ripple_texture begin];
	NSMutableArray *to_remove = [NSMutableArray array];
	for (RippleInfo *itr in _ripples) {
		if ([itr should_remove]) {
			[to_remove addObject:itr];
		} else {
			[itr render:_ripple_proto];
			[itr i_update];
		}
	}
	[_ripples removeObjectsInArray:to_remove];
	[_ripple_texture end];
}

-(void)render_reflection_texture {
	[_reflection_texture clear:0 g:0 b:0 a:0];
	[_reflection_texture begin];
	[_bg_sky render_reflection:self];
	
	if (_player.position.y > -10) {
		CGPoint player_pos = _player.position;
		_player.position = ccp(_player.position.x, self.HORIZON_HEIGHT + _player.position.y);
		[_player visit];
		_player.position = player_pos;
	}
	_spirit_anchor.position = ccp(0,self.HORIZON_HEIGHT);
	for (SpiritBase *itr in _spirit_manager.get_spirits) if (itr.position.y < 0) itr.visible = NO;
	[_spirit_anchor visit];
	for (SpiritBase *itr in _spirit_manager.get_spirits) itr.visible = YES;
	_spirit_anchor.position = CGPointZero;
	
	[_bg_fog visit];
	[_reflection_texture end];
}

-(void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler {
	[_accel accel_report_x:aceler.x y:aceler.y z:aceler.z];
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	
	_tick += dt_scale_get();
	
	[self render_ripple_texture];
	[self render_reflection_texture];
	[_accel i_update:self];
	[_player update_game:self];
	[self update_particles];
	
	switch(_player_state) {
		case PlayerState_Dive:
			if(self.touch_down == false) {
				if(_player.position.y > _player_dive_bottom_y + 200)
					_player_state = PlayerState_Return;
			}
			
			_player_dive_bottom_y = [self get_spirit_manager].dive_y - 200;
			
			_cam_y += (0 - _cam_y) * .1 * dt_scale_get();
			
			_cam_y_lirp += (_player_dive_bottom_y - _cam_y_lirp) * .06 * dt_scale_get();
		break;
		case PlayerState_Return:
			_cam_y_lirp += (_player.position.y + 100 - _cam_y_lirp) * .1 * dt_scale_get();
		break;
		case PlayerState_Combat:
			_cam_y += (-100 - _cam_y) * .2 * dt_scale_get();
			if(_player_combat_top_y < _player.position.y)
				_player_combat_top_y = _player.position.y;
			_player_combat_top_y += 3;
			
			if(_player.position.y < _player_combat_top_y - 340)
				_player_combat_top_y = _player.position.y + 340;
		break;
		case PlayerState_WaveEnd:
			_player_combat_top_y = 0;
			_cam_y += (130 - _cam_y) * .02 * dt_scale_get();
			//_cam_y_lirp += 100;
		break;
	}
	
	if(_player_state == PlayerState_Dive || _player_state == PlayerState_Return) {
		[self center_camera_hei:_cam_y_lirp];
	} else if (_player_state == PlayerState_Combat) {
		[self center_camera_hei:_player_combat_top_y + _cam_y];
	} else {
		[self center_camera_hei:_player.position.y + _cam_y];
	}
	for (BGElement *itr in _bg_elements) {
		[itr i_update:self];
	}
	
	[_spirit_manager i_update];
	
	// shake it baby
	if(_shake_rumble_time > 0)
		_shake_rumble_time -= dt_scale_get();
	else
		_shake_rumble_time = 0;
	
	float _rumble_dist = _shake_rumble_distance * (_shake_rumble_time / _shake_rumble_total_time);
	
	[_game_anchor setPosition:CGPointAdd(_game_anchor.position,ccp(sinf(_tick) * _rumble_dist, cosf(_tick) * _rumble_dist))];
	
	
	if(_shake_rumble_slow_time > 0)
		_shake_rumble_slow_time -= dt_scale_get();
	else
		_shake_rumble_slow_time = 0;
	
	float _rumble_slow_dist = _shake_rumble_slow_distance * (_shake_rumble_slow_time / _shake_rumble_slow_total_time);
	
	[_game_anchor setPosition:CGPointAdd(_game_anchor.position,ccp(sinf(_tick / 2) * _rumble_slow_dist / 2, cosf(_tick / 2) * _rumble_slow_dist))];
	_touch_tapped = _touch_released = false;
}

-(void)add_particle:(Particle*)p {
    [_particles_tba addObject:p];
}
-(void)update_particles {
    for (Particle *p in _particles_tba) {
        [_particles addObject:p];
        [_game_anchor addChild:p z:[p get_render_ord]];
    }
    [_particles_tba removeAllObjects];
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in _particles) {
        [i i_update:self];
        if ([i should_remove]) {
			[_game_anchor removeChild:i cleanup:YES];
            [toremove addObject:i];
        }
    }
    [_particles removeObjectsInArray:toremove];
}

-(void)center_camera_hei:(float)hei {
	CGPoint pt = ccp(game_screen().width / 2, hei);
	_camera_center_point = pt;
	CGSize s = [CCDirector sharedDirector].viewSize;
	CGPoint halfScreenSize = ccp(s.width / 2, s.height / 2);
	[_game_anchor setScale:1];
	[_game_anchor setPosition:CGPointAdd(
	 ccp(
		 clampf(halfScreenSize.x - pt.x, -999999, 999999) * [self scale],
		 clampf(halfScreenSize.y - pt.y, -999999, 999999) * [self scale]),
	 ccp(_current_camera.x, _current_camera.y))];
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

-(void)add_gameobject:(GameObject*)o{}
-(void)remove_gameobject:(GameObject*)o{}
-(void)set_target_camera:(CameraZoom)tar{}
-(void)shake_for:(float)ct distance:(float)distance{
	_shake_rumble_time = _shake_rumble_total_time = ct;
	_shake_rumble_distance = distance;
}

-(void)shake_slow_for:(float)ct distance:(float)distance{
	_shake_rumble_slow_time = _shake_rumble_slow_total_time = ct;
	_shake_rumble_slow_distance = distance;
}

-(void)freeze_frame:(int)ct{}
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(_camera_center_point.x-game_screen().width/2,_camera_center_point.y-game_screen().height/2,game_screen().width,game_screen().height); }

@end

@implementation BGElement
-(void)i_update:(GameEngineScene*)game{}
@end
