varying float alphaGradient;
uniform sampler2D rippleTexture;

void main(){
	vec2 texCoord = cc_FragTexCoord1;
	
	float time = cc_Time[0];
	texCoord.x += 0.01 * (texCoord.y - 0.4) * sin(100.0 * texCoord.y + time * 3.0) + 0.05 * (texCoord.y - 0.5) * sin(25.0 * texCoord.y + time * 1.5);
	
	vec4 rippleValAtPos = texture2D(rippleTexture, cc_FragTexCoord1);
	texCoord.x += (rippleValAtPos.r - 0.5) * 0.15 * rippleValAtPos.a;
	texCoord.y += (rippleValAtPos.g - 0.5) * 0.15 * rippleValAtPos.a;
	
	vec4 textureColor = texture2D(cc_MainTexture, texCoord);
	
	gl_FragColor.r = textureColor.r;
	gl_FragColor.g = textureColor.g;
	gl_FragColor.b = textureColor.b;
	gl_FragColor.a = textureColor.a * alphaGradient * 0.8;
}