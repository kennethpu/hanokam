#import "cocos2d.h"
#import "Common.h"
@class GameObject;
@class Particle;

@interface GameEngineScene : CCScene
+(GameEngineScene*)cons;

-(void)add_particle:(Particle*)p;
-(void)add_gameobject:(GameObject*)o;
-(void)remove_gameobject:(GameObject*)o;
-(void)set_target_camera:(CameraZoom)tar;
-(void)shake_for:(float)ct intensity:(float)intensity;
-(void)freeze_frame:(int)ct;
-(HitRect)get_viewbox;

@end
