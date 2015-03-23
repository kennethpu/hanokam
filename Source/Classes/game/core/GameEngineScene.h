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
-(void)add_gameobject:(GameObject*)o;
-(void)remove_gameobject:(GameObject*)o;
-(void)set_target_camera:(CameraZoom)tar;
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

-(SpiritManager*)get_spirit_manager;

-(void)add_ripple:(CGPoint)pos;

-(float) REFLECTION_HEIGHT;
-(float) HORIZON_HEIGHT;
@end

@interface BGElement : CCNode
-(void)i_update:(GameEngineScene*)game;
@end
