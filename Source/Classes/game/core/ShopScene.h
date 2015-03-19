#import "cocos2d.h"
#import "Common.h"
@class GameObject;
@class Particle;
@class Player;

@interface ShopScene : CCScene <UIAccelerometerDelegate>
@property(readwrite,assign) int rowFocus;
+(ShopScene*)cons;

-(CGPoint)touchPosition;
-(BOOL)touchDown;
-(BOOL)touchTap;
-(BOOL)touchRelease;

@end
