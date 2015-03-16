#import "cocos2d.h"

@interface Resource : NSObject

+(void)load_all;
+(CCTexture*)get_tex:(NSString*)key;

#define TEX_BLANK @"blank"

#define TEX_TEST_BG_TILE_SKY @"bg_test_tile_sky"
#define TEX_TEST_BG_TILE_WATER @"bg_test_tile_water"
#define TEX_TEST_BG_BLDG1 @"bg_test_bldg1"
#define TEX_TEST_BG_BLDG2 @"bg_test_bldg2"
#define TEX_TEST_BG_FOG @"bg_test_fog"
#define TEX_TEST_BG_OBJ_BIRD @"bg_test_obj_bird"
#define TEX_TEST_BG_OBJ_CLOUD @"bg_test_obj_cloud"

#define TEX_TEST_CHAR_HANOKA @"bg_test_hanoka"

@end
