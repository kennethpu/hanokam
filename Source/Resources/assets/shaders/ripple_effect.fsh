void main(){
	vec2 texCoord = cc_FragTexCoord1;
	vec4 textureColor = texture2D(cc_MainTexture, texCoord);
	
	gl_FragColor.r = clamp(0.,1.,textureColor.r * cc_FragTexCoord1.x * 1.25);
	gl_FragColor.g = clamp(0.,1.,textureColor.g * cc_FragTexCoord1.y * 2.0);
	gl_FragColor.b = textureColor.b;
	gl_FragColor.a = textureColor.a * cc_FragColor.a;

}