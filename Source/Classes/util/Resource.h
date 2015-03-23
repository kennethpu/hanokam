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
#define TEX_SH_BUTTON_MIDDLE @"sh_button_middle"
#define TEX_SH_BUTTON_SIDE @"sh_button_side"
#define TEX_TEST_SH_ITEM @"sh_test_item"

#define TEX_SPIRIT_FISH_1 @"spirit_fish_1"
#define TEX_SPIRIT_FISH_2 @"spirit_fish_2"
#define TEX_SPIRIT_FISH_3 @"spirit_fish_3"

#define TEX_SPRITER_CHAR_HANOKATEST @"hanoka v0.01"

#define TEX_PARTICLE_BLOOD_1 @"particle_blood_1"

#define TEX_ARROW @"arrow"
#define TEX_RIPPLE @"ripple"

@end
