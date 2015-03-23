#import "GameUI.h"
#import "Resource.h" 
#import "FileCache.h"
#import "Common.h"
#import "GameEngineScene.h"
#import "SpiritBase.h"
#import "HealthBar.h"

@implementation GameUI {
	NSMutableDictionary *_enemy_health_bars;
	HealthBar *_boss_health_bar;
}

+(GameUI*)cons:(GameEngineScene*)game {
	return [(GameUI*)[GameUI node] cons:game];
}

-(GameUI*)cons:(GameEngineScene*)game {
	[self setAnchorPoint:ccp(0,0)];
	_enemy_health_bars = [NSMutableDictionary dictionary];
	_boss_health_bar = [HealthBar cons_size:CGSizeMake(game_screen().width-10, 15) anchor:ccp(0,0)];
	[_boss_health_bar setPosition:game_screen_anchor_offset(ScreenAnchor_BL, ccp(5,5))];
	[self addChild:_boss_health_bar];
	[_boss_health_bar set_pct:0.5];
	return self;
}

-(void)i_update:(GameEngineScene*)game {
	[self update_enemy_health_bars:game];
}

-(void)update_enemy_health_bars:(GameEngineScene*)game {
	NSMutableSet *active_enemy_objhash = _enemy_health_bars.keySet;
	for (SpiritBase *itr_enemy in game.get_spirit_manager.get_spirits) {
		if (![itr_enemy has_health_bar]) continue;
		NSNumber *itr_hash = @([itr_enemy hash]);
		if ([active_enemy_objhash containsObject:itr_hash]) {
			[active_enemy_objhash removeObject:itr_hash];
		} else {
			_enemy_health_bars[itr_hash] = [HealthBar cons_size:CGSizeMake(20, 4) anchor:ccp(0.5,0.5)];
			[self addChild:_enemy_health_bars[itr_hash]];
		}
		HealthBar *itr_healthbar = _enemy_health_bars[itr_hash];
		[itr_healthbar setPosition:CGPointAdd([itr_enemy convertToWorldSpace:CGPointZero],[itr_enemy get_healthbar_offset])];
		[itr_healthbar set_pct:[itr_enemy get_health_pct]];
	}
	
	for (NSNumber *itr_hash in active_enemy_objhash) {
		HealthBar *itr_healthbar = _enemy_health_bars[itr_hash];
		[self removeChild:itr_healthbar];
		[_enemy_health_bars removeObjectForKey:itr_hash];
	}
}

@end
