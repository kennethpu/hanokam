#import "ChainedMovementParticle.h"
#import "GameEngineScene.h"
#import "Player.h"

@interface ChainedMovementParticleWaypoint : NSObject
@property(readwrite,assign) CGPoint _point;
@property(readwrite,assign) float _speed;
@property(readwrite,assign) BOOL _use_playerx;
@end
@implementation ChainedMovementParticleWaypoint
@synthesize _point;
@synthesize _speed;
@synthesize _use_playerx;
@end

@implementation ChainedMovementParticle {
	NSMutableArray *_waypoints;
	float _t;
	
	CGPoint _starting_position;
	BOOL _has_starting_position;
	
	BOOL _use_playerx;
	BOOL _is_relative;
}

+(ChainedMovementParticle*)cons { return [[ChainedMovementParticle node] cons]; }
-(ChainedMovementParticle*)cons {
	_waypoints = [NSMutableArray array];
	_t = 0;
	_has_starting_position = NO;
	_use_playerx = NO;
	_is_relative = NO;
	return self;
}
-(ChainedMovementParticle*)add_waypoint:(CGPoint)target speed:(float)speed {
	if (!_has_starting_position) {
		_has_starting_position = YES;
		_starting_position = target;
	} else {
		ChainedMovementParticleWaypoint *neu = [[ChainedMovementParticleWaypoint alloc] init];
		neu._point = target;
		neu._speed = speed;
		neu._use_playerx = NO;
		[_waypoints addObject:neu];
	}
	return self;
}
-(ChainedMovementParticle*)add_playerx_waypoint:(float)target_y speed:(float)speed {
	ChainedMovementParticleWaypoint *neu = [[ChainedMovementParticleWaypoint alloc] init];
	neu._point = ccp(0,target_y);
	neu._speed = speed;
	neu._use_playerx = YES;
	[_waypoints addObject:neu];
	return self;
}
-(ChainedMovementParticle*)set_relative {
	_is_relative = YES;
	return self;
}

-(void)i_set_position:(CGPoint)pos game:(GameEngineScene*)game {
	_is_relative?[self setPosition:CGPointAdd(pos, ccp(0,game.get_viewbox.y1))]:[self setPosition:pos];
}

-(int)waypoints_left {
	return _waypoints.count;
}

-(void)i_update:(id)g {
	if (_waypoints.count == 0) return;
	GameEngineScene *game = g;
	ChainedMovementParticleWaypoint *tar = _waypoints[0];
	_t += tar._speed * dt_scale_get();
	if (_t < 1) {
		CGPoint start = _use_playerx? ccp(game.player.position.x,_starting_position.y) : _starting_position;
		CGPoint end = tar._use_playerx? ccp(game.player.position.x,tar._point.y) : tar._point;
		if (!tar._use_playerx) {
			[self i_set_position:lerp_point(start, end, cubic_interp(0, 1, 0, 1, _t)) game:game];
		} else {
			CGPoint bez_ctrl1 = ccp(end.x,start.y);
			CGPoint bez_ctrl2 = ccpMidpoint(bez_ctrl1, end);
			[self i_set_position:bezier_point_for_t(start, bez_ctrl1, bez_ctrl2, end, cubic_interp(0, 1, 0, 1, _t)) game:game];
		}
		
	} else {
		[_waypoints removeObjectAtIndex:0];
		[self i_set_position:tar._point game:game];
		_starting_position = tar._point;
		_use_playerx = tar._use_playerx;
		_t = 0;
	}
}
-(BOOL)should_remove {
	return _waypoints.count <= 0;
}
-(int)get_render_ord {
	return GameAnchorZ_Enemies_Air;
}


@end
