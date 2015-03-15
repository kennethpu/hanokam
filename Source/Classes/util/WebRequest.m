#import "WebRequest.h"

/**
 [WebRequest request_to:@"http://www.spotcos.com" callback:^(NSString* response, WebRequestStatus status) {
	if (status == WebRequestStatus_OK) {
		NSLog(@"%@",response);
	} else {
		NSLog(@"request failed");
	}
 }];
 **/

@implementation WebRequest

static NSOperationQueue *request_queue;

+(void)initialize {
	request_queue = [[NSOperationQueue alloc] init];
	[request_queue setMaxConcurrentOperationCount:5];
}

+(void)request_to:(NSString*)url callback:(void (^)(NSString* response, WebRequestStatus status))callback {
	NSURL *url_obj = [NSURL URLWithString:url];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url_obj
												cachePolicy:NSURLRequestReloadIgnoringCacheData
											timeoutInterval:30];
	
	[NSURLConnection sendAsynchronousRequest:urlRequest
									  queue:request_queue
						  completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
							   if (callback == NULL) return;
							   if (!error) {
								   NSString *body = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
								   callback(body,WebRequestStatus_OK);
								   
							   } else {
								   callback(@"",WebRequestStatus_FAIL);
							   }
						   }];
	
}

+(void)post_request_to:(NSString*)url vals:(NSDictionary *)vals callback:(void (^)(NSString *, WebRequestStatus))callback{
	NSURL *url_obj = [NSURL URLWithString:url];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url_obj
												cachePolicy:NSURLRequestReloadIgnoringCacheData
											timeoutInterval:30];
	
	NSMutableString *post = [NSMutableString string];
	NSEnumerator *itr = [vals keyEnumerator];
	
	
	NSString *key = NULL;
	while (1) {
		if (key != NULL) {
			NSString *val = [vals objectForKey:key];
			[post appendString:[NSString stringWithFormat:@"%@=%@",key,val]];
		}
		key = [itr nextObject];
		if (key == NULL) {
			break;
		} else if (key != NULL && post.length != 0) {
			[post appendString:@"&"];
		}
	}
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setHTTPBody:postData];
	
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:request_queue
						   completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
							   if (callback == NULL) return;
							   if (!error) {
								   NSString *body = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
								   callback(body,WebRequestStatus_OK);
								   
							   } else {
								   callback(@"",WebRequestStatus_FAIL);
							   }
						   }];
}



@end
