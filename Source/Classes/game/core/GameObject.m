#import "GameObject.h"
#import "GameEngineScene.h"

@implementation GameObject

-(void)update_game:(GameEngineScene*)g {}

-(void)check_should_render:(GameEngineScene *)g {
    if (hitrect_touch([g get_viewbox], [self get_hit_rect])) {
        [self setVisible:YES];
    } else {
        [self setVisible:NO];
    }
}

-(HitRect)get_hit_rect {
    return hitrect_cons_xy_widhei(0, 0, 0, 0);
}

-(int)get_render_ord {
    return 0;
}


@end
