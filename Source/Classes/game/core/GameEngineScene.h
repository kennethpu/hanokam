#import "cocos2d.h"
#import "Common.h"
@class GameObject;
@class Particle;
@class Player;
@class SpiritManager;
@class BGSky;
@class AirEnemyManager;

typedef enum _PlayerState {
	PlayerState_Dive = 0,
	PlayerState_DiveReturn = 1,
	PlayerState_InAir = 2,
	PlayerState_OnGround = 3,
	PlayerState_AirToGroundTransition = 4
} PlayerState;

typedef enum _GameAnchorZ {
	GameAnchorZ_BGSky_SurfaceReflection = 100,
	GameAnchorZ_Enemies_Air = 81,
	GameAnchorZ_BGSky_SurfaceGradient = 80,
	GameAnchorZ_Player_Out = 79,
	GameAnchorZ_BGSky_Docks_Pillars_Front = 52,
	GameAnchorZ_Player = 51,
	GameAnchorZ_BGSky_Docks = 13,
	GameAnchorZ_BGSky_Elements = 12,
	GameAnchorZ_BGWater_Reflection = 11,
	GameAnchorZ_BGSky_WaterLights = 10,
	//GameAnchorZ_Player_Underwater = 9,
	GameAnchorZ_Enemies_Underwater = 8,
	GameAnchorZ_BGWater_I1 = 7,
	GameAnchorZ_BGSky_BackgroundElements = 6,
	GameAnchorZ_BGSky_RepeatBG = 5,
	GameAnchorZ_BGWater_Ground = 4,
	GameAnchorZ_BGWater_RepeatBG = 3
} GameAnchorZ;

@interface RippleInfo : NSObject
-(void)render_reflected:(CCSprite*)proto offset:(CGPoint)offset scymult:(float)scymult;
-(void)render_default:(CCSprite*)proto offset:(CGPoint)offset scymult:(float)scymult;
@end

@interface GameEngineScene : CCScene <UIAccelerometerDelegate>
@property(readwrite,assign) PlayerState _player_state;
//@property(readwrite,assign) int _water_num;

+(GameEngineScene*)cons;

-(Player*)player;

-(void)add_particle:(Particle*)p;
-(void)shake_for:(float)ct distance:(float)distance;
-(void)shake_slow_for:(float)ct distance:(float)distance;
-(void)freeze_frame:(int)ct;

-(float) tick;
-(CGPoint)touch_position;
-(BOOL)touch_down;
-(BOOL)touch_tapped;
-(BOOL)touch_released;
-(float)get_camera_y;
-(void)center_camera_hei:(float)hei;

-(PlayerState)get_player_state;
-(HitRect)get_viewbox;
-(CGPoint)camera_center_point;
-(CCNode*)get_anchor;
-(SpiritManager*)get_spirit_manager;
-(AirEnemyManager*)get_air_enemy_manager;

-(void)add_ripple:(CGPoint)pos;
-(float)get_ground_depth;
-(void)set_zoom:(float)val;
-(float)zoom;
-(float)player_combat_top_y;

-(float) REFLECTION_HEIGHT;
-(float) HORIZON_HEIGHT;
-(float) DOCK_HEIGHT;

-(NSNumber*)get_tick_mod_pi;
-(NSArray*)get_ripple_infos;
-(CCSprite*)get_ripple_proto;
-(BGSky*)get_bg_sky;
-(float)get_cam_y_lirp_current;
@end

@interface BGElement : NSObject
-(void)i_update:(GameEngineScene*)game;
@end
