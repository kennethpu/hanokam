#import "CCNode.h"
@class SpriterData;
@interface SpriterNode : CCNode
+(SpriterNode*)nodeFromData:(SpriterData*)data;
-(void)playAnim:(NSString*)anim repeat:(BOOL)repeat;
-(BOOL)current_anim_repeating;
-(BOOL)current_anim_finished;

-(void)p_play_anim:(NSString*)anim repeat:(BOOL)repeat;
-(void)p_play_anim:(NSString*)anim1 on_finish_anim:(NSString*)anim2;
@end
