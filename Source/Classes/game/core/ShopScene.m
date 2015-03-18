#import "ShopScene.h"
#import "Common.h"

#import "AccelerometerManager.h"
//#import "AccelerometerSimulation.h" 

#import "Resource.h"
#import "CCTexture_Private.h"
#import "SHButton.h"
#import "SHItemRow.h"

@implementation ShopScene {
	CameraZoom _target_camera;
	CameraZoom _current_camera;
	
	CCNode *_game_anchor;
	
	SHButton *_but_action;
	SHItemRow *_meleeRow, *_bowRow, *_armorRow;
	
	CGPoint _camera_center_point;
	
	AccelerometerManager *_accel;
}

+(GameEngineScene*)cons {
	return [[ShopScene node] cons];
}

-(id)cons {
	self.userInteractionEnabled = YES;
	_accel = [AccelerometerManager cons];
	
	_game_anchor = [[CCNode node] add_to:self];
	
	_but_action = (SHButton*)[[SHButton cons_width:(game_screen().width - 50)] add_to:_game_anchor z:0];
	_meleeRow = (SHItemRow*)[[SHItemRow cons] add_to:_game_anchor];
	[_meleeRow setPosition:ccp(game_screen().width / 2, game_screen().height - 50)];
	
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.delegate = self;
	accel.updateInterval = 1.0f/60.0f;
	
	return self;
}

-(void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler {
	[_accel accel_report_x:aceler.x y:aceler.y z:aceler.z];
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	[_meleeRow i_update:self];
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}

-(BOOL)fullScreenTouch { return YES; }

-(void)add_particle:(Particle*)p{}
-(void)add_gameobject:(GameObject*)o{}
-(void)remove_gameobject:(GameObject*)o{}
-(void)set_target_camera:(CameraZoom)tar{}
-(void)shake_for:(float)ct intensity:(float)intensity{}
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(_camera_center_point.x-game_screen().width/2,_camera_center_point.y-game_screen().height/2,game_screen().width,game_screen().height); }

@end

