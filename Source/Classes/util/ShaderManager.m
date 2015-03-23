#import "ShaderManager.h"
#import "cocos2d.h"

@implementation ShaderManager

static NSDictionary *_shader_cache;

+(void)load_all {
	_shader_cache = @{
		SHADER_ALPHA_GRADIENT_MASK: [CCShader shaderNamed:SHADER_ALPHA_GRADIENT_MASK],
		SHADER_RIPPLE_FX : [CCShader shaderNamed:SHADER_RIPPLE_FX]
	};
}

+(CCShader*)get_shader:(NSString*)key {
	return [_shader_cache objectForKey:key];
}

@end
