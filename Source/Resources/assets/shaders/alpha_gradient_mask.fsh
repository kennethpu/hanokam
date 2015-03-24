varying float alphaGradient;
uniform sampler2D rippleTexture;

void main(){
	vec2 texCoord = cc_FragTexCoord1;
	
	float time = cc_Time[0];
	//texCoord.x += 0.01 * (texCoord.y - 0.4) * sin(100.0 * texCoord.y + time * 3.0) + 0.05 * (texCoord.y - 0.5) * sin(25.0 * texCoord.y + time * 1.5);
	
	/*
	float base_y = (texCoord.y - 20);
	if(base_y < 0) {
		base_y = 0;
	}
	base_y = base_y * 2;
	*/
	
	//base_y = texCoord.y;
	
	texCoord.x += 0.01 * cos(-time * 1.2 + 5.0 * texCoord.y) * texCoord.y;
	texCoord.y += 0.03 * sin(time * 4.0 + 50.0 / (texCoord.y + .1)) * texCoord.y;
	
	vec4 rippleValAtPos = texture2D(rippleTexture, cc_FragTexCoord1);
	texCoord.x += (rippleValAtPos.r - 0.5) * 0.3 * rippleValAtPos.a;
	texCoord.y += (rippleValAtPos.g - 0.5) * 0.3 * rippleValAtPos.a;
	
	vec4 textureColor = texture2D(cc_MainTexture, texCoord);
	
	gl_FragColor.r = textureColor.r * .9;
	gl_FragColor.g = textureColor.g * 1.2;
	gl_FragColor.b = textureColor.b * 1.3;
	gl_FragColor.a = textureColor.a * alphaGradient * 0.8;
	
}