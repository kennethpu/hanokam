#import "cocos2d.h"
#import "Common.h"
@class GameObject;
@class Particle;
@class Player;

typedef enum _PlayerState {
	PlayerState_Dive = 0,
	PlayerState_Return = 1,
	PlayerState_Combat = 2,
	PlayerState_WaveEnd = 3

} PlayerState;

@interface GameEngineScene : CCScene <UIAccelerometerDelegate>
@property(readwrite,assign) int _playerState;

+(GameEngineScene*)cons;

-(Player*)player;

-(void)add_particle:(Particle*)p;
-(void)add_gameobject:(GameObject*)o;
-(void)remove_gameobject:(GameObject*)o;
-(void)set_target_camera:(CameraZoom)tar;
-(void)shake_for:(float)ct intensity:(float)intensity;
-(void)freeze_frame:(int)ct;

-(float) tick;
-(CGPoint)touchPosition;
-(BOOL)touchDown;
-(BOOL)touchTap;
-(BOOL)touchRelease;

-(PlayerState)get_player_state;

-(HitRect)get_viewbox;
@end

@interface BGElement : CCNode
-(void)i_update:(GameEngineScene*)game;
@end
