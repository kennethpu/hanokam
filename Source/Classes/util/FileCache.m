#import "FileCache.h"
#import "Resource.h"

#import "SpriterJSONParser.h"
#import "SpriterData.h"

#define PLIST @"plist"

@implementation FileCache

static NSMutableDictionary* files;

+(void)precache_files {
}

+(void)cache_file:(NSString*)file {
	NSDictionary *file_dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:PLIST]];
	if (file == NULL) NSLog(@"FileCache::FILE NOT FOUND:%@",file);
	
	NSDictionary *frames_dict = [file_dict objectForKey:@"frames"];
	NSMutableDictionary *sto_dict = [NSMutableDictionary dictionary];
	
    for (NSString *key in frames_dict.keyEnumerator) {
		NSDictionary *obj_info = [frames_dict objectForKey:key];
		CGRect r = CGRectFromString([obj_info objectForKey:@"textureRect"]);
		
		[sto_dict setObject:[NSValue valueWithCGRect:r] forKey:key];
	}
	
	[files setObject:sto_dict forKey:file];
}

+(CGRect)get_cgrect_from_plist:(NSString*)file idname:(NSString*)idname {
    if (files == NULL) {
        files = [[NSMutableDictionary alloc] init];
    }
    if (![files objectForKey:file]) {
		[self cache_file:file];
		//NSLog(@"DELAYED CACHEING OF %@",file);
    }
	NSDictionary *sto_dict = [files objectForKey:file];
	CGRect rtv = [(NSValue*)[sto_dict objectForKey:idname] CGRectValue];
	return rtv;
}

static NSMutableDictionary *_spriter_json_files;
+(SpriterJSONParser*)spriter_json_from_file:(NSString*)file {
	if (_spriter_json_files == NULL) _spriter_json_files = [NSMutableDictionary dictionary];
	if (![_spriter_json_files objectForKey:file]) {
		_spriter_json_files[file] = [[[SpriterJSONParser alloc] init] parseFile:file];
	}
	return _spriter_json_files[file];
}

NSString* hash_for_scmldata(NSString *file, NSString *json, CCTexture *texture) {
	return [NSString stringWithFormat:@"%@_%@_%@",file,json,texture];
}

static NSMutableDictionary *_spriter_scml_data_files;
+(SpriterData*)spriter_scml_data_from_file:(NSString*)file json:(NSString*)json texture:(CCTexture*)texture {
	if (_spriter_scml_data_files == NULL) _spriter_scml_data_files = [NSMutableDictionary dictionary];
	NSString *hash = hash_for_scmldata(file, json, texture);
	if (![_spriter_scml_data_files objectForKey:hash]) {
		SpriterJSONParser *json_data = [self spriter_json_from_file:json];
		_spriter_scml_data_files[hash] = [SpriterData dataFromSpriteSheet:texture frames:json_data scml:file];
	}
	return _spriter_scml_data_files[hash];
}

@end
