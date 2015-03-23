#import <Foundation/Foundation.h>
@class CCShader;

#define SHADER_RIPPLE_FX @"ripple_effect"
#define SHADER_ALPHA_GRADIENT_MASK @"alpha_gradient_mask"

@interface ShaderManager : NSObject
+(void)load_all;
+(CCShader*)get_shader:(NSString*)key;
@end
