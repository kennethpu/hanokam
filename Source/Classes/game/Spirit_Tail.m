//
//  Spirit_Tail.m
//  hobobob
//
//  Created by Kuris on 3/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Spirit_Tail.h"

@implementation Spirit_Tail {
    CCNode *_parent;
}

(Spirit_Tail*)cons_parent:(CCNode*)parent_tail _sprite_id:(int)sprite_id {
    return ;
}

-(Spirit_Tail*)cons_parent:(CCNode*)parent_tail {
    _parent = parent_tail;
    return self;
}
@end
