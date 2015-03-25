#import "ShaderManager.h"
#import "cocos2d.h"

@implementation ShaderManager

static NSDictionary *_shader_cache;

+(void)load_all {
	_shader_cache = @{
		SHADER_REFLECTION_AM_DOWN: [CCShader shaderNamed:SHADER_REFLECTION_AM_DOWN],
		SHADER_RIPPLE_FX : [CCShader shaderNamed:SHADER_RIPPLE_FX],
		SHADER_ABOVEWATER_AM_UP : [CCShader shaderNamed:SHADER_ABOVEWATER_AM_UP]
	};
}

+(CCShader*)get_shader:(NSString*)key {
	return [_shader_cache objectForKey:key];
}

@end
