#import "PolyLib.h"

@implementation PolyLib

+(SATPoly)hitrect_to_poly:(HitRect)r {
    return [PolyLib cons_SATPoly_quad:ccp(r.x1,r.y1) b:ccp(r.x2,r.y1) c:ccp(r.x2,r.y2) d:ccp(r.x1,r.y2)];
}

+(SATPoly)cons_SATPoly_quad:(CGPoint)a b:(CGPoint)b c:(CGPoint)c d:(CGPoint)d {
    struct SATPoly n;
    n.length = 4;
    n.pts[0]=a;
    n.pts[1]=b;
    n.pts[2]=c;
    n.pts[3]=d;
    return n;
}

+(BOOL)poly_intersect_SAT:(SATPoly)a b:(SATPoly)b {
    SATPoly polygons[2] = {a,b};
    
    for(int i = 0; i < 2; i++) { 
        SATPoly polygon = polygons[i];
        for (int i1 = 0; i1 < polygon.length; i1++) {
            
            int i2 = (i1 + 1) % polygon.length;
            CGPoint p1 = polygon.pts[i1];
            CGPoint p2 = polygon.pts[i2];
            
            CGPoint normal = ccp(p2.y-p1.y,p1.x-p2.x);
            
            float minA = NAN;
            float maxA = NAN;
            
            for (int j = 0; j < a.length; j++) {
                float projected = normal.x * a.pts[j].x + normal.y * a.pts[j].y;
                if (isnan(minA) || projected < minA) {
                    minA = projected;
                }
                if (isnan(maxA) || projected > maxA) {
                    maxA = projected;
                }
            }
            
            float minB = NAN;
            float maxB = NAN;
            
            for (int j = 0; j < b.length; j++) {
                float projected = normal.x * b.pts[j].x + normal.y * b.pts[j].y;
                
                if (isnan(minB) || projected < minB) {
                    minB = projected;
                }
                if (isnan(maxB) || projected > maxB) {
                    maxB = projected;
                }
            }
            
            if (maxA < minB || maxB < minA) {
                return false;
            }
        }
    }
    return true;
}

+(NSString*)satpoly_to_str:(SATPoly)poly {
	return strf("{SATPoly 0:(%f,%f) 1:(%f,%f) 2:(%f,%f) 3:(%f,%f)}",poly.pts[0].x,poly.pts[0].y,poly.pts[1].x,poly.pts[1].y,poly.pts[2].x,poly.pts[2].y,poly.pts[3].x,poly.pts[3].y);
}


/*stackoverflow.com/questions/10962379/how-to-check-intersection-between-2-rotated-rectangles*/

@end
