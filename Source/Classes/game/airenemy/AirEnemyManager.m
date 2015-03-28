//
//  AirEnemyManager.m
//  hobobob
//
//  Created by spotco on 27/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "AirEnemyManager.h"
#import "GameEngineScene.h"
#import "Resource.h"
#import "FileCache.h"

@implementation BaseAirEnemy
-(void)i_update:(GameEngineScene*)game{}
-(BOOL)should_remove{ return YES; }
-(void)do_remove{ }
-(HitRect)get_hitrect{ return hitrect_cons_xy_widhei(self.position.x, self.position.y, 0, 0); }
@end

@interface TestAirEnemy : BaseAirEnemy
@end
@implementation TestAirEnemy
+(TestAirEnemy*)cons_pos:(CGPoint)pos {
	return [[TestAirEnemy node] cons_pos:pos];
}
-(TestAirEnemy*)cons_pos:(CGPoint)pos {
	[self setPosition:pos];
	[self setTexture:[Resource get_tex:TEX_ENEMIES_SPRITESHEET]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMIES_SPRITESHEET idname:@"spirit_fish_1.png"]];
	[self setScale:0.25];
	return self;
}
-(BOOL)should_remove{ return NO; }
-(HitRect)get_hitrect{ return hitrect_cons_xy_widhei(self.position.x, self.position.y, 0, 0); }
@end

@implementation AirEnemyManager {
	NSMutableArray *_enemies;
}
+(AirEnemyManager*)cons:(GameEngineScene*)g {
	return [[[AirEnemyManager alloc] init] cons:g];
}
-(AirEnemyManager*)cons:(GameEngineScene*)game {
	_enemies = [NSMutableArray array];

	[self add_enemy:[TestAirEnemy cons_pos:ccp(50,50)] game:game];
	[self add_enemy:[TestAirEnemy cons_pos:ccp(game_screen().width-50,-50)] game:game];
	return self;
}

-(void)i_update:(GameEngineScene*)game {
	NSMutableArray *do_remove = [NSMutableArray array];
	for (int i = _enemies.count-1; i >= 0; i--) {
		BaseAirEnemy *itr = [_enemies objectAtIndex:i];
		[itr i_update:game];
		if ([itr should_remove]) {
			[itr do_remove];
			[[game get_anchor] removeChild:itr];
			[do_remove addObject:itr];
		}
	}
	[_enemies removeObjectsInArray:do_remove];
	[do_remove removeAllObjects];
}
-(void)add_enemy:(BaseAirEnemy*)enemy game:(GameEngineScene*)game {
	[[game get_anchor] addChild:enemy];
	[_enemies addObject:enemy];
}
@end
