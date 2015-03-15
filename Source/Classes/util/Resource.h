#import "cocos2d.h"

@interface Resource : NSObject

+(void)load_all;
+(CCTexture*)get_tex:(NSString*)key;

#define TEX_BLANK @"blank"

#define TEX_TEST_BG_TILE_SKY @"bg_test_tile_sky"
#define TEX_TEST_BG_TILE_WATER @"bg_test_tile_water"
#define TEX_TEST_CHAR_HANOKA @"bg_test_hanoka"

@end
