#import "GameUI.h"
#import "Resource.h" 
#import "FileCache.h"
#import "Common.h"
#import "GameEngineScene.h"
#import "SpiritBase.h"
#import "HealthBar.h"
#import "Particle.h"
#import "UIBossIntroParticle.h"

typedef enum _GameUIBossIntroMode {
	GameUIBossIntroMode_None,
	GameUIBossIntroMode_FillInToBoss,
	GameUIBossIntroMode_Boss
} GameUIBossIntroMode;

@implementation GameUI {
	NSMutableDictionary *_enemy_health_bars;
	HealthBar *_boss_health_bar;
	CCLabelTTF *_boss_health_label;
	GameUIBossIntroMode _current_boss_mode;
	float _boss_fillin_pct;
	
	ParticleSystem *_particles;
	
	CCSprite *_depth_bar_back;
	CCSprite *_depth_bar_fill;
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
	_boss_health_label = (CCLabelTTF*)[label_cons(ccp(0,15), ccc3(255, 255, 255), 6, @"Big Badass Boss") set_anchor_pt:ccp(0,0)];
	[_boss_health_bar addChild:_boss_health_label];
	_particles = [ParticleSystem cons_anchor:self];
	_current_boss_mode = GameUIBossIntroMode_None;
	
	_depth_bar_back = [CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_depthbar_back.png"]];
	[_depth_bar_back setAnchorPoint:ccp(0,1)];
	[_depth_bar_back setPosition:game_screen_anchor_offset(ScreenAnchor_TL, ccp(10,-40))];
	[_depth_bar_back setScale:0.85];
	[self addChild:_depth_bar_back];
	
	_depth_bar_fill = [CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_depthbar_fill.png"]];
	[_depth_bar_fill setAnchorPoint:ccp(0,0)];
	[_depth_bar_back addChild:_depth_bar_fill];
	
	[self depth_bar_from_top_fill_pct:0.9];
	
	return self;
}

-(float)depth_bar_from_top_fill_pct:(float)pct {
	CGRect rect = [FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_depthbar_fill.png"];
	float hei = rect.size.height * (1-pct);
	rect.origin.y += hei;
	rect.size.height -= hei;
	_depth_bar_fill.textureRect = rect;
	[_depth_bar_fill setPosition:ccp(0,hei)];
	return hei;
}

-(float)depth_bar_from_bottom_fill_pct:(float)pct {
	[_depth_bar_fill setPosition:ccp(0,0)];
	CGRect rect = [FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_depthbar_fill.png"];
}

-(void)start_boss:(NSString*)title sub:(NSString*)sub {
	[_particles add_particle:[UIBossIntroParticle cons_header:title sub:sub]];
	_current_boss_mode = GameUIBossIntroMode_FillInToBoss;
	_boss_fillin_pct = 0;
	[_boss_health_bar setVisible:YES];
	[_boss_health_label setString:title];
}

-(void)update_boss_ui:(GameEngineScene*)game {
	switch (_current_boss_mode) {
		case GameUIBossIntroMode_None:;
			[_boss_health_bar setVisible:NO];
		break;
		case GameUIBossIntroMode_FillInToBoss:;
			_boss_fillin_pct += 0.025 * dt_scale_get();
			[_boss_health_bar setVisible:YES];
			[_boss_health_label setVisible:NO];
			[_boss_health_bar set_pct:_boss_fillin_pct];
			if (_boss_fillin_pct >= 1) _current_boss_mode = GameUIBossIntroMode_Boss;
		break;
		case GameUIBossIntroMode_Boss:;
			[_boss_health_bar setVisible:YES];
			[_boss_health_label setVisible:YES];
			[_boss_health_bar set_pct:1.0];
		break;
	}
}

-(void)i_update:(GameEngineScene*)game {
	[self update_enemy_health_bars:game];
	[self update_boss_ui:game];
	[_particles update_particles:self];
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
