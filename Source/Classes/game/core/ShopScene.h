#import "cocos2d.h"
#import "Common.h"
@class GameObject;
@class Particle;
@class Player;

@interface ShopScene : CCScene <UIAccelerometerDelegate>
@property(readwrite,assign) int row_focussing;
+(ShopScene*)cons;

-(CGPoint)touch_position;
-(BOOL)touch_down;
-(BOOL)touch_tapped;
-(BOOL)touch_released;

@end
