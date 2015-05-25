#import "GameUI.h"
#import "Resource.h" 
#import "FileCache.h"
#import "Common.h"
#import "GameEngineScene.h"
#import "HealthBar.h"
#import "Particle.h"
#import "UIBossIntroParticle.h"
#import "Player.h"
#import "PlayerUIHealthIndicator.h"

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
	
	CCSprite *_depth_bar_icon_player, *_depth_bar_icon_boss;
	
	PlayerUIHealthIndicator *_player_health_ui;
	
	CCNode *_red_flash_overlay;
	CCNode *_black_fadeout_overlay;
	float _tar_black_fadeout_overlay_alpha;
}

+(GameUI*)cons:(GameEngineScene*)game {
	return [(GameUI*)[GameUI node] cons:game];
}

-(GameUI*)cons:(GameEngineScene*)game {
	[self setAnchorPoint:ccp(0,0)];
	
	_red_flash_overlay = [CCNodeColor nodeWithColor:[CCColor redColor]];
	[_red_flash_overlay setOpacity:0];
	[self addChild:_red_flash_overlay];
	
	_black_fadeout_overlay = [CCNodeColor nodeWithColor:[CCColor blackColor]];
	_tar_black_fadeout_overlay_alpha = 0;
	[_black_fadeout_overlay setOpacity:_tar_black_fadeout_overlay_alpha];
	[self addChild:_black_fadeout_overlay];
	
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
	[_depth_bar_back setAnchorPoint:ccp(0,0.5)];
	[_depth_bar_back setPosition:game_screen_anchor_offset(ScreenAnchor_ML, ccp(10,0))];
	[_depth_bar_back setScale:0.85];
	[self addChild:_depth_bar_back];
	
	_depth_bar_fill = [CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_depthbar_fill.png"]];
	[_depth_bar_fill setAnchorPoint:ccp(0,0)];
	[_depth_bar_back addChild:_depth_bar_fill];
	
	_depth_bar_icon_player = [CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_selector.png"]];
	[_depth_bar_icon_player setPosition:ccp(10,100)];
	[_depth_bar_icon_player setScale:0.15];
	[_depth_bar_icon_player addChild:
		[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET]
							   rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_hanoka.png"]] set_scale:3] set_pos:ccp(250,45)]
	];
	[_depth_bar_back addChild:_depth_bar_icon_player];
	
	_depth_bar_icon_boss = [CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET] rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_selector.png"]];
	[_depth_bar_icon_boss setPosition:ccp(10,10)];
	[_depth_bar_icon_boss setScale:0.15];
	[_depth_bar_icon_boss addChild:
		[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_HUD_SPRITESHEET]
							   rect:[FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"hudicon_skull.png"]] set_scale:3] set_pos:ccp(250,45)]
	];
	[_depth_bar_back addChild:_depth_bar_icon_boss];
	
	CGRect heart_size = [FileCache get_cgrect_from_plist:TEX_HUD_SPRITESHEET idname:@"heart_fill.png"];
	_player_health_ui = [PlayerUIHealthIndicator cons:game];
	[_player_health_ui setPosition:game_screen_anchor_offset(ScreenAnchor_TL, ccp((heart_size.size.width*0.5 + 3),-(heart_size.size.height*0.5 + 3)))];
	[self addChild:_player_health_ui];
	
	
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
	rect.size.height *= pct;
	[_depth_bar_fill setTextureRect:rect];
	return rect.size.height;
}

-(void)start_boss:(NSString*)title sub:(NSString*)sub {
	[_particles add_particle:[UIBossIntroParticle cons_header:title sub:sub]];
	_current_boss_mode = GameUIBossIntroMode_FillInToBoss;
	_boss_fillin_pct = 0;
	[_boss_health_bar setVisible:YES];
	[_boss_health_label setString:title];
}

-(void)flash_red {
	[_red_flash_overlay setOpacity:0.5];
}

-(void)fadeout:(BOOL)tar {
	_tar_black_fadeout_overlay_alpha = tar?1:0;
}
-(BOOL)is_faded_out {
	return _black_fadeout_overlay.opacity >= 1;
}
-(BOOL)is_faded_in {
	return _black_fadeout_overlay.opacity <= 0;
}
-(void)pulse_heart_lastfill {
	[_player_health_ui pulse_heart_lastfill];
}

-(void)i_update:(GameEngineScene*)game {
	[self update_enemy_health_bars:game];
	[self update_boss_ui:game];
	[_player_health_ui i_update:game];
	[_particles update_particles:self];
	[_red_flash_overlay setOpacity:MAX(0,_red_flash_overlay.opacity-0.025*dt_scale_get())];
	[_black_fadeout_overlay setOpacity:(_tar_black_fadeout_overlay_alpha>0.5)?MIN(1,_black_fadeout_overlay.opacity+0.01*dt_scale_get()):MAX(0,_black_fadeout_overlay.opacity-0.01*dt_scale_get())];
	
	if ([game get_player_state] == PlayerState_Dive) {
		[_depth_bar_back setVisible:YES];
		float hei_from_top = [self depth_bar_from_top_fill_pct:game.player.position.y/game.get_ground_depth];
		[_depth_bar_icon_player setPosition:ccp(_depth_bar_icon_player.position.x,hei_from_top)];
		
	} else if ([game get_player_state] == PlayerState_InAir) {
		[_depth_bar_back setVisible:NO];
		[self depth_bar_from_bottom_fill_pct:0.5];
		
	} else {
		[_depth_bar_back setVisible:NO];
	}
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

-(void)update_enemy_health_bars:(GameEngineScene*)game {
	/*
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
	*/
}

@end
