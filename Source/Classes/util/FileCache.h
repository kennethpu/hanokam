#import <Foundation/Foundation.h>

@class SpriterJSONParser;
@class SpriterData;
@interface FileCache : NSObject

+(void)precache_files;
+(CGRect)get_cgrect_from_plist:(NSString*)file idname:(NSString*)idname;

//+(SpriterJSONParser*)spriter_json_from_file:(NSString*)file;
+(SpriterData*)spriter_scml_data_from_file:(NSString*)file json:(NSString*)json texture:(CCTexture*)texture;
@end
