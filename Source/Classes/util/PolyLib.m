#import "PolyLib.h"

/*stackoverflow.com/questions/10962379/how-to-check-intersection-between-2-rotated-rectangles*/

NSString* SAT_poly_to_str(SATPoly* poly) {
	return strf("{{%f,%f},{%f,%f},{%f,%f},{%f,%f}}",
		poly->pts[0].x,poly->pts[0].y,
		poly->pts[1].x,poly->pts[1].y,
		poly->pts[2].x,poly->pts[2].y,
		poly->pts[3].x,poly->pts[3].y
	);
}

void SAT_hitrect_to_poly(SATPoly* buf, HitRect r) {
	SAT_cons_quad_buf(buf, ccp(r.x1,r.y1), ccp(r.x2,r.y1), ccp(r.x2,r.y2), ccp(r.x1,r.y2));
}

void SAT_cons_quad_buf(SATPoly* buf, CGPoint a, CGPoint b, CGPoint c, CGPoint d) {
	buf->length = 4;
	buf->pts[0] = a;
	buf->pts[1] = b;
	buf->pts[2] = c;
	buf->pts[3] = d;
}

BOOL SAT_polyowners_intersect(id<SATPolyHitOwner> a, id<SATPolyHitOwner> b) {
	if (!hitrect_touch([a get_hit_rect], [b get_hit_rect])) {
		return NO;
	}

    SATPoly polygons[2];
	[a get_sat_poly:&polygons[0]];
	[b get_sat_poly:&polygons[1]];
    
    for(int i = 0; i < 2; i++) { 
        SATPoly polygon = polygons[i];
        for (int i1 = 0; i1 < polygon.length; i1++) {
            
            int i2 = (i1 + 1) % polygon.length;
            CGPoint p1 = polygon.pts[i1];
            CGPoint p2 = polygon.pts[i2];
            
            CGPoint normal = ccp(p2.y-p1.y,p1.x-p2.x);
            
            float minA = NAN;
            float maxA = NAN;
            
            for (int j = 0; j < polygons[0].length; j++) {
                float projected = normal.x * polygons[0].pts[j].x + normal.y * polygons[0].pts[j].y;
                if (isnan(minA) || projected < minA) {
                    minA = projected;
                }
                if (isnan(maxA) || projected > maxA) {
                    maxA = projected;
                }
            }
            
            float minB = NAN;
            float maxB = NAN;
            
            for (int j = 0; j < polygons[1].length; j++) {
                float projected = normal.x * polygons[1].pts[j].x + normal.y * polygons[1].pts[j].y;
                
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

HitRect satpolyowner_cons_hit_rect(CGPoint position, float sizex, float sizey) {
	float scf = 0.25;
	float max_dim = MAX(sizex,sizey);
	float max_dim_2 = max_dim/2;
	return hitrect_cons_xy_widhei(position.x - max_dim_2*scf, position.y - max_dim_2*scf, max_dim*scf, max_dim*scf);
}

void satpolyowner_cons_sat_poly(SATPoly *in_poly, CGPoint position, float rotation, float sizex, float sizey, CGPoint mul_scf) {
	Vec3D right = vec_from_ccrotation(rotation);
	Vec3D up = vec_cross(vec_z(), right);
	float scf = 0.25;
	float wid = sizex/2 * scf * mul_scf.x;
	float hei = sizey/2 * scf * mul_scf.y;

	SAT_cons_quad_buf(
		in_poly,
		vec_basis_transform_point(position, up, -hei, right, -wid),
		vec_basis_transform_point(position, up, -hei, right, wid),
		vec_basis_transform_point(position, up, hei, right, wid),
		vec_basis_transform_point(position, up, hei, right, -wid)
	);
}
