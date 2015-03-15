#import <Foundation/Foundation.h>

@interface DataStore : NSObject

+(void)cons;
+(BOOL)isset_key:(NSString*)key;
+(void)reset_key:(NSString*)key;
+(void)set_key:(NSString*)key int_value:(int)val;
+(int)get_int_for_key:(NSString*)key;
+(void)set_key:(NSString*)key flt_value:(float)val;
+(float)get_flt_for_key:(NSString*)key;
+(void)set_key:(NSString*)key str_value:(NSString*)val;
+(NSString*)get_str_for_key:(NSString*)key;
+(void)reset_all;

+(void)set_long_for_key:(NSString*)key long_value:(long)val;
+(long)get_long_for_key:(NSString*)key;

@end
