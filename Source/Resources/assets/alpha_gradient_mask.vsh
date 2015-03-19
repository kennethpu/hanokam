
varying float alphaGradient;

void main(){
	gl_Position = cc_Position;
	cc_FragColor = clamp(cc_Color, 0.0, 1.0);
	cc_FragTexCoord1 = cc_TexCoord1;
	alphaGradient = 1.0-cc_TexCoord1.y;
}