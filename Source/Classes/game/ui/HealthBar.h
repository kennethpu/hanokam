#import "CCNode.h"

@interface HealthBar : CCNode
+(HealthBar*)cons_size:(CGSize)size anchor:(CGPoint)anchor;
-(void)set_pct:(float)pct;
@end
