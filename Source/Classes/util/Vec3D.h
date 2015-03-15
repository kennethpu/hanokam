#ifndef VEC3D_H
#define VEC3D_H
typedef struct Vec3D {
    float x,y,z;
} Vec3D;

Vec3D vec_z();
Vec3D vec_cons(float x, float y, float z);
Vec3D vec_cons_norm(float x, float y, float z);
float vec_rad_angle_between(Vec3D a, Vec3D b);
Vec3D vec_add(Vec3D v1, Vec3D v2);
Vec3D vec_sub(Vec3D v1, Vec3D v2);
Vec3D vec_scale(Vec3D v, float sf);
void vec_scale_m(Vec3D *v, float sf);
BOOL vec_eq(Vec3D v1, Vec3D v2);
Vec3D vec_neg(Vec3D v, float f);
float vec_len(Vec3D v);
Vec3D vec_norm(Vec3D v);
void vec_norm_m(Vec3D *v);
Vec3D vec_cross(Vec3D v1, Vec3D a);
float vec_dot(Vec3D v1, Vec3D a);
Vec3D vec_rotate_rad(Vec3D v, float rad);
float vec_ang_rad(Vec3D v);
float vec_ang_deg_lim180(Vec3D dirvec, float offset);
#endif