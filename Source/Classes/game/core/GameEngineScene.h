#import "cocos2d.h"
#import "Common.h"
@class GameObject;
@class Particle;
@class Player;
@class SpiritManager;

typedef enum _PlayerState {
	PlayerState_Dive = 0,
	PlayerState_Return = 1,
	PlayerState_Combat = 2,
	PlayerState_WaveEnd = 3
} PlayerState;

@interface GameEngineScene : CCScene <UIAccelerometerDelegate>
@property(readwrite,assign) int _player_state;
@property(readwrite,assign) int _water_num;

+(GameEngineScene*)cons;

-(Player*)player;
-(CCNode*)spirit_anchor;

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

-(PlayerState)get_player_state;
-(HitRect)get_viewbox;
-(CCNode*)get_anchor;
-(SpiritManager*)get_spirit_manager;

-(void)add_ripple:(CGPoint)pos;
-(float)get_ground_depth;
-(void)set_zoom:(float)val;
-(float)zoom;
-(float)player_combat_top_y;

-(float) REFLECTION_HEIGHT;
-(float) HORIZON_HEIGHT;

-(CCTexture*)get_ripple_texture;
-(NSNumber*)get_tick_mod_pi;
-(CCNode*)get_bg_anchor;
@end

@interface BGElement : CCNode
-(void)i_update:(GameEngineScene*)game;
@end
