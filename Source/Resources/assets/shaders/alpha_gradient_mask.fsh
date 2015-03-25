varying float alphaGradient;
uniform sampler2D rippleTexture;
uniform float testTime;

void main(){
	vec2 texCoord = cc_FragTexCoord1;
	
	float time = cc_Time[0];
	texCoord.x += 0.002 * cos(testTime * 4.0 + 50.0 / (texCoord.y + .1)) * texCoord.y;
	texCoord.y += 0.03 * sin(testTime * 4.0 + 50.0 / (texCoord.y + .1)) * texCoord.y;
	vec4 rippleValAtPos = texture2D(rippleTexture, cc_FragTexCoord1);
	texCoord.x += (rippleValAtPos.r - 0.5) * 0.3 * rippleValAtPos.a;
	texCoord.y += (rippleValAtPos.g - 0.5) * 0.3 * rippleValAtPos.a;
	
	vec4 textureColor = texture2D(cc_MainTexture, texCoord);
	
	gl_FragColor.r = textureColor.r * .7;
	gl_FragColor.g = textureColor.g * 1.15;
	gl_FragColor.b = textureColor.b * 1.3;
	gl_FragColor.a = textureColor.a * alphaGradient * 0.8;
	
}