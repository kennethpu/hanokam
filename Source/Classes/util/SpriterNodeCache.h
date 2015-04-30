#import <Foundation/Foundation.h>
@class SpriterNode;
@interface SpriterNodeCache : NSObject

+(SpriterNodeCache*)cons;
-(void)precache;
-(SpriterNode*)depool_node_for_scml:(NSString*)scml json:(NSString*)json texture:(NSString*)texture;
-(void)repool_node:(SpriterNode*)node scml:(NSString*)scml json:(NSString*)json texture:(NSString*)texture;
@end
