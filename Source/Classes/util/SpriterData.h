#import "CCNode.h"

@class TGSpriterAnimation;
@class TGSpriterFile;

@interface SpriterData : NSObject

+(SpriterData*)dataFromSpriteSheet:(CCTexture*)spriteSheet json:(NSString*)json scml:(NSString*)scml;

-(NSDictionary*)folders;
-(NSDictionary*)animations;
-(NSArray*)bones;
-(CCTexture*)texture;

-(TGSpriterAnimation*)anim_of_name:(NSString*)name;
-(TGSpriterFile*)file_for_folderid:(int)folderid fileid:(int)fileid;

@end
