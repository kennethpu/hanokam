#import "DataStore.h"

@implementation DataStore

static NSUserDefaults* store;

+(void)cons {
    store = [NSUserDefaults standardUserDefaults];
}

+(void)reset_all {
	for (NSString* key in [store dictionaryRepresentation].keyEnumerator) {
		[store removeObjectForKey:key];
	}
	[store synchronize];
}

+(BOOL)isset_key:(NSString*)key {
    return [store objectForKey:key] != NULL;
}

+(void)reset_key:(NSString*)key {
    [store setObject:nil forKey:key];
    [self force_write];
}

+(void)set_key:(NSString*)key int_value:(int)val {
    [store setInteger:val forKey:key];
    [self force_write];
}

+(int)get_int_for_key:(NSString*)key {
    return (int)[store integerForKey:key];
}

+(void)set_key:(NSString*)key flt_value:(float)val {
    [store setFloat:val forKey:key];
    [self force_write];
}

+(float)get_flt_for_key:(NSString*)key {
    return [store floatForKey:key];
}

+(void)set_key:(NSString*)key str_value:(NSString*)val {
    [store setObject:val forKey:key];
    [self force_write];
}

+(NSString*)get_str_for_key:(NSString*)key {
    return [store stringForKey:key];
}

+(void)force_write {
    [store synchronize];
}

+(void)set_long_for_key:(NSString *)key long_value:(long)val {
	[store setInteger:val forKey:key];
	[self force_write];
}

+(long)get_long_for_key:(NSString *)key {
	return [store integerForKey:key];
}


@end
