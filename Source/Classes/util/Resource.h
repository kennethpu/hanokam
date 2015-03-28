#import "cocos2d.h"

@interface Resource : NSObject

+(void)load_all;
+(CCTexture*)get_tex:(NSString*)key;

#define TEX_BLANK @"blank"

#define TEX_TEST_BG_TILE_SKY @"bg_test_tile_sky"
#define TEX_TEST_BG_TILE_WATER @"bg_test_tile_water"
#define TEX_TEST_BG_UNDERWATER_SURFACE_GRADIENT @"bg_underwater_surface_gradient"

#define TEX_SPRITER_CHAR_HANOKATEST @"hanoka v0.01"
#define TEX_PARTICLES_SPRITESHEET @"particles_spritesheet"
#define TEX_RIPPLE @"ripple"
#define TEX_BG_SPRITESHEET_1 @"bg_spritesheet_1"
#define TEX_KELP_SPRITESHEET @"kelp_spritesheet"
#define TEX_HUD_SPRITESHEET @"hud_spritesheet"

#define TEX_ENEMIES_SPRITESHEET @"enemies_spritesheet"

//todo -- move below to spritesheets
#define TEX_SH_BUTTON_MIDDLE @"sh_button_middle"
#define TEX_SH_BUTTON_SIDE @"sh_button_side"
#define TEX_TEST_SH_ITEM @"sh_test_item"

#define TEX_AIMING_BAR @"aiming_bar"
#define TEX_PARTICLE_BLOOD_1 @"particle_blood_1"
#define TEX_PARTICLE_BUBBLE @"particle_bubble"
#define TEX_WATER_SHINE @"water_shine"
#define TEX_ARROW @"arrow"
#define TEX_TEST_BG_OBJ_BIRD @"bg_test_obj_bird"
#define TEX_TEST_BG_OBJ_CLOUD @"bg_test_obj_cloud"
#define TEX_SPIRIT_FISH_1 @"spirit_fish_1"
#define TEX_SPIRIT_FISH_2 @"spirit_fish_2"
#define TEX_SPIRIT_FISH_3 @"spirit_fish_3"

@end
