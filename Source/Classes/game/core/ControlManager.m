//
//  AccelerometerManager.m
//  hobobob
//
//  Created by spotco on 15/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ControlManager.h"
#import "GameEngineScene.h"
#import "Player.h"
#import "Vec3D.h"

@implementation ControlManager {
	float _accel_x;
	
	float _touch_dist_sum, _avg_x, _avg_y;
	int _touch_move_counter;
	CGPoint _prev_touch;
	BOOL _is_touch_down, _this_touch_has_procced_action;
	
	Vec3D _proc_swipe_dir;
	BOOL _is_proc_swipe;
	
	CGPoint _proc_tap_pt;
	BOOL _is_proc_tap;
}

+(ControlManager*)cons {
	return [[ControlManager alloc] init];
}

-(void)accel_report_x:(float)x y:(float)y z:(float)z {
	_accel_x = x;
}

-(void)touch_begin:(CGPoint)pt {
    _is_touch_down = YES;
    _touch_move_counter = 0;
    _touch_dist_sum = 0;
    _prev_touch = pt;
	_this_touch_has_procced_action = NO;
	[self clear_proc_swipe];
}

-(void)touch_move:(CGPoint)pt {
    _touch_move_counter++;
    _touch_dist_sum += CGPointDist(_prev_touch, pt);
	
	float avg_ct = 3.0;
	_avg_x -= _avg_x / avg_ct;
    _avg_x += (pt.x-_prev_touch.x) / avg_ct;
	_avg_y -= _avg_y / avg_ct;
    _avg_y += (pt.y-_prev_touch.y) / avg_ct;
    
    if(_touch_move_counter == 3) {
        float avg = _touch_dist_sum/_touch_move_counter;
        if (avg > 7 && !_this_touch_has_procced_action) {
			_this_touch_has_procced_action = YES;
			Vec3D dir = vec_cons_norm(_avg_x, _avg_y, 0);
			float angle = rad_to_deg(vec_ang_rad(dir));
			if (angle < -25 && angle > -160) {
				_proc_swipe_dir = dir;
				_is_proc_swipe = YES;
			}
        }
		
        _touch_move_counter = 0;
        _touch_dist_sum = 0;
        _avg_x = 0;
        _avg_y = 0;
	}
    _prev_touch = pt;
}

-(void)touch_end:(CGPoint)pt {
    _is_touch_down = NO;
	if (!_this_touch_has_procced_action) {
		_is_proc_tap = YES;
		_proc_tap_pt = pt;
	}
}

-(float)get_accel_x {
	return _accel_x;
}

-(BOOL)is_proc_swipe {
	return _is_proc_swipe;
}
-(void)clear_proc_swipe {
	_is_proc_swipe = NO;
}
-(Vec3D)get_proc_swipe_dir {
	return _proc_swipe_dir;
}

-(BOOL)is_proc_tap {
	return _is_proc_tap;
}
-(void)clear_proc_tap {
	_is_proc_tap = NO;
}
-(CGPoint)get_proc_tap {
	return _proc_tap_pt;
}

-(BOOL)is_touch_down {
	return _is_touch_down;
}

-(void)i_update:(GameEngineScene*)game {}

@end
