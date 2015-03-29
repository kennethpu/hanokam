#import "ShopScene.h"
#import "Common.h"

#import "ControlManager.h"
//#import "AccelerometerSimulation.h" 

#import "Resource.h"
#import "CCTexture_Private.h"
#import "SHButton.h"
#import "SHItemRow.h"

@interface BaseShopItem : NSObject
@property(readwrite,assign) int price;
@property(readwrite,strong) NSString *name;
@property(readwrite,strong) void (^onPurchase)();
//image
//info text
@end

@implementation BaseShopItem
@synthesize price;
@synthesize name;
@synthesize onPurchase;
@end

@implementation ShopScene {
	CGPoint _touch_position;
	BOOL _touch_down;
	BOOL _touch_tapped;
	BOOL _touch_released;

	CameraZoom _target_camera;
	CameraZoom _current_camera;
	
	int _money;
	CCLabelTTF *_money_text;
	
	CCNode *_game_anchor;
	
	SHButton *_but_action, *_but_info, *_but_play;
	SHItemRow *_row_melee, *_row_bow, *_row_armor;
	
	CGPoint _camera_center_point;
	NSArray *_rows;
	
}

@synthesize row_focussing;

+(GameEngineScene*)cons {
	return [[ShopScene node] cons];
}

-(CGPoint)touch_position {
	return _touch_position;
}

-(BOOL)touch_down {
	return _touch_down;
}

-(BOOL)touch_tapped {
	return _touch_tapped;
}

-(BOOL)touch_released {
	return _touch_released;
}

-(id)cons {
	/*
	BaseShopItem *item = [[BaseShopItem alloc] init];
	item.price = 5;
	item.name = @"test item";
	item.onPurchase = ^void() {
		NSLog(@"test");
	};
	
	BaseShopItem *item2 = [[BaseShopItem alloc] init];
	item2.price = 10;
	item.name = @"test item2";
	item.onPurchase = ^void() {
		NSLog(@"test2");
	};
	
	
	_shop_items = @[item,item2];
	*/

	self.userInteractionEnabled = YES;
	
	_game_anchor = [[CCNode node] add_to:self];
	
	_money_text = label_cons(ccp(100, game_screen().height - 50), ccc3(255, 255, 255), 25, @"");
	[self addChild:_money_text z:99];
	
	_but_action = (SHButton*)[[SHButton cons_width:(game_screen().width - 50)] add_to:_game_anchor z:0];
	[_but_action setPosition:ccp(20, 90)];
	
	_but_info = (SHButton*)[[SHButton cons_width:(game_screen().width / 2 - 50)] add_to:_game_anchor z:0];
	[_but_info setPosition:ccp(20, 10)];
	
	_but_play = (SHButton*)[[SHButton cons_width:(game_screen().width / 2 - 50)] add_to:_game_anchor z:0];
	[_but_play setPosition:ccp(game_screen().width / 2 + 20, 10)];
	
	_row_melee = (SHItemRow*)[[SHItemRow cons_row_num:0] add_to:_game_anchor];
	[_row_melee setPosition:ccp(game_screen().width / 2, game_screen().height - 150)];
	
	_row_bow = (SHItemRow*)[[SHItemRow cons_row_num:1] add_to:_game_anchor];
	[_row_bow setPosition:ccp(game_screen().width / 2, game_screen().height - 250)];
	
	_row_armor = (SHItemRow*)[[SHItemRow cons_row_num:2] add_to:_game_anchor];
	[_row_armor setPosition:ccp(game_screen().width / 2, game_screen().height - 350)];
	
	_rows = @[_row_melee, _row_bow, _row_armor];
	
	_touch_position = ccp(0,0);
	
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.delegate = self;
	accel.updateInterval = 1.0f/60.0f;
	
	//
	_money = 10000;
	//
	
	return self;
}

-(void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler {
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	for (SHItemRow* itr in _rows) {
		[itr i_update:self];
	}
	
	_money_text.string = [NSString stringWithFormat:@"%i", _money];
	
	_touch_tapped = _touch_released = false;
}


-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_tapped = _touch_down = true;
	_touch_position = [touch locationInWorld];
}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_position = [touch locationInWorld];
}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	_touch_released = true;
	_touch_down = false;
	_touch_position = [touch locationInWorld];
}
@end

