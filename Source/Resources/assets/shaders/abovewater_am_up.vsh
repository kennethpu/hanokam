varying float alphaGradient;

void main(){
	gl_Position = cc_Position;
	cc_FragTexCoord1 = cc_TexCoord1;
	alphaGradient = cc_TexCoord1.y;
}