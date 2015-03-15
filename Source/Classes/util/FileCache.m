#import "FileCache.h"
#import "Resource.h"

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

@end
