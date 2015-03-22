uniform float scalex;
uniform float scaley;
uniform sampler2D buffer;

float get1(int x, int y) {
    return texture2D(cc_MainTexture, cc_FragTexCoord1 + (vec2(x, y)) / vec2(scalex,scaley)).a;
}

float get2(int x, int y) {
    return texture2D(buffer, cc_FragTexCoord1 + (vec2(x, y)) / vec2(scalex,scaley)).a;
}

//buffer1 -
//buffer2
void main(){
	/*
	gl_FragColor = vec4(0,0,0,get1(-1,0));
	float new_height = (
		get1( 0, 1) +
		get1( 0,-1) +
		get1( 1, 0) +
		get1(-1, 0)) * .25;
	
	new_height -= get1(0, 0) * .4;
	
	gl_FragColor = vec4(0, 0, 0, new_height);

	
	float velocity = -get2(0,0);
	float smoothed = ( get1(-1,0) + get1(1,0) + get1(0,-1) + get1(0,1) ) / 4.0;
	float new_height = (velocity + smoothed)*0.95;
	gl_FragColor = vec4(0,0,0,new_height);
	*/
}

/*
// velocity position relation
Velocity(x,y) = -Buffer2(x,y)

// spread out the waves ( smooth values )
Smoothed(x,y) = ( Buffer1(x-1,y) + Buffer1(x+1,y) +
                  Buffer1(x,y-1) + Buffer1(x,y+1) ) / 4

// final height of the wave
NewHeight(x,y) = Smoothed(x,y) + Velocity(x,y)

// Ripples lose energy
NewHeight(x,y) = NewHeight(x,y) * damping

// swap the buffers
bufferTmp = buffer1;
buffer1   = buffer2;
buffer2   = bufferTmp;
*/