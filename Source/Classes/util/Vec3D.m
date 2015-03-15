#import "Vec3D.h"

Vec3D vec_z() {
    return vec_cons(0, 0, 1);
}

Vec3D vec_cons(float x, float y, float z) {
    struct Vec3D v;
    v.x = x;
    v.y = y;
    v.z = z;
    return v;
}

Vec3D vec_cons_norm(float x, float y, float z) {
	Vec3D rtv = vec_cons(x, y, z);
	vec_norm_m(&rtv);
	return rtv;
}

float vec_rad_angle_between(Vec3D a, Vec3D b) {
    return acosf(vec_dot(a, b)/(vec_len(a)*vec_len(b)));
}


Vec3D vec_add(Vec3D v1, Vec3D v2) {
    return vec_cons(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z);
}

Vec3D vec_sub(Vec3D v1, Vec3D v2) {
    return vec_cons(v2.x + v1.x,v2.y+v1.y,v2.z+v1.z);
}


Vec3D vec_scale(Vec3D v, float sf) {
    v.x *= sf;
    v.y *= sf;
    v.z *= sf;
    return v;
}

void vec_scale_m(Vec3D *v, float sf) {
    v->x *= sf;
    v->y *= sf;
    v->z *= sf;
}

BOOL vec_eq(Vec3D v1, Vec3D v2) {
    return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z;
}

Vec3D vec_neg(Vec3D v, float f) {
    v.x = -v.x;
    v.y = -v.y;
    v.z = -v.z;
    return v;
}

float vec_len(Vec3D v) {
    return sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z));
}

Vec3D vec_norm(Vec3D v) {
    float len = vec_len(v);
	if (len == 0) len = 0.0001;
    v.x /= len;
    v.y /= len;
    v.z /= len;
    return v;
}

void vec_norm_m(Vec3D *v) {
    float len = vec_len(*v);
	if (len == 0) len = 0.0001;
    v->x /= len;
    v->y /= len;
    v->z /= len;
}

Vec3D vec_cross(Vec3D v1, Vec3D a) {
	float x1, y1, z1;
    x1 = (v1.y*a.z) - (a.y*v1.z);
    y1 = -((v1.x*a.z) - (v1.z*a.x));
    z1 = (v1.x*a.y) - (a.x*v1.y);
    return vec_cons(x1, y1, z1);
}

float vec_dot(Vec3D v1, Vec3D a) {
	return ( v1.x * a.x ) + ( v1.y * a.y ) + ( v1.z * a.z );
}


Vec3D vec_rotate_rad(Vec3D v, float rad) {
    float mag = vec_len(v);
    float ang = atan2f(v.y, v.x);
    ang += rad;
	return vec_cons(mag*cos(ang), mag*sin(ang), v.z);
}

float vec_ang_rad(Vec3D v) {
    return atan2f(v.y,v.x);
}

float vec_ang_deg_lim180(Vec3D dirvec, float offset) {
	float ccwt = (vec_ang_rad(dirvec)+offset)*180.0 / M_PI;
	return ccwt > 0 ? 180-ccwt : -(180-ABS(ccwt));
}
