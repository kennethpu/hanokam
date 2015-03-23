void main(){
	gl_Position = cc_Position;
	cc_FragTexCoord1 = cc_TexCoord1;
	cc_FragColor = clamp(cc_Color, 0.0, 1.0);
}