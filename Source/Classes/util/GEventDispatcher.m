#import "GEventDispatcher.h"

@implementation GEventDispatcher

static NSMutableArray* listeners;
static NSMutableArray* event_queue;

+(void)lazy_alloc {
    if (!listeners) {
        listeners = [[NSMutableArray alloc] init];
    }
    if (!event_queue) {
        event_queue = [[NSMutableArray alloc] init];
    }
}

+(void)add_listener:(id<GEventListener>)tar {
    [listeners addObject:tar];
}

+(void)remove_all_listeners {
    [listeners removeAllObjects];
}

+(void)remove_listener:(id<GEventListener>)tar {
    [listeners removeObject:tar];
}

+(void)push_event:(GEvent*)e {
    [event_queue addObject:e];
}

+(void)push_unique_event:(GEvent*)e {
    for (GEvent* i in event_queue) {
        if (e.type == i.type) {
            return;
        }
    }
    [GEventDispatcher push_event:e];
}

+(void)immediate_event:(GEvent*)e {
    for(int li = 0; li < [listeners count]; li++) {
        id<GEventListener> l = [listeners objectAtIndex:li];
        [l dispatch_event:e];
    }
}

+(void)dispatch_events {
    [GEventDispatcher lazy_alloc];
    if ([event_queue count]==0){return;}
	
	//[self print_queue_events];
	
    for(int ei = 0; ei < [event_queue count]; ei++) {
        GEvent* e = [event_queue objectAtIndex:ei];
        
        for(int li = 0; li < [listeners count]; li++) {
            id<GEventListener> l = [listeners objectAtIndex:li];
            [l dispatch_event:e];
        }
    }
    
    [event_queue removeAllObjects];
}

+(void)print_queue_events {
	NSMutableString *evts = [NSMutableString stringWithFormat:@"events["];
	for(int ei = 0; ei < [event_queue count]; ei++) {
		GEvent* e = [event_queue objectAtIndex:ei];
		[evts appendString:[NSString stringWithFormat:@"%d ",e.type]];
	}
	[evts appendString:@"]"];
	NSLog(@"%@",evts);
}

+(void)remove_all_events {
	[event_queue removeAllObjects];
}
@end

@implementation GEvent
    @synthesize type;
    @synthesize data;
    @synthesize pt;
    @synthesize i1,i2;
    @synthesize f1,f2;

+(GEvent*)cons_type:(GEventType)t {
    GEvent *e = [[GEvent alloc] init];
    e.type = t;
    return e;
}

-(GEvent*)add_key:(NSString*)k value:(id)v {
    if (!data) {
        data = [[NSMutableDictionary alloc] init];
    }
    [data setObject:v forKey:k];
    return self;
}

-(GEvent*)add_pt:(CGPoint)tpt {
    pt = tpt;
    return self;
}

-(GEvent*)add_i1:(int)ti1 i2:(int)ti2 {
    i1 = ti1;
    i2 = ti2;
    return self;
}

-(GEvent*)add_f1:(float)tf1 f2:(float)tf2 {
    f1 = tf1;
    f2 = tf2;
    return self;
}

-(id)get_value:(NSString*)key {
	if (!data) return NULL;
    return [data objectForKey:key];
}

@end
