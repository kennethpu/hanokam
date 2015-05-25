#import "cocos2d.h"

@interface Resource : NSObject

+(void)load_all;
+(CCTexture*)get_tex:(NSString*)key;

#define TEX_BLANK @"blank"

#define TEX_BG_SPRITESHEET_1 @"bg_spritesheet_1"
#define TEX_BG_UNDERWATER_SPRITESHEET @"underwater_spritesheet"
#define TEX_BG_SKY_SPRITESHEET @"sky_spritesheet"
#define TEX_BG_WATER_ELEMENT_FADE @"bg_water_element_fade"

#define TEX_TEST_BG_TILE_SKY @"bg_test_tile_sky"
#define TEX_TEST_BG_TILE_WATER @"bg_test_tile_water"
#define TEX_TEST_BG_UNDERWATER_SURFACE_GRADIENT @"bg_underwater_surface_gradient"

#define TEX_SPRITER_CHAR_HANOKA_V2 @"hanokav2"

#define TEX_SPRITER_CHAR_OLDMAN @"oldman_ss"
#define TEX_SPRITER_CHAR_VILLAGER_FISHWOMAN @"villager_fishwoman"

#define TEX_ENEMY_PUFFER @"puffer_enemy_ss"
#define TEX_SPRITER_TEST @"spriter_test"

#define TEX_PARTICLES_SPRITESHEET @"particles_spritesheet"
#define TEX_RIPPLE @"ripple"
#define TEX_HUD_SPRITESHEET @"hud_spritesheet"

//todo -- move below to spritesheets
#define TEX_SH_BUTTON_MIDDLE @"sh_button_middle"
#define TEX_SH_BUTTON_SIDE @"sh_button_side"
#define TEX_TEST_SH_ITEM @"sh_test_item"


@end
