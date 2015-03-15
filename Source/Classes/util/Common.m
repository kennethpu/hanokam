#import "Common.h"
#import "GameMain.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "CoreFoundation/CoreFoundation.h"
#import "CCTexture_Private.h"
#import "CCAnimation.h"
#import "Resource.h"
#import "FileCache.h"
#import "DataStore.h"

@implementation CallBack
	@synthesize selector;
	@synthesize target;
@end

@implementation GLRenderObject
    @synthesize isalloc,pts;
    @synthesize texture;
	@synthesize transform;
    -(fCGPoint*)tex_pts {return tex_pts;}
    -(fCGPoint*)tri_pts {return tri_pts;}
@end

@implementation TexRect
	@synthesize tex;
	@synthesize rect;
+(TexRect*)cons_tex:(CCTexture *)tex rect:(CGRect)rect {
    TexRect *r = [[TexRect alloc] init]; [r setTex:tex]; [r setRect:rect]; return r;
}
@end

@implementation CCNode (helpers)
-(CCNode*)set_pos:(CGPoint)pt {
	[self setPosition:pt];
	return self;
}
-(CCNode*)set_scale:(float)scale {
	[self setScale:scale];
	return self;
}
-(CCNode*)set_scale_x:(float)scale_x {
	[self setScaleX:scale_x];
	return self;
}
-(CCNode*)set_scale_y:(float)scale_y {
	[self setScaleY:scale_y];
	return self;
}
-(CCNode*)set_rotation:(float)rotation {
	[self setRotation:rotation];
	return self;
}
-(CCNode*)set_color:(ccColor3B)color {
	[self setColor:[CCColor colorWithCcColor3b:color]];
	return self;
}
-(CCNode*)set_visible:(BOOL)visible {
	[self setVisible:visible];
	return self;
}
-(CCNode*)set_anchor_pt:(CGPoint)pt {
	[self setAnchorPoint:pt];
	return self;
}
-(CCNode*)add_to:(CCNode*)parent {
	return [self add_to:parent z:0];
}
-(CCNode*)add_to:(CCNode*)parent z:(NSInteger)z {
	[parent addChild:self z:z];
	return self;
}
-(CCNode*)add_on:(CCNode*)child {
	[self addChild:child];
	return self;
}
@end

@implementation NSArray (Random)
-(id)random {
	uint32_t rnd = (uint32_t)arc4random_uniform((u_int32_t)[self count]);
	return [self objectAtIndex:rnd];
}
-(BOOL)contains_str:(NSString *)tar {
	for (id i in self) {
		if ([i isEqualToString:tar]) return YES;
	}
	return NO;
}
-(NSArray*)copy_removing:(NSArray *)a {
	NSMutableArray *n = [NSMutableArray array];
	for (id i in self) {
		if (![a containsObject:i]) [n addObject:i];
	}
	return n;
}
-(id)get:(int)i {
	if (i >= [self count]) {
		return NULL;
	} else {
		return [self objectAtIndex:i];
	}
}
@end

float drp(float a, float b, float div) {
	return a + (b - a) / div;
}

float lerp(float a, float b, float t) {
	return a + (b - a) * t;
}

long sys_time() {
	return CFAbsoluteTimeGetCurrent();
}

fCGPoint fCGPointMake(float x, float y){
	fCGPoint rtv;
	rtv.x = x;
	rtv.y = y;
	return rtv;
}

@implementation NSMutableArray (Shuffle)
-(void)shuffle {
	for (NSUInteger i = [self count] - 1; i >= 1; i--){
		u_int32_t j = (uint32_t)arc4random_uniform((u_int32_t)i + 1);
		[self exchangeObjectAtIndex:j withObjectAtIndex:i];
	}
}
-(id)add:(id)i {
	[self addObject:i];
	return i;
}
@end

NSString* strf (char* format, ... ) {
    char outp[255];
    va_list a_list;
    va_start( a_list, format );
    vsprintf(outp, format, a_list);
    va_end(a_list);
    return [NSString stringWithUTF8String:outp];
}

int SIG(float n) {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    } else {
        return 0;
    }
}

inline CGPoint CGPointAdd(CGPoint a,CGPoint b) {
    return ccp(a.x+b.x,a.y+b.y);
}

inline float CGPointDist(CGPoint a,CGPoint b) {
    return sqrtf(powf(a.x-b.x, 2)+powf(a.y-b.y, 2));
}

bool fuzzyeq(float a, float b, float delta) {
	return ABS(a-b) <= delta;
}

float deg_to_rad(float degrees) {
    return degrees * M_PI / 180.0;
}

float rad_to_deg(float rad) {
    return rad * 180.0 / M_PI;
}

CGPoint pct_of_obj(CCNode* obj, float pctx, float pcty) {
	CGRect rct = [obj boundingBox];
	return ccp(rct.size.width*pctx*1/ABS(obj.scaleX),rct.size.height*pcty*1/ABS(obj.scaleY));
}

