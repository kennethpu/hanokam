#import "SpriterNodeCache.h"
#import "Resource.h"
#import "SpriterNode.h"
#import "FileCache.h"
#import "Common.h"

@implementation SpriterNodeCache {
	NSMutableDictionary *_cache;
}

+(SpriterNodeCache*)cons {
	return [[SpriterNodeCache alloc] init];
}

-(id)init {
	self = [super init];
	_cache = [NSMutableDictionary dictionary];
	return self;
}

NSString* hash_for(NSString* scml, NSString *json, NSString *texture) {
	return [NSString stringWithFormat:@"%@_%@_%@",scml,json,texture];
}

-(void)precache {
	//DO_FOR(6, [self add_to_cache_scml:@"enemy_puffer.scml" json:@"enemy_puffer.json" texture:TEX_SPRITER_ENEMY_PUFFER]);
}

static int _test_ct = 0;
static int _alloct = 0;

-(void)add_to_cache_scml:(NSString*)scml json:(NSString*)json texture:(NSString*)texture {
	NSString *hash = hash_for(scml, json, texture);
	if ([_cache objectForKey:hash] == NULL) _cache[hash] = [NSMutableArray array];
	SpriterNode *neu = [SpriterNode nodeFromData:[FileCache spriter_scml_data_from_file:scml json:json texture:[Resource get_tex:texture]]];
	[((NSMutableArray*)_cache[hash]) addObject:neu];
	
	_alloct++;
	//NSLog(@"alloc %d",_alloct);
}

-(SpriterNode*)depool_node_for_scml:(NSString*)scml json:(NSString*)json texture:(NSString*)texture {
	NSString *hash = hash_for(scml, json, texture);
	if ([_cache objectForKey:hash] == NULL) _cache[hash] = [NSMutableArray array];
	NSMutableArray *list = _cache[hash];
	if (list.count == 0) {
		[self add_to_cache_scml:scml json:json texture:texture];
	}
	SpriterNode *rtv = [list objectAtIndex:0];
	[list removeObjectAtIndex:0];
	
	_test_ct++;
	//NSLog(@"depool %d",_test_ct);
	
	return rtv;
}
-(void)repool_node:(SpriterNode*)node scml:(NSString*)scml json:(NSString*)json texture:(NSString*)texture {
	NSString *hash = hash_for(scml, json, texture);
	if ([_cache objectForKey:hash] == NULL) _cache[hash] = [NSMutableArray array];
	[((NSMutableArray*)_cache[hash]) addObject:node];
	
	_test_ct--;
	//NSLog(@"repool %d",_test_ct);
}

@end
