#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Common.h"

@interface PolyLib : NSObject

typedef struct SATPoly {
    CGPoint pts[4];
    int length;
} SATPoly;

+(SATPoly)hitrect_to_poly:(HitRect)r;
+(SATPoly)cons_SATPoly_quad:(CGPoint)a b:(CGPoint)b c:(CGPoint)c d:(CGPoint)d;
+(BOOL)poly_intersect_SAT:(SATPoly)a b:(SATPoly)b;
+(NSString*)satpoly_to_str:(SATPoly)poly;


@end