static BOOL has_set_sdt = NO;
static CCTime sdt = 1;
static CCTime last_sdt = 1;
void dt_set(CCTime dt) {
	if (!has_set_sdt) {
		has_set_sdt = YES;
		sdt = dt;
		last_sdt = dt;
		return;
	}

	last_sdt = sdt;
	sdt = dt;
	if (ABS(sdt-last_sdt) > 0.01) {
		sdt = last_sdt + 0.01 * SIG(sdt-last_sdt);
	}
}

void dt_unset() {
	has_set_sdt = NO;
}

float dt_scale_get() {
	return clampf(sdt/(1/60.0f), 0.25, 3);
}

CGSize game_screen() {
    return [CCDirector sharedDirector].viewSize;
}

CGPoint game_screen_pct(float pctwid, float pcthei) {
    return ccp(game_screen().width*pctwid,game_screen().height*pcthei);
}

void callback_run(CallBack *c) {
	IMP imp = [c.target methodForSelector:c.selector];
	void (*func)(id, SEL) = (void *)imp;
	func(c.target,c.selector);
}

CallBack* callback_cons(NSObject *tar, SEL sel) {
    CallBack* cb = [[CallBack alloc] init];
    cb.target = tar;
	cb.selector = sel;
    return cb;
}

HitRect hitrect_cons_x1y1_x2y2(float x1, float y1, float x2, float y2) {
	struct HitRect n;
    n.x1 = x1;
    n.y1 = y1;
    n.x2 = x2;
    n.y2 = y2;
    return n;
}

HitRect hitrect_cons_xy_widhei(float x1, float y1, float wid, float hei) {
    return hitrect_cons_x1y1_x2y2(x1, y1, x1+wid, y1+hei);
}

CGRect hitrect_to_cgrect(HitRect rect) {
    return CGRectMake(rect.x1, rect.y1, rect.x2-rect.x1, rect.y2-rect.y1);
}

BOOL hitrect_touch(HitRect r1, HitRect r2) {
    return !(r1.x1 > r2.x2 ||
             r2.x1 > r1.x2 ||
             r1.y1 > r2.y2 ||
             r2.y1 > r1.y2);
}

CGFloat SEG_NO_VALUE() {
	return -99999.995;
}

CGPoint line_seg_intersection_pts(CGPoint a1, CGPoint a2, CGPoint b1, CGPoint b2) {
	CGPoint null_point = CGPointMake(SEG_NO_VALUE(),SEG_NO_VALUE());
    double Ax = a1.x; double Ay = a1.y;
	double Bx = a2.x; double By = a2.y;
	double Cx = b1.x; double Cy = b1.y;
	double Dx = b2.x; double Dy = b2.y;
	double X; double Y;
	double  distAB, theCos, theSin, newX, ABpos ;
	
	if ((Ax==Bx && Ay==By) || (Cx==Dx && Cy==Dy)) return null_point; //  Fail if either line segment is zero-length.
    
	Bx-=Ax; By-=Ay;//Translate the system so that point A is on the origin.
	Cx-=Ax; Cy-=Ay;
	Dx-=Ax; Dy-=Ay;
	
	distAB=sqrt(Bx*Bx+By*By);//Discover the length of segment A-B.
	
	theCos=Bx/distAB;//Rotate the system so that point B is on the positive X axis.
	theSin=By/distAB;
    
	newX=Cx*theCos+Cy*theSin;
	Cy  =Cy*theCos-Cx*theSin; Cx=newX;
	newX=Dx*theCos+Dy*theSin;
	Dy  =Dy*theCos-Dx*theSin; Dx=newX;
	
	if ((Cy<0. && Dy<0.) || (Cy>=0. && Dy>=0.)) return null_point;//C-D must be origin crossing line
	
	ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);//Discover the position of the intersection point along line A-B.
	
    
	if (ABpos<0. || ABpos-distAB> 0.001) {
        return null_point;//  Fail if segment C-D crosses line A-B outside of segment A-B.
	}
        
	X=Ax+ABpos*theCos;//Apply the discovered position to line A-B in the original coordinate system.
	Y=Ay+ABpos*theSin;
	
	return ccp(X,Y);
}

float shortest_dist_from_cur(float a1, float a2) {
    a1 = deg_to_rad(a1);
    a2 = deg_to_rad(a2);
    float res = atan2f(cosf(a1)*sinf(a2)-sinf(a1)*cosf(a2),
                       sinf(a1)*sinf(a2)+cosf(a1)*cosf(a2));
    
    res = rad_to_deg(res);
    return res;
}

CGPoint line_seg_intersection(line_seg a, line_seg b) {
    return line_seg_intersection_pts(a.a, a.b, b.a, b.b);
}

line_seg line_seg_cons(CGPoint a, CGPoint b) {
    struct line_seg new;
    new.a = a;
    new.b = b;
    return new;
}

