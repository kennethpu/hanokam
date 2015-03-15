#import "CCSprite.h"
#import "Common.h"

@interface BatchDraw : CCSprite

+(void)cons;
+(void)add:(GLRenderObject*)gl key:(GLuint)tex z_ord:(int)ord draw_ord:(int)dord;
+(void)clear;
+(void)sort_jobs;

@end
