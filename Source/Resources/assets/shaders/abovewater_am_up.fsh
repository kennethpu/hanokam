varying float alphaGradient;
uniform sampler2D rippleTexture;
uniform float testTime;

void main(){
	vec2 texCoord = cc_FragTexCoord1;
	float itexCoordy = 1.-texCoord.y;
	
	texCoord.x += 0.002 * cos(testTime * 4.0 + 50.0 / (texCoord.y + .45)) * itexCoordy;
	texCoord.y += 0.03 * sin(testTime * 4.0 + 50.0 / (texCoord.y + .45)) * itexCoordy;
	vec4 rippleValAtPos = texture2D(rippleTexture, cc_FragTexCoord1);
	texCoord.x += (rippleValAtPos.r - 0.5) * 0.3 * rippleValAtPos.a;
	texCoord.y += (rippleValAtPos.g - 0.5) * 0.3 * rippleValAtPos.a;
	
	vec4 textureColor = texture2D(cc_MainTexture, texCoord);
	
	gl_FragColor.r = textureColor.r * 1.;
	gl_FragColor.g = textureColor.g * 1.;
	gl_FragColor.b = textureColor.b * 1.;
	gl_FragColor.a = textureColor.a * (1.-alphaGradient) * 0.5;
	
}