GLRenderObject* render_object_cons(CCTexture* tex, int npts) {
    GLRenderObject *n = [[GLRenderObject alloc] init];
    n.texture = tex;
    n.isalloc = 1;
    n.pts = npts;
    return n;
}

void render_object_draw(CCRenderer* renderer, CCRenderState *renderState, const GLKMatrix4 *transform, GLRenderObject *obj) {
	CCRenderBuffer buffer = [renderer enqueueTriangles:obj.pts/2 andVertexes:obj.pts withState:renderState globalSortOrder:0];
	for (int i = 0; i < obj.pts; i++) {
		CCVertex vert;
		vert.position = GLKVector4Make(obj.tri_pts[i].x, obj.tri_pts[i].y, 0, 1);
		vert.texCoord1 = GLKVector2Make(obj.tex_pts[i].x, obj.tex_pts[i].y);
		vert.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
		CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(vert, transform));
	}
	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	if (obj.pts == 4) CCRenderBufferSetTriangle(buffer, 1, 1, 2, 3);
}

void render_object_tex_map_to_tri_loc(GLRenderObject *o, int len) {
    for (int i = 0; i < len; i++) {
        o.tex_pts[i] = fccp(o.tri_pts[i].x/o.texture.pixelWidth, o.tri_pts[i].y/o.texture.pixelHeight);
    }
}

CGRect rect_from_dict(NSDictionary* dict, NSString* tar) {
    NSDictionary *frames_dict = [dict objectForKey:@"frames"];
    NSDictionary *obj_info = [frames_dict objectForKey:tar];
    NSString *txt = [obj_info objectForKey:@"textureRect"];
    CGRect r = CGRectFromString(txt);
    return r;
}

void render_object_transform(GLRenderObject* o, CGPoint position) {
	o.tri_pts[0] = fccp(position.x+o.tri_pts[0].x-o.transform.x, position.y+o.tri_pts[0].y-o.transform.y);
	o.tri_pts[1] = fccp(position.x+o.tri_pts[1].x-o.transform.x, position.y+o.tri_pts[1].y-o.transform.y);
	o.tri_pts[2] = fccp(position.x+o.tri_pts[2].x-o.transform.x, position.y+o.tri_pts[2].y-o.transform.y);
	o.tri_pts[3] = fccp(position.x+o.tri_pts[3].x-o.transform.x, position.y+o.tri_pts[3].y-o.transform.y);
	o.transform = ccp2fccp(position);
}

CameraZoom camerazoom_cons(float x, float y, float z) {
    struct CameraZoom c = {x,y,z};
    return c;
}

CCAction* animaction_cons(NSArray *a, float speed, NSString *tex_key) {
	CCTexture *texture = [Resource get_tex:tex_key];
	NSMutableArray *animFrames = [NSMutableArray array];
	for (NSString* k in a)
		[animFrames addObject:
		 [CCSpriteFrame frameWithTexture:texture
									rectInPixels:[FileCache get_cgrect_from_plist:tex_key idname:k]]];
    return [CCActionRepeatForever actionWithAction:
			[CCActionAnimate actionWithAnimation:
			 [CCAnimation animationWithSpriteFrames:animFrames delay:speed]
							restoreOriginalFrame:YES]];
}

CCAction* animaction_nonrepeating_cons(NSArray *a, float speed, NSString *tex_key) {
	CCTexture *texture = [Resource get_tex:tex_key];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a)
		[animFrames addObject:
		 [CCSpriteFrame frameWithTexture:texture
							rectInPixels:[FileCache get_cgrect_from_plist:tex_key idname:k]]];
	return [CCActionAnimate actionWithAnimation:[CCAnimation animationWithSpriteFrames:animFrames delay:speed] restoreOriginalFrame:NO];
}

NSString* platform() {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	return platform;
}

void scale_to_fit_screen_x(CCSprite *spr) {
	[spr setScaleX:game_screen().width/spr.texture.contentSize.width];
}
void scale_to_fit_screen_y(CCSprite *spr) {
	[spr setScaleY:game_screen().height/spr.texture.contentSize.height];
}

#define KEY_UUID @"key_uuid"
NSString* unique_id() {
	if ([DataStore get_str_for_key:KEY_UUID] == NULL) {
		CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
		NSString *uuid_str = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
		CFRelease((CFTypeRef)uuid);
		[DataStore set_key:KEY_UUID str_value:uuid_str];
	}
	return [DataStore get_str_for_key:KEY_UUID];
}

CCLabelTTF* label_cons(CGPoint pos, ccColor3B color, int fontSize, NSString* str) {
	CCLabelTTF *rtv = (CCLabelTTF*)[[CCLabelTTF labelWithString:str fontName:@"" fontSize:fontSize] set_pos:pos];
	[rtv setColor:_CCColor(color)];
	return rtv;
}
