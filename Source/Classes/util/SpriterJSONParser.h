//
//  SpriterJSONParser.h
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpriterJSONParser : NSObject
-(SpriterJSONParser*)parseFile:(NSString*)filepath;
-(CGRect)cgRectForFrame:(NSString*)key;
@end
