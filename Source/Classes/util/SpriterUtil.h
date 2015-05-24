#import <Foundation/Foundation.h>

@interface NSDictionary (KeySet)
	-(NSMutableSet*)keySet;
@end

void calc_table_scubic_point_for_t();

float sbezier_val_for_t(float p0, float p1, float p2, float p3, float t);
CGPoint sbezier_point_for_t(CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, float t);
float scubic_interp(float a, float b, float t);
float sshortest_angle(float src, float dest);
float scubic_angular_interp(float src, float dest, float t);