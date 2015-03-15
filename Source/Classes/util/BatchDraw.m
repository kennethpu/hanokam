#import "BatchDraw.h"

@interface BatchJob : NSObject {
    fCGPoint *pvtx,*ptex;
    ccColor4B *pclr;
    int batch_ct,cursize;
}
+(BatchJob*)cons_tex:(GLuint)tex;
-(void)add_obj:(GLRenderObject*)gl;
-(void)clear;
@property(readwrite,assign) GLuint tex;
@property(readwrite,assign) int dord;
@end

@implementation BatchJob
#define WHITE ccc4(255, 255, 255, 255)
@synthesize dord;
@synthesize tex;
+(BatchJob*)cons_tex:(GLuint)tex {
    BatchJob *b = [[BatchJob alloc] init];
    [b cons_tex:tex];
    return b;
}

-(void)cons_tex:(GLuint)ttex{
    tex = ttex;
    cursize = 36;
    [self alloc_arrs:cursize];

}

-(void)alloc_arrs:(int)size {
    pvtx = calloc(size, sizeof(CGPoint));
    ptex = calloc(size, sizeof(CGPoint));
    pclr = calloc(size, sizeof(ccColor4B));
}

-(void)incr_arrs_to:(int)sizef {
    fCGPoint *o_pvtx,*o_ptex;
    ccColor4B *o_pclr;
    
    o_pvtx = pvtx;
    o_ptex = ptex;
    o_pclr = pclr;
    
    [self alloc_arrs:sizef];
    
    memcpy(pvtx, o_pvtx, sizeof(CGPoint)*cursize);
    memcpy(ptex, o_ptex, sizeof(CGPoint)*cursize);
    memcpy(pclr, o_pclr, sizeof(ccColor4B)*cursize);
    
    cursize = sizef;
    
    free(o_pvtx);
    free(o_ptex);
    free(o_pclr);
}

-(void)add_obj:(GLRenderObject*)gl {
    int lim = gl.pts==4?6:3;
    
    while (cursize < batch_ct+lim) {
        [self incr_arrs_to:cursize*cursize];
    }
    
    for(int i = 0; i < lim; i++) {
        int t = i%3 + i/3;
        pvtx[batch_ct+i] = gl.tri_pts[t];
        ptex[batch_ct+i] = gl.tex_pts[t];
        pclr[batch_ct+i] = WHITE;
    }
    batch_ct+=lim;
}

-(void)clear {
    batch_ct = 0;
}

-(void)dealloc {
    free(pvtx);
    free(ptex);
    free(pclr);
}
@end


@implementation BatchDraw

static NSMutableArray* z_bucket;

+(void)cons {
    if (!z_bucket) {
        z_bucket = [[NSMutableArray alloc] init];
        for(int i = 0; i < 8; i++) {
            [z_bucket addObject:[NSMutableArray array]];
        }
    }
}

+(void)add:(GLRenderObject*)gl key:(GLuint)tex z_ord:(int)zord draw_ord:(int)dord {
    if (![z_bucket objectAtIndex:zord]) {
        [z_bucket replaceObjectAtIndex:zord withObject:[NSMutableArray array]];
    }
    
    NSMutableArray *zord_list = [z_bucket objectAtIndex:zord];
    
    for (BatchJob *b in zord_list) {
        if (b.tex == tex && b.dord == dord) {
            [b add_obj:gl];
            return;
        }
    }
    BatchJob *nb = [BatchJob cons_tex:tex];
    nb.dord = dord;
    [nb add_obj:gl];
    [zord_list addObject:nb];
    return;
}

+(void)sort_jobs {    
    for(NSMutableArray *a in z_bucket) {
        [a sortUsingComparator:^NSComparisonResult(BatchJob *a, BatchJob *b) {
            NSNumber *v_a = [NSNumber numberWithInt:a.dord];
            NSNumber *v_b = [NSNumber numberWithInt:b.dord];
            return [v_a compare:v_b];
        }];
    }
}

/*
-(void)draw {
    [super draw];
    NSArray* jobs = [z_bucket objectAtIndex:[self zOrder]];
    if (jobs) {
		
		CCGLProgram *prog = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
		[prog use];
		[prog setUniformsForBuiltins];
		
        for (BatchJob *job in jobs) {
            [job draw];
        }
    }
}
*/

+(void)clear {
    for(NSMutableArray *jobs in z_bucket) {
        for (BatchJob* job in jobs) {
            [job clear];
        }
    }
}



@end
