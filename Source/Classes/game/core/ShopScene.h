#import "cocos2d.h"
#import "Common.h"
@class GameObject;
@class Particle;
@class Player;

@interface ShopScene : CCScene <UIAccelerometerDelegate>
+(ShopScene*)cons;

-(Player*)player;

-(void)add_particle:(Particle*)p;
-(void)add_gameobject:(GameObject*)o;
-(void)remove_gameobject:(GameObject*)o;
-(void)shake_for:(float)ct intensity:(float)intensity;
-(HitRect)get_viewbox;
@end
