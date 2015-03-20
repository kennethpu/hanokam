varying float alphaGradient;

void main(){
  vec4 textureColor = texture2D(cc_MainTexture, cc_FragTexCoord1);
  gl_FragColor.r = cc_FragColor.r*textureColor.r;
  gl_FragColor.g = cc_FragColor.g*textureColor.g;
  gl_FragColor.b = cc_FragColor.b*textureColor.b;
  gl_FragColor.a = cc_FragColor.a*textureColor.a * alphaGradient * 0.8;
}