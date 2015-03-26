#import "cocos2d.h"

@interface TouchTrackingLayer : CCNode
-(void)touch_begin:(CGPoint)pt;
-(void)touch_move:(CGPoint)pt;
-(void)touch_end:(CGPoint)pt;
@end